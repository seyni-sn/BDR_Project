
/* Script projet tutoré base de données
Auteurs: Seyni KANE && Ramatoulaye DIALLO
Contacts: kane.seyni@ugb.edu.sn  &&  diallo.ramoutaye2@ugb.edu.sn*/




/*################--Creation de la base de donnees######################*/
DROP DATABASE IF EXISTS projet_base_donnees;
CREATE DATABASE projet_base_donnees;

DROP USER IF EXISTS seyni_rahmatoulaye;
CREATE USER seyni_rahmatoulaye WITH ENCRYPTED PASSWORD '01234';


REVOKE ALL ON DATABASE projet_base_donnees FROM PUBLIC;
GRANT ALL PRIVILEGES ON DATABASE projet_base_donnees TO seyni_rahmatoulaye;


--Connection a la base de donnees projet_base_donnees
\c projet_base_donnees;


/*################--Creation des fonctions ######################*/



CREATE OR REPLACE FUNCTION return_tarif_station(station VARCHAR (50)) RETURNS INTEGER AS $$
DECLARE
	resultat INTEGER := 0;
BEGIN

	SELECT tarif INTO resultat FROM Station WHERE nom_station = $1;

	RETURN resultat;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION return_capacite_station(station VARCHAR (50)) RETURNS INTEGER AS $$
DECLARE
	resultat INTEGER := 0;
BEGIN

	SELECT capacite INTO resultat FROM Station WHERE nom_station = $1;

	RETURN resultat;
END;
$$ LANGUAGE PLPGSQL;



/*################--Creation des tables######################*/

-- ************************ STATION ******************************

CREATE TABLE IF NOT EXISTS Station (nom_station VARCHAR (50) NOT NULL,
                       capacite INTEGER NOT NULL,
                       lieu VARCHAR (50) NOT NULL,
                       region VARCHAR (50),
                       tarif INTEGER DEFAULT 0,
                       CONSTRAINT CH_region CHECK (region IN ('Ocean Indien','Antilles','Europe','Amerique', 'Extreme Orient')),
                       CONSTRAINT PK_station PRIMARY KEY (nom_station),
                       CONSTRAINT Unique_station UNIQUE (lieu, region));

-- ************************ ACTIVITE ******************************


CREATE TABLE IF NOT EXISTS Activite (nom_station VARCHAR (50) NOT NULL,
                       libelle VARCHAR (50) NOT NULL,
                       prix INTEGER DEFAULT 0,
                       CONSTRAINT CH_prix CHECK (prix > 0 AND prix < return_tarif_station(nom_station)),
                       CONSTRAINT PK_activite PRIMARY KEY (nom_station, libelle),
                       CONSTRAINT FK_activite FOREIGN KEY (nom_station) REFERENCES Station(nom_station) ON DELETE CASCADE ON UPDATE CASCADE);


-- ************************ CLIENT ******************************

CREATE TABLE IF NOT EXISTS Client (id_client INTEGER NOT NULL,
                    nom VARCHAR (50) NOT NULL,
                    prenom VARCHAR (50),
                    ville VARCHAR (50) NOT NULL,
                    region VARCHAR (50) NOT NULL,
                    solde INTEGER NOT NULL DEFAULT 0,
                    CONSTRAINT PK_client PRIMARY KEY (id_client));



-- ************************ SEJOUR ******************************


CREATE TABLE IF NOT EXISTS Sejour (id_sejour INTEGER NOT NULL,
                    station VARCHAR (30) NOT NULL,
                    debut DATE NOT NULL,
                    nb_place INTEGER NOT NULL,
                    CONSTRAINT CH_nb_place CHECK (nb_place < return_capacite_station(station)),
                    CONSTRAINT PK_sejour PRIMARY KEY (id_sejour, station, debut),
                    CONSTRAINT FK_sejour FOREIGN KEY (station) REFERENCES Station (nom_station) ON DELETE CASCADE ON UPDATE CASCADE);






/*################--Insertion des donnees######################*/

--SUPPRESSION DES DONNEES

DELETE FROM Station;
DELETE FROM Activite;
DELETE FROM Client;
DELETE FROM Sejour;

--************************ STATION ******************************

INSERT INTO Station (nom_station, capacite, lieu, region, tarif) VALUES ('Venusa', 350, 'Guadeloupe', 'Antilles', 1200);
INSERT INTO Station (nom_station, capacite, lieu, region, tarif) VALUES ('Venusa', 350, 'Guadeloupe', 'Antilles', 1200);



--************************ ACTIVITE ******************************

INSERT INTO Activite (nom_station, libelle, prix) VALUES ('Venusa','Voile',150);
INSERT INTO Activite (nom_station, libelle, prix) VALUES ('Venusa','Plongée',120);


--************************ CLIENT ******************************

INSERT INTO Client (id_client, nom, prenom, ville, region, solde) VALUES (10, 'Fogg','Phileas', 'Londres', 'Europe', 12465);
INSERT INTO Client (id_client, nom, prenom, ville, region, solde) VALUES (20, 'Pascal','Blaise', 'Paris', 'Europe', 12465);
INSERT INTO Client (id_client, nom, prenom, ville, region, solde) VALUES (30, 'Kerouak','Jack', 'New York', 'Amérique', 9812);



--************************ SEJOUR ******************************

INSERT INTO Sejour (id_sejour, station, debut, nb_place) VALUES (20,'Venusa','03-08-2003',4);




/*################--Tests######################*/

--************************ Affichage des tables ******************************

SELECT * FROM Station;
SELECT * FROM Activite;
SELECT * FROM Client;
SELECT * FROM Sejour;


--************************ Teste des contraintes d'integrites ******************************

-- Destruction de la station 'Venusa'
DELETE FROM Station WHERE nom_station = 'Venusa';
--Verifaction sur la table activiite
SELECT * FROM Activite WHERE nom_station = 'Venusa';

--Insertion d'une nouvelle station
INSERT INTO Station (nom_station, capacite, lieu, region, tarif) VALUES ('Kampala', 350, 'Guadeloupe', 'Antilles', 1200);
--Insertion d'une station dans une region 'Nullpart'
INSERT INTO Station (nom_station, capacite, lieu, region, tarif) VALUES ('Moubaraka', 350, 'Guinea', 'Nullepart', 1500);

--Test de la contrainte CH_prix par insertion d'une nouvelle activite ayant un prix superieur au tarif de la station
INSERT INTO Activite (nom_station, libelle, prix) VALUES ('Kampala', 'vollé', 1201);

--Test de la contrainte Unique_station insertion d'une nouvelle station dans le meme lieu et la meme region qu'une autre station
INSERT INTO Station (nom_station, capacite, lieu, region, tarif) VALUES ('Moubaraka', 450, 'Guadeloupe', 'Antilles', 1500);

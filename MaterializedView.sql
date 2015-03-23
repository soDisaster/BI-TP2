/* 
Saint-Omer Anne-Sophie
Poux Delphine
*/

drop materialized view v_produit;
drop materialized view v_temps;
drop materialized view v_client;
drop materialized view v_adresse;
drop materialized view v_vente;
drop dimension v_produit_dim;
drop dimension v_client_dim;
drop dimension v_temps_dim;
drop dimension v_adresse_dim;
drop index IX_SEXE;

/* Vue pour la dimension produit */
column designation heading designation Format a30
column num heading num Format 9999
column categorie Format a20
column souscategorie Format a20
Create materialized view  v_produit
Refresh force on demand as
SELECT num as nump, substr(designation,1,instr(designation,'.',1,1)-1) as designation,
CASE
	WHEN instr(designation,'.',1,2) = 0 THEN substr(designation,instr(designation,'.',1,1)+1,length(designation)-instr(designation,'.',1,1))
	ELSE substr(designation,instr(designation,'.',1,1)+1,instr(designation,'.',1,2)-instr(designation,'.',1,1)-1)
END categorie,
CASE
	WHEN instr(designation,'.',1,2) = 0 THEN 'Pas de sc'
	ELSE substr(designation,instr(designation,'.',1,2)+1, length(designation) - instr(designation,'.',1,2)+1)
END souscategorie
FROM PRODUIT;


/* Vue pour la dimension client */
column jour Format 999999
Create MATERIALIZED VIEW v_client
Refresh force on demand as 
SELECT  
CASE 
	WHEN age  < 30 THEN '<30' 
	WHEN age between 30 and 45 THEN '30-45ans'
	WHEN age between 46 and 60 THEN '45-60ans'
	WHEN age > 60 THEN '>60ans'
END tranche_age,
num as numc, sexe, age
FROM 
	(
	SELECT num, sexe, FLOOR((MONTHS_BETWEEN(SYSDATE,date_nais)/12)) as age
	FROM client
	);


/* Vue pour la dimension temps */
Create materialized view  v_temps 
Refresh force on commit as
SELECT date_etabli as id_temps, TO_CHAR(date_etabli, 'DDD') as jour, TO_CHAR(date_etabli, 'IW') as semaine, TO_CHAR(date_etabli, 'MM') as mois, TO_CHAR(date_etabli, 'YYYY') as annee
FROM FACTURE;

/* Vue pour la dimension adresse */
column ville Format a15
column pays Format a15
column code_postal Format a12
Create materialized view v_adresse 
Refresh force on demand as
SELECT substr(adresse,instr(adresse,',',1,1)+1,instr(adresse,',',1,2)-instr(adresse,',',1,1)-1) as code_postal, substr(adresse, instr(adresse,',',1,2)+1,instr(adresse,',',1,3)-instr(adresse,',',1,2)-1) as ville, substr(adresse, instr(adresse,',',1,3)+1,length(adresse)-instr(adresse,',',1,3)) as pays
FROM client;



/* Vue pour la table de fait */
column numc Format 9999999
column nump Format 9999999
column id_adr Format a12
column id_temps Format a10
column qte Format 999
column prix Format 99999
column remise Format 99999
Create materialized view v_vente
Refresh force on demand as
SELECT distinct numc, nump, code_postal as id_adr, id_temps, qte, prix, remise
FROM client c, v_client cl, v_produit p, facture f, ligne_facture lf, v_adresse a, v_temps t, prix_date dp
WHERE f.client = cl.numc
AND lf.facture = f.num
AND lf.produit = p.nump
AND a.code_postal = substr(adresse,instr(adresse,',',1,1)+1,instr(adresse,',',1,2)-instr(adresse,',',1,1)-1)
AND c.num = cl.numc
AND t.id_temps = f.date_etabli
AND lf.id_prix = dp.num; 

/* Clés primaires */

alter materialized view v_client add constraint primary_key_client primary key (numc) disable;
alter materialized view v_temps add constraint primary_key_temps primary key (id_temps) disable;
alter materialized view v_adresse add constraint primary_key_adresse primary key (code_postal) disable;

/* Clés étrangères */
alter materialized view v_vente add constraint foreign_key_venteToClient foreign key (numc) references V_CLIENT(numc) disable;
alter materialized view v_vente add constraint foreign_key_venteToProduit foreign key (nump) references V_PRODUIT(nump) disable;
alter materialized view v_vente add constraint foreign_key_venteToDate foreign key (id_temps) references V_TEMPS(id_temps) disable;
alter materialized view v_vente add constraint foreign_key_venteToAdresse foreign key (id_adr) references V_ADRESSE(code_postal) disable;
/*alter materialized view v_produit add constraint primary_key_produit primary key(nump) disable;*/


/* Index */
CREATE BITMAP INDEX IX_SEXE
ON v_client (sexe);


/* Dimensions */
/* Dimension pour le produit */
CREATE DIMENSION v_produit_dim
LEVEL designation IS (v_produit.designation)
LEVEL sousCategorie IS (v_produit.sousCategorie) SKIP WHEN NULL
LEVEL categorie IS (v_produit.categorie)
HIERARCHY prod_rollup (
			designation CHILD OF sousCategorie CHILD OF categorie
		      );

/* Dimension pour le client */
CREATE DIMENSION v_client_dim
LEVEL age IS (v_client.age)
LEVEL tranche_age IS (v_client.tranche_age)
HIERARCHY client_rollup(
			age CHILD OF tranche_age
		     );

/* Dimension pour le temps */
CREATE DIMENSION v_temps_dim
LEVEL jour IS (v_temps.jour)
LEVEL semaine IS (v_temps.semaine)
LEVEL mois IS (v_temps.mois)
LEVEL annee IS (v_temps.annee)
HIERARCHY temps_rollup(
			jour CHILD OF semaine CHILD OF mois CHILD OF annee
		      );

/* Dimension pour l'adresse */
CREATE DIMENSION v_adresse_dim
LEVEL ville IS (v_adresse.ville)
LEVEL pays IS (v_adresse.pays)
HIERARCHY adresse_rollup(
			ville CHILD OF pays
			);

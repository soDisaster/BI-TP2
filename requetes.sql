/* 
Saint-Omer Anne-Sophie
Poux Delphine
*/

/* Requête 1 : Quel est le chiffre d'affaire par produit ? */
column designation Format a50
column CA Format 99999999
set pagesize 100
SELECT designation, SUM(qte*prix) as CA
FROM v_vente v, v_produit p
WHERE v.nump = p.nump
GROUP BY designation
ORDER BY designation;

/* Requête 2 : Quel est le chiffre d'affaire par catégorie et mois, par catégorie et globalement ? */
column categorie Format a30
column mois Format 99999
column CA Format 9999999999
set pagesize 1000
SELECT categorie, mois, SUM(qte*prix) as CA
FROM v_vente, v_produit, v_temps
WHERE v_vente.nump = v_produit.nump
AND v_vente.id_temps = v_temps.id_temps
GROUP BY ROLLUP (categorie,mois);

/* Requêtes 3 : Quel est le chiffre d'affaire par tranche d'âge, en donnant le rang de chaque tranche d'âge ? */
column tranche_age Format a15
SELECT tranche_age, CA_tranche_age, RANK() OVER(PARTITION BY tranche_age ORDER BY CA_tranche_age) as rang
FROM	(
	SELECT tranche_age, SUM(qte*prix) as CA_tranche_age
	FROM v_vente, v_client
	WHERE v_vente.numc = v_client.numc
	GROUP BY tranche_age
			ORDER BY tranche_age
			)
ORDER BY CA_tranche_age DESC;

/* Requête 4 : Quels sont les 3 produits les plus vendus en quantité */
SELECT designation, SUM(QTE) as CA_produit,RANK() OVER(PARTITION BY designation ORDER BY SUM(QTE)) as rang
FROM v_vente, v_produit
WHERE v_vente.nump = v_produit.nump
GROUP BY designation
ORDER BY CA_produit DESC;

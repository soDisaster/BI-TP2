drop materialized view v_produit;
drop materialized view v_temps;


Create materialized view  v_produit
Build immediate
Refresh force on demand
Enable query rewrite as
SELECT num, designation
FROM PRODUIT;


Create materialized view v_client
Build immediate
Refresh force on demand
Enable query rewrite as
SELECT num, nom, prenom, @age, adresse, sexe
FROM CLIENT, dual
WHERE (set @age = (((TO_DATE(SYSDATE, 'YYYY'))) - ((TO_DATE(date_nais, 'YYYY')))));


Create materialized view  v_temps
Build immediate
Refresh force on demand
Enable query rewrite as
SELECT date_etabli
FROM FACTURE;




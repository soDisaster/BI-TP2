INSERT INTO CLIENT VALUES(client_seq.nextval,'Poux','Delphine','575 rue du pain,59730,Berlin,Allemagne',TO_DATE('08/22/1990','mm/dd/yy'),'femme');

INSERT INTO PRODUIT VALUES(79,'Poivre.Condiments', 604 );

INSERT INTO prix_date VALUES(79,79,TO_DATE('02/19/2015','mm/dd/yy'),2,1);

INSERT INTO FACTURE VALUES(1575,94,TO_DATE('02/19/2015','mm/dd/yy'));

INSERT INTO LiGNE_FACTURE VALUES(1575,79,1,79);

execute DBMS_MVIEW.REFRESH('v_client')
execute DBMS_MVIEW.REFRESH('v_produit')
execute DBMS_MVIEW.REFRESH('v_adresse')
execute DBMS_MVIEW.REFRESH('v_temps')
execute DBMS_MVIEW.REFRESH('v_vente')

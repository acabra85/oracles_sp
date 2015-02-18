PROCEDURE SP_GUARDAR_CACHE(ivaLlave  IN VARCHAR2,
                          ivaCache IN VARCHAR2,
                          ivaObjeto IN BLOB,
                          ovaMensajeTecnico OUT VARCHAR2,
                          ovaMensajeUsuario OUT VARCHAR2) IS
 lvaLlaveSel VARCHAR2(255):= NULL;
 lboActualizar BOOLEAN:= FALSE;
 lcoDismin  VARCHAR(25):= 'COUNTER_DISMINUIR_';
 lcoCrear  VARCHAR(25):= 'COUNTER_CREAR_';
 lnuCounterDism NUMBER:=0;
 lnuCounter NUMBER:=0;
 lvaCacheNum VARCHAR2(255);
 lvaCache VARCHAR2(60);
 lvaNombreCounter VARCHAR2(7):='Counter';
 lblCounterVal BLOB;
 
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    lnuCounter := INSTR(ivaCache,lcoCrear);
    IF lnuCounter > 0  THEN
      lvaCacheNum :=  TRIM(TRANSLATE(ivaCache, lcoCrear, ' '));
      lnuCounter := TO_NUMBER(lvaCacheNum);
      DBMS_OUTPUT.put_line('NUMERO A INSERTAR:'||lnuCounter);
      
      lvaCache:= lvaNombreCounter;
    
    ELSE
      lvaCache := ivaCache;
      lnuCounterDism := INSTR(ivaCache,lcoDismin);
       IF lnuCounterDism > 0  THEN
         lvaCacheNum :=  TRIM(TRANSLATE(ivaCache, lcoDismin, ' '));
       
         lnuCounterDism := TO_NUMBER(lvaCacheNum);
         DBMS_OUTPUT.put_line('NUMERO DISM:'||lnuCounterDism);
        
         lvaCache:= lvaNombreCounter;
         SELECT T.NMCONTCACHE INTO lnuCounter FROM TMVG_CACHES T
         WHERE  T.NMLOTE = ivaLlave AND T.DSCACHE = lvaCache;
  
         lnuCounter := lnuCounter - lnuCounterDism;
         DBMS_OUTPUT.put_line('NUMERO delta:'||lnuCounter);   
       END IF;
    END IF;
  BEGIN
  
    SELECT T.DSCACHE INTO lvaLlaveSel FROM TMVG_CACHES T
    WHERE  T.NMLOTE = ivaLlave AND T.DSCACHE = lvaCache;
    lboActualizar:= TRUE;
    EXCEPTION
      WHEN OTHERS THEN
      INSERT INTO TMVG_CACHES(NMLOTE,DSCACHE,DSOBJETO,FEINSERCION,NMCONTCACHE)
       VALUES(ivaLlave,lvaCache,ivaObjeto, SYSDATE,lnuCounter);
   END;
  
   IF lboActualizar THEN
    
     UPDATE TMVG_CACHES T SET T.FEULTIMA_ACT= SYSDATE, T.DSOBJETO = ivaObjeto,
     T.NMCONTCACHE = lnuCounter
     WHERE T.NMLOTE = ivaLlave AND T.DSCACHE = lvaCache;
   END IF;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
      ovaMensajeUsuario := 'Error al Almacenar Cache ';
      ovaMensajeTecnico := ovaMensajeUsuario || (SQLCODE);
   
END SP_GUARDAR_CACHE;

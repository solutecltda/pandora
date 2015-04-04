--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: plpython2u; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpython2u WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpython2u; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpython2u IS 'PL/Python2U untrusted procedural language';


SET search_path = public, pg_catalog;

--
-- Name: comillas(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comillas(character) RETURNS character
    LANGUAGE plpgsql
    AS $_$

declare
  pcadena alias for $1;

begin
  return ''''||pcadena||'''';
end;

$_$;


ALTER FUNCTION public.comillas(character) OWNER TO postgres;

--
-- Name: configurar_inv(character, character, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION configurar_inv(character, character, character) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE
 p_usuario ALIAS FOR $1;
 p_cara ALIAS FOR $2;
 p_gondola ALIAS FOR $3;
 
BEGIN

 Execute ' 
 	UPDATE configurarinv 
       SET gondola = '''||p_gondola||''' , 
           cara    = '''||p_cara ||'''
     WHERE usuario = '''||p_usuario||''' ';
     
 RETURN TRUE;
END;
$_$;


ALTER FUNCTION public.configurar_inv(character, character, character) OWNER TO postgres;

--
-- Name: configurar_inv(character, character, character, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION configurar_inv(character, character, character, character) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE
 p_usuario ALIAS FOR $1;
 p_cara ALIAS FOR $2;
 p_gondola ALIAS FOR $3;
 p_tipoinv ALIAS FOR $4;
 
 
BEGIN

 Execute ' 
 	UPDATE configurarinv 
       SET gondola = '''||p_gondola||''' , 
           cara    = '''||p_cara ||''',
           tipoinv = '||p_tipoinv||'
     WHERE usuario = '''||p_usuario||''' ';
     
 RETURN TRUE;
END;
$_$;


ALTER FUNCTION public.configurar_inv(character, character, character, character) OWNER TO postgres;

--
-- Name: configurar_inv(character, character, character, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION configurar_inv(character, character, character, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE
 p_usuario ALIAS FOR $1;
 p_cara ALIAS FOR $2;
 p_gondola ALIAS FOR $3;
 p_tipoinv ALIAS FOR $4;
 
 
BEGIN

 Execute ' 
 	UPDATE configurarinv 
       SET gondola = '''||p_gondola||''' , 
           cara    = '''||p_cara ||''',
           tipoinv = '||p_tipoinv||'
     WHERE usuario = '''||p_usuario||''' ';
     
 RETURN TRUE;
END;
$_$;


ALTER FUNCTION public.configurar_inv(character, character, character, integer) OWNER TO postgres;

--
-- Name: configurar_inv(character, integer, integer, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION configurar_inv(character, integer, integer, character) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE

	p_usuario 	ALIAS FOR $1;
	p_cara 		ALIAS FOR $2;
	p_gondola 	ALIAS FOR $3;
	p_tipoinv 	ALIAS FOR $4;

	vrReg		RECORD;
	control		integer := 0;
	
BEGIN

  for vrReg IN SELECT count(*) as nro FROM configurarinv
			WHERE usuario = p_usuario
  Loop
	control := vrReg.nro;
  End Loop;


  if control = 0 then 
	INSERT INTO configurarinv VALUES (default, p_usuario, p_cara, p_gondola, p_tipoinv );
  else
	UPDATE configurarinv 
	SET 	gondola = p_gondola, 
			cara    = p_cara,
			tipoinv = p_tipoinv
	WHERE 	usuario = p_usuario ;
  end if;
	

 RETURN TRUE;
 
 END;
$_$;


ALTER FUNCTION public.configurar_inv(character, integer, integer, character) OWNER TO postgres;

--
-- Name: pda_transmitir_inv(character, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pda_transmitir_inv(character, integer, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
DECLARE

	p_usuario 	ALIAS FOR $1;
	p_cara 		ALIAS FOR $2;
	p_gondola 	ALIAS FOR $3;

	vrReg		RECORD;
	control		integer := 0;
	t_inv_alm	text;
	
BEGIN

  t_inv_alm := 'tmp_inv_almacen';
  
  for vrReg IN SELECT * FROM inventari_mv10 
			WHERE 	gondola = p_gondola and
					cara    = p_cara
  Loop
	Execute 'insert into '||t_inv_alm||' 
				(
					gondola,
					cara,
					rotulo,
					id_referencia,
					cantidad,
					ejecutor_conteo,
					usuario_proceso
				)
		VALUES	(
					'||vrReg.gondola||',
					'||vrReg.cara||',
					'||vrReg.consecutivo||',
					'||comillas(vrReg.ean)||',
					'||vrReg.cantidad||',
					'||comillas(p_usuario)||',
					'||comillas(p_usuario)||'
				)';
  End Loop;

  -- Falta crear la tabla de Bitacora y llenarla por cada conteo realizado 
  -- en una PDA.
  
 RETURN TRUE;
 
END;
$_$;


ALTER FUNCTION public.pda_transmitir_inv(character, integer, integer) OWNER TO postgres;

--
-- Name: pymax(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pymax(a integer, b integer) RETURNS integer
    LANGUAGE plpython2u
    AS $$
  if a > b:
    return a
  return b
$$;


ALTER FUNCTION public.pymax(a integer, b integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: EMPLEADO; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "EMPLEADO" (
    "ID_ALMACEN" character(2) NOT NULL,
    "C_COSTO" character(2) NOT NULL,
    "NIT_EMPLEADO" character(12) NOT NULL,
    "NOMBRE" character(40) NOT NULL,
    "ID_CARGO" smallint NOT NULL,
    "TIPO_EMPLEADO" smallint NOT NULL,
    "FECHA_NACIMIENTO" date NOT NULL,
    "SEXO" smallint NOT NULL,
    "DIRECCION" character varying(40) NOT NULL,
    "TELEFONO" character varying(15),
    "CIUDAD_RESIDE" character(5),
    "ESTADO_CIVIL" smallint,
    "GRUPO_SANGUINEO" smallint NOT NULL,
    "PERSONAS_A_CARGO" smallint NOT NULL,
    "ID_NIVEL" smallint NOT NULL,
    "ID_CUENTA" character varying(20),
    "ID_BANCO" character(2),
    "FECHA_INGRESO" date NOT NULL,
    "ID_CONTRATO" smallint NOT NULL,
    "SUELDO_BASICO" double precision NOT NULL,
    "CIUDAD_NACIMIENTO" character(5),
    "ID_ESTADO" smallint DEFAULT 0,
    "TIPO_CONTABLE" character(2) DEFAULT '51'::bpchar NOT NULL,
    "FACTOR_TRANSPORTE" numeric(9,2),
    "FACTOR_SUELDO" numeric(5,2) DEFAULT 1.00,
    "TERMINACION_CONTRATO" date,
    "EMP_IMG" integer
);


ALTER TABLE public."EMPLEADO" OWNER TO postgres;

--
-- Name: configurarinv; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE configurarinv (
    id integer NOT NULL,
    usuario character(20),
    cara integer,
    gondola integer,
    tipoinv character(1)
);


ALTER TABLE public.configurarinv OWNER TO postgres;

--
-- Name: configurarinv_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE configurarinv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.configurarinv_id_seq OWNER TO postgres;

--
-- Name: configurarinv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE configurarinv_id_seq OWNED BY configurarinv.id;


--
-- Name: empleados_maes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE empleados_maes (
    id integer NOT NULL,
    tipodoc_id integer,
    numero_doc integer,
    nombre1 character(20),
    nombre2 character(20),
    apellido1 character(20),
    apellido2 character(20),
    contrato integer,
    estado integer,
    id_almacen character(2) NOT NULL,
    c_costo character(2) NOT NULL,
    nit_empleado character(12) NOT NULL,
    nombre character(40) NOT NULL,
    id_cargo smallint NOT NULL,
    tipo_empleado smallint NOT NULL,
    fecha_nacimiento date NOT NULL,
    sexo smallint NOT NULL,
    direccion character varying(40) NOT NULL,
    telefono character varying(15),
    ciudad_reside character(5),
    estado_civil smallint,
    grupo_sanguineo smallint NOT NULL,
    personas_a_cargo smallint NOT NULL,
    id_nivel smallint NOT NULL,
    id_cuenta character varying(20),
    id_banco character(2),
    fecha_ingreso date NOT NULL,
    id_contrato smallint NOT NULL,
    sueldo_basico double precision NOT NULL,
    ciudad_nacimiento character(5),
    id_estado smallint DEFAULT 0,
    tipo_contable character(2) DEFAULT '51'::bpchar NOT NULL,
    factor_transporte numeric(9,2),
    factor_sueldo numeric(5,2) DEFAULT 1.00,
    terminacion_contrato date,
    emp_img integer
);


ALTER TABLE public.empleados_maes OWNER TO postgres;

--
-- Name: COLUMN empleados_maes.tipodoc_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN empleados_maes.tipodoc_id IS 'tipos de documento';


--
-- Name: COLUMN empleados_maes.estado; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN empleados_maes.estado IS 'Estado del empleado : activo, retirado';


--
-- Name: empleados_maes_copia; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE empleados_maes_copia (
    id integer DEFAULT nextval(('public.empleados_maes_id_seq'::text)::regclass) NOT NULL,
    tipodoc_id integer,
    numero_doc integer,
    nombre1 character(20),
    nombre2 character(20),
    apellido1 character(20),
    apellido2 character(20),
    contrato integer,
    estado integer
);


ALTER TABLE public.empleados_maes_copia OWNER TO postgres;

--
-- Name: COLUMN empleados_maes_copia.tipodoc_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN empleados_maes_copia.tipodoc_id IS 'tipos de documento';


--
-- Name: COLUMN empleados_maes_copia.estado; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN empleados_maes_copia.estado IS 'Estado del empleado : activo, retirado';


--
-- Name: empleados_maes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE empleados_maes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.empleados_maes_id_seq OWNER TO postgres;

--
-- Name: empleados_maes_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE empleados_maes_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.empleados_maes_id_seq1 OWNER TO postgres;

--
-- Name: empleados_maes_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE empleados_maes_id_seq1 OWNED BY empleados_maes.id;


--
-- Name: inventari_mv10; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventari_mv10 (
    id integer NOT NULL,
    id_parent integer NOT NULL,
    gondola integer,
    cara integer,
    consecutivo integer,
    ean character(20),
    cantidad numeric(10,3)
);


ALTER TABLE public.inventari_mv10 OWNER TO postgres;

--
-- Name: inventari_mv10_id_parent_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventari_mv10_id_parent_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventari_mv10_id_parent_seq OWNER TO postgres;

--
-- Name: inventari_mv10_id_parent_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventari_mv10_id_parent_seq OWNED BY inventari_mv10.id_parent;


--
-- Name: inventari_mv10_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventari_mv10_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventari_mv10_id_seq OWNER TO postgres;

--
-- Name: inventari_mv10_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventari_mv10_id_seq OWNED BY inventari_mv10.id;


--
-- Name: pending_users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pending_users (
    token character(40) NOT NULL,
    username character varying(45) NOT NULL,
    tstamp integer NOT NULL
);


ALTER TABLE public.pending_users OWNER TO postgres;

--
-- Name: sesiones_de_usuarios; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sesiones_de_usuarios (
    token character(40) NOT NULL,
    usuario character varying(45) NOT NULL,
    sello_de_tiempo integer NOT NULL
);


ALTER TABLE public.sesiones_de_usuarios OWNER TO postgres;

--
-- Name: tmp_inv_almacen; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tmp_inv_almacen (
    id_referencia character(30),
    descripcion_articulo character(40),
    gondola integer,
    cara integer,
    rotulo integer,
    cantidad double precision,
    fecha date DEFAULT ('now'::text)::date,
    ejecutor_conteo character(40),
    usuario_proceso character(15),
    fecha_proceso timestamp without time zone DEFAULT now()
);


ALTER TABLE public.tmp_inv_almacen OWNER TO postgres;

--
-- Name: turnos_mv10; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE turnos_mv10 (
    id integer NOT NULL,
    turno integer
);


ALTER TABLE public.turnos_mv10 OWNER TO postgres;

--
-- Name: turnos_mv10_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE turnos_mv10_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.turnos_mv10_id_seq OWNER TO postgres;

--
-- Name: turnos_mv10_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE turnos_mv10_id_seq OWNED BY turnos_mv10.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE usuarios (
    id integer NOT NULL,
    usuario character(20),
    clave character(20),
    bloqueado boolean
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE usuarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usuarios_id_seq OWNER TO postgres;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE usuarios_id_seq OWNED BY usuarios.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY configurarinv ALTER COLUMN id SET DEFAULT nextval('configurarinv_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY empleados_maes ALTER COLUMN id SET DEFAULT nextval('empleados_maes_id_seq1'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventari_mv10 ALTER COLUMN id SET DEFAULT nextval('inventari_mv10_id_seq'::regclass);


--
-- Name: id_parent; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventari_mv10 ALTER COLUMN id_parent SET DEFAULT nextval('inventari_mv10_id_parent_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY turnos_mv10 ALTER COLUMN id SET DEFAULT nextval('turnos_mv10_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY usuarios ALTER COLUMN id SET DEFAULT nextval('usuarios_id_seq'::regclass);


--
-- Data for Name: EMPLEADO; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "EMPLEADO" ("ID_ALMACEN", "C_COSTO", "NIT_EMPLEADO", "NOMBRE", "ID_CARGO", "TIPO_EMPLEADO", "FECHA_NACIMIENTO", "SEXO", "DIRECCION", "TELEFONO", "CIUDAD_RESIDE", "ESTADO_CIVIL", "GRUPO_SANGUINEO", "PERSONAS_A_CARGO", "ID_NIVEL", "ID_CUENTA", "ID_BANCO", "FECHA_INGRESO", "ID_CONTRATO", "SUELDO_BASICO", "CIUDAD_NACIMIENTO", "ID_ESTADO", "TIPO_CONTABLE", "FACTOR_TRANSPORTE", "FACTOR_SUELDO", "TERMINACION_CONTRATO", "EMP_IMG") FROM stdin;
1 	1 	37580301    	CINDY MILENA ROA CAMPO                  	17	3	1985-04-24	1	ADJPAKDJAJDKJL	64370000	68001	2	1	0	5	45	8 	2007-10-03	253	461500	68001	1	52	0.00	1.00	2008-10-30	0
0 	0 	63334739    	MARTHA MALDONADO GUARIN                 	29	1	1967-04-23	1	Car.  8 No. 61-137  BGA	6410422	68001	1	1	0	2	0	60	1995-10-02	2	3100000	68780	1	51	0.00	1.00	2006-10-05	0
1 	1 	91427130    	WILSON RIOS RINCON                      	102	1	1965-11-27	2	DIG 54B No 22B - 50  SFCO	6463224	68307	1	1	0	2	0	60	1988-05-21	5	1700000	68081	0	52	0.00	1.00	2005-12-30	0
0 	0 	63367439    	EDITA MALAVER DURAN                     	29	1	1971-02-14	1	DIG 10 No 20A-13 GIRON  BGA	6591254	68307	1	1	0	2	0	60	1998-08-20	4	700000	68001	1	51	0.00	1.00	2005-12-30	0
0 	0 	37935323    	PORFIRIA C BARROSO BERASTEGUI           	29	3	1966-03-02	1	CLL 60A  No 37-14  BARRANCA	6221732	68081	1	1	0	2	0	60	1992-03-02	7	2700000	68081	0	52	0.00	1.00	2005-12-30	0
0 	0 	28285070    	NIDIA ALEXANDRA PATIÑO                  	29	1	1979-11-15	1	BUCARICA BLQ 18-2 APT 502  BGA	6484552	68276	1	1	0	2	0	60	2004-08-30	8	650000	68533	1	51	0.00	1.00	2006-12-30	0
1 	1 	37930277    	ADELA LOPEZ NOVA                        	17	1	1961-08-15	1	CRA 38 No 36C-83 CALIDAD	6106790	68081	1	1	0	2	0	60	2004-05-10	13	461500	68081	1	52	0.00	1.00	2005-12-30	0
4 	4 	91446775    	LUIS CARLOS PASSO ROJASA                	15	3	1976-01-26	2	CRA 8 No 47-51 BARRANCA	6206305	68081	1	1	0	2	0	60	2003-04-21	14	461500	68081	1	52	0.00	1.00	2005-12-30	0
1 	1 	91422999    	EMEL MORALES GIL                        	15	1	1974-12-16	2	CRA 52 No. 26-57  CALIDAD	6105665	68081	1	1	0	2	0	60	2004-06-01	15	550000	13300	1	52	0.00	1.00	2005-12-30	0
0 	0 	37864635    	SILVIA JULIANA PRIETO LUNA              	29	1	1981-07-18	1	masxmenos	6447300	68001	1	1	0	4	107-158555	5 	2004-12-15	98	800000	68001	1	51	0.00	1.00	2005-12-15	0
4 	4 	36505582    	HEIDY DE J QUEVEDO ACUÑA                	16	1	1975-07-27	1	PTN 6 No 36E-22  BARRANCA	6219190	68081	1	1	0	2	0	60	2004-07-16	17	496900	47707	1	52	0.00	1.00	2004-12-30	0
4 	4 	37933870    	MARIA EUGENIA BLANCO MANCIPE            	12	1	1966-03-30	1	CLL 51 No 15-27 CALIDAD	6226709	68081	1	1	0	2	0	5 	2004-06-22	18	1000000	68615	1	52	0.00	1.00	2005-06-27	0
1 	1 	1095792580  	EDUARDO JOSE MERLANO CELIS              	17	3	1987-04-09	2	JAJDLJAD	6447300	68001	2	1	0	5	5465456456	8 	2007-05-24	239	433700	68001	1	52	0.00	1.00	2008-05-24	0
4 	4 	63463261    	ROSA MARIA ULLOA POLANCO                	17	1	1973-12-22	1	CLL 52B No 34C 05  BARRANCA	6219134	68081	1	1	0	2	0	60	2004-06-15	20	535600	68081	1	52	0.00	1.00	2006-12-30	0
1 	1 	13854428    	DONALDI MONTES BAEZ                     	15	1	1982-01-18	2	CLL56 NO 34D - 20  CALIDAD	6101234	68081	1	1	0	2	0	60	2004-07-01	21	433700	68081	1	52	0.00	1.00	2005-07-01	0
0 	0 	37513420    	MARGARITA MARIA BAUTISTA LOPEZ          	29	1	1978-01-01	1	mas por menos	6447300	68001	2	5	1	4	0	5 	2004-02-23	99	800000	68001	1	51	0.00	1.00	2005-02-23	0
0 	0 	37842598    	CAROLINA SIERRA VALERO                  	29	1	1981-02-23	1	C. RES FATIMA CS 11H  BGA	6313624	68001	1	1	0	2	0	60	2004-08-09	23	850000	68001	1	51	0.00	1.00	2005-08-09	0
1 	1 	91445943    	EDWIN URIBE TARAZONA                    	14	1	1976-09-07	2	CLL 42 No 42-08 BARRANCA	6205109	68081	1	1	0	2	0	60	2010-08-04	24	750000	68081	1	52	0.00	1.00	2006-12-30	0
6 	6 	91505559    	ALBEIRO BAUTISTA FLOREZ                 	15	3	1980-05-14	2	HASHDUIASYDSAHDJO	6486189	68276	1	5	0	2	525252	8 	2005-11-10	102	433700	68276	1	52	0.00	1.00	2006-11-09	0
5 	5 	63513094    	ZOILA ISABEL JIMENEZ S                  	12	1	1976-06-24	1	CRA 21  No 35-10  PROVENZA	6300062	68001	1	1	0	2	0	60	2004-08-30	26	1000000	68001	1	52	0.00	1.00	2005-08-30	0
4 	4 	88237934    	RAFAEL ARRIETA BALDOVINO                	15	3	1980-01-01	2	BARRANCA	6224514	68081	1	5	0	2	0	5 	2006-06-01	100	433700	68081	1	52	0.00	1.00	2006-12-30	0
1 	1 	91440135    	EDWARD JAVIER GONZALEZ                  	20	1	1972-03-17	2	 DIG 57 No 43-145  CALIDAD	6216668	68081	1	1	0	2	0	60	2013-07-10	28	1550000	68081	1	52	0.00	1.00	2005-08-30	0
2 	2 	63539643    	YENY YOMARA DELGADO RUIZ                	14	1	1983-06-17	1	CALLE 51 N§ 15-25  BUCARICA	6815550	68001	1	1	0	2	0	60	2004-09-01	29	500000	68001	1	52	0.00	1.00	2005-12-30	0
1 	1 	63468882    	DANEXI DITA TAPIAS                      	17	1	1975-10-28	1	CRA 36I No 50-45  BARRANCA	6217771	68081	1	1	0	2	0	60	2004-09-06	30	433700	68081	1	52	0.00	1.00	2005-09-06	0
0 	0 	91487783    	EDDINSON FDO. BARON PEDRAZA             	29	1	1976-04-16	2	BLOQUE 17-1 APTO 201  BGA	6481389	68276	1	1	0	2	0	60	2007-02-05	31	1200000	68001	1	51	0.00	1.00	2005-09-13	0
0 	0 	37511819    	YASMIN BARRERA RINCON                   	29	1	1976-04-26	1	CLL 19 No 26-78  SFCO	6594043	68001	1	1	0	2	0	60	2004-09-16	32	2200000	68081	0	51	0.00	1.00	2005-09-30	0
0 	0 	37713601    	SHIRLEY ARIZA                           	29	1	1960-07-10	1	BGA	000-00000	68001	1	1	0	2	0	60	2004-08-30	33	800000	68001	1	51	0.00	1.00	2006-08-28	0
1 	1 	28483971    	CLAUDIA MILENA CASTILLO ZARATE          	17	3	1979-08-04	1	BARRANCA	6224514	68081	1	5	0	2	0	8 	2005-12-19	101	433700	68081	1	52	0.00	1.00	2005-10-22	0
3 	3 	13715183    	JHON JAIME BAREÑO                       	19	1	1978-08-28	2	CARRERA 14 Nø 50-04 FLORIDA	6814185	68276	1	1	0	2	0	60	2008-07-04	35	950000	68001	1	52	0.00	1.00	2005-10-01	0
1 	1 	60397853    	ANGELA MARIA MENESES RUEDA              	17	1	1979-11-16	1	CALLE 52 No 34F-16  BARRANCA	6216916	68081	1	1	0	2	0	60	2004-09-27	37	433700	54001	1	52	0.00	1.00	2005-09-30	0
2 	2 	37901101    	BLANCA LEON GOMEZ                       	17	3	1984-06-12	1	NBJHGJHJGHJ	6486189	68276	1	5	0	2	456456465	8 	2004-06-23	103	461500	68276	1	52	0.00	1.00	2005-06-23	0
2 	2 	91498826    	DANIEL ENRIQUE REMOLINA                 	15	3	1976-05-17	1	mas por menos	6486189	76275	1	5	0	2	545645465	8 	2004-08-30	104	461500	76275	1	52	0.00	1.00	2005-08-30	0
2 	2 	91492813    	JAIRO ALONSO MORENO JARAMILLO           	15	3	1976-10-26	2	njkhjihjih	6486189	68001	1	5	0	2	156465456465	8 	2004-10-14	105	433700	68001	1	52	0.00	1.00	2005-10-14	0
2 	2 	91254980    	WILLIAM RAMIREZ QUINTERO                	12	1	1960-07-16	2	CRA 4 No 1A-08 C. VERDE  BGA	6541612	68547	1	1	0	2	0	60	2010-02-01	40	3000000	68001	0	52	0.00	1.00	2005-10-01	0
7 	7 	91516573    	JOSE DEL CARMEN BARRERA DUARTE          	31	3	1982-12-03	2	FLORIDA	6486189	68001	1	1	0	2	45445	8 	2006-08-01	130	1040000	68001	1	52	0.00	1.00	2006-03-06	0
6 	6 	91539339    	VICTOR  ALFONSO SOLANO GOMEZ            	15	3	1985-05-17	2	SAN FRANCISCO	6320505	68001	1	5	0	2	4542645664	8 	2005-12-06	106	433700	68001	1	52	0.00	1.00	2005-11-08	0
6 	6 	63449128    	GLORIA ADIVI RODRIGUEZ JAIMES           	17	1	1975-03-29	1	BLQ 22-20 APTO 422 SC 19 BUCAR	6483892	68276	1	1	0	2	0	60	2003-10-27	43	433700	68001	1	52	0.00	1.00	2005-12-30	0
9 	9 	13748029    	EDUARD DANILO CAMACHO                   	12	3	1981-01-26	2	DIAG. 105 N¦ 104E -196 PROVENZ	6377507	68001	1	1	0	2	0	60	2004-11-16	44	3000000	15693	0	52	0.00	1.00	2008-06-28	0
0 	0 	91291777    	CRISTIAN ALEXANDER CELY INFANTE         	29	1	1973-06-13	2	MAS X MENOS SFCO	63250505	68001	2	5	0	4	26465456465456	8 	2004-09-13	107	2000000	68001	1	51	0.00	1.00	2005-09-13	\N
3 	3 	91285660    	JORGE LUIS LIZARAZO                     	15	3	1972-05-22	2	MAS X MENOS	6320505	68001	2	5	0	2	64545645456	8 	2004-06-11	108	433700	68001	1	52	0.00	1.00	2005-06-11	0
0 	0 	91298308    	OMAR VILLAMIZAR ANAYA                   	29	1	1974-06-17	2	CLL 15 No 10-50 GAITAN  BGA	6719522	68001	1	1	0	2	0	60	2003-11-24	48	770000	68001	1	51	0.00	1.00	2005-12-24	0
7 	7 	37860600    	MARTHA YOLANDA BARRIOS TORRES           	16	3	1981-05-05	1	FLORIDA	6486189	68001	2	1	0	2	545456456	8 	2005-03-01	131	461500	68001	1	52	0.00	1.00	2006-03-01	0
4 	4 	63537287    	LUZ ARGEIDYZ LOPEZ ROJAS                	17	3	1983-03-17	1	BARRANCA	6206547	68081	2	1	0	2	4654564564	8 	2004-09-10	110	433700	68081	1	52	0.00	1.00	2005-09-10	0
6 	6 	91156190    	FREDY ANTONIO GALEANO PENA              	15	1	1973-07-27	2	CARRERA 16A - 1B -31 BUCARICA	6555354	68001	1	1	0	2	0	60	2003-12-01	49	433700	68001	1	52	0.00	1.00	2005-12-30	0
1 	1 	63555055    	MARCELA PINEDA  GUTIERREZ               	17	3	1984-07-03	2	BARRANCA	6203747	68081	1	5	0	2	151564	8 	2004-11-02	111	461500	68081	1	52	0.00	1.00	2005-11-02	0
5 	5 	5135444     	MANUEL BARRETO RICO                     	15	3	1980-08-27	1	PROVENZA	6312116	68001	1	5	0	2	454545456	8 	2005-11-10	112	496900	68001	1	52	0.00	1.00	2006-11-09	0
3 	3 	19083037    	ORLANDO MEJIA LEON                      	30	3	2005-02-16	1	SAN FRANCISCO	6320505	68001	2	1	0	2	107-	8 	2005-02-16	129	433700	68001	1	52	0.00	1.00	2005-12-30	0
4 	4 	91496381    	EDWIN CIFUENTES YEPES                   	15	3	1980-01-01	2	MASXMENOS	6447300	68081	1	5	0	4	107-	25	2005-01-01	125	433700	68081	1	52	0.00	1.00	2005-12-30	0
0 	0 	19401655    	JESUS CRUZ NAVAS                        	29	1	1960-07-10	2	MASXMENOS	6447300	68001	2	5	2	4	107-	5 	1998-04-27	126	3700000	68001	0	51	0.00	1.00	2005-12-31	0
7 	7 	37860637    	DEICY DURAN GONZALEZ                    	17	1	1981-03-20	1	SFCO	000-00000	68001	1	1	0	2	0	60	2005-06-16	54	433700	68001	1	52	0.00	1.00	2005-12-30	0
0 	0 	91268515    	ROBERT NIÑO RAMIREZ                     	29	1	1960-08-13	2	CRA 12 No 20-06 KENEDY  BGA	6400424	68001	1	1	0	2	0	60	2006-01-10	57	1300000	68001	0	51	0.00	1.00	2010-06-15	0
5 	5 	7175155     	OSCAR JAVIER CORTES MARTINEZ            	15	4	1976-11-25	1	PROVENZA	6312116	68001	1	5	0	2	5454456	8 	2004-11-02	113	433700	68001	1	52	0.00	1.00	2005-11-02	0
8 	8 	63356869    	OLGA LEONOR PEREZ ROSAS                 	12	3	1970-09-26	1	SECT 1 BLOQ 1-3 APTO 501 PROVE	6498846	68276	1	1	0	2	0	60	2010-03-15	59	1800000	68001	1	52	0.00	1.00	2008-06-28	0
7 	7 	63558874    	DAYANA MILENA MARIN                     	17	3	1985-04-09	1	PROVENZA	6312116	68001	1	5	0	2	572752572	25	2006-05-15	114	433700	68001	1	52	0.00	1.00	2007-05-14	0
5 	5 	37724151    	LIBIA  GONZALEZ RODRIGUEZ               	17	3	1978-11-12	1	PROVENZA	6312116	68081	1	5	0	2	4645456	54	2004-08-05	115	433700	68081	1	52	0.00	1.00	2005-08-05	0
5 	5 	63453420    	DIANA CECILIA DAVILA                    	17	1	1983-08-30	1	BLQ 10-10 APTO 502  FLORIDA	6482117	68276	1	1	0	2	0	60	2004-01-22	61	433700	68276	1	52	0.00	1.00	2004-12-31	0
0 	0 	63515530    	BEATRIZ CIFUENTES CARDONA               	29	1	1976-11-07	1	CRA 10AN No 27N-13  SFCO	6409084	68001	1	1	0	2	0	60	2004-01-22	62	700000	5001 	1	51	0.00	1.00	2004-12-20	0
2 	2 	37842126    	SANDY KARINA CARDENAS MOLINA            	17	1	1980-10-14	1	CLL 28 No 7-28  FLORIDA	6383251	68001	1	1	0	2	0	60	2005-01-01	64	433700	68276	1	52	0.00	1.00	2005-01-15	0
4 	4 	28488479    	DEISY JOHANNA FLOREZ GRATERON           	33	1	1981-12-01	1	CALIDAD	000-00000	68081	1	1	0	2	0	60	2005-08-22	67	461500	68081	1	52	0.00	1.00	2004-12-31	0
1 	1 	63537035    	PILAR CRISTINA GALVIS JIMENEZ           	17	1	1983-03-10	1	CALIDAD	000-00000	68081	1	1	0	2	0	60	2004-02-01	66	433700	68081	1	52	0.00	1.00	2005-01-30	0
7 	7 	91448836    	JUVENAL GONZALEZ RICO                   	15	1	1977-11-21	2	CALIDAD	000-00000	68081	1	1	0	2	0	60	2009-05-01	65	535600	68081	1	52	0.00	1.00	2007-02-21	0
10	10	63500025    	YOLANDA VERGARA RIVERA                  	18	3	1974-12-21	1	PROVENZA	6312116	68001	1	5	0	2	46545456	8 	2009-07-16	116	1400000	68001	0	52	0.00	1.00	2007-05-21	0
3 	3 	63490704    	CLAUDIA PATRICIA TRUJILLO BRICEÑO       	17	3	1973-10-13	1	PROVENZA	6312116	68001	3	5	0	2	465546546	54	2005-01-11	117	433700	68001	1	52	0.00	1.00	2005-12-11	0
0 	0 	37512985    	CARMEN YOLANDA DELGADO AYALA            	29	1	1977-06-06	1	BGA	000-00000	68001	0	1	0	2	0	60	2004-02-02	69	2500000	68001	1	51	0.00	1.00	2004-08-30	0
6 	6 	13748669    	PABLO JOSE SANCHEZ SANCHEZ              	15	1	1980-04-20	2	PROVENZA	000-00000	68001	1	1	0	2	0	60	2005-02-01	71	433700	68001	1	52	0.00	1.00	2005-12-30	0
5 	5 	5478370     	ALEXANDER PARADA RIVERA                 	15	3	1979-07-08	2	PROVENZA	6312116	68001	1	5	0	2	588585	8 	2005-01-14	118	433700	68001	1	52	0.00	1.00	2006-01-14	0
0 	0 	37706049    	LUZ STELLA CRUZ NAVAS                   	29	1	1968-04-29	1	masxmenos	6447300	68001	2	5	0	4	0	5 	2015-02-03	119	6600000	68001	0	51	0.00	1.00	2005-12-30	0
0 	0 	91490791    	JONH EDUARDO QUINTERO SANTOS            	29	1	1960-07-10	2	BGA	000-00000	68001	1	1	0	2	0	60	2004-02-11	74	800000	68001	1	51	0.00	1.00	2005-02-11	0
0 	0 	63352218    	SMITH PATRICIA CARREÑO                  	29	1	1969-03-23	1	BGA	000-00000	68001	1	1	0	2	0	60	2004-02-16	75	1100000	68001	1	51	0.00	1.00	2006-12-30	0
2 	2 	63453396    	CLAUDIA PATRICIA RINCON PE¥A            	17	1	1983-11-11	1	CRA 13 No 7-38  SFCO	6485310	68276	1	1	0	2	0	60	2004-02-23	76	433700	68276	1	52	0.00	1.00	2004-12-31	0
2 	2 	63528743    	LISBETH GONZALEZ LOPEZ                  	17	1	1982-05-20	1	CRA 28B No 95-31  FLORIDA	6496028	68276	1	1	0	2	0	60	2004-02-24	78	433700	68081	1	52	0.00	1.00	2005-02-24	0
6 	6 	63450554    	OMAIRA REY ROJAS                        	17	3	1979-10-29	1	SAN FRANCISCO	6320505	68001	2	1	0	2	0	8 	2005-02-02	122	433700	68001	1	52	0.00	1.00	2005-12-30	0
5 	5 	91275118    	CARLOS MANUEL TORRES PICO               	19	1	1970-12-02	2	CLL 4 No 12-16 NUEV VILLAB FLO	6380618 -	68001	1	1	0	2	0	60	2006-01-23	80	1100000	68679	1	52	0.00	1.00	2007-01-22	0
5 	5 	63557885    	LADY PAOLA URIBE RODRIGUEZ              	17	3	1985-01-28	1	asdmkadklkadlk	6447300	68001	2	1	0	5	456456465	8 	2007-05-23	240	461500	68001	1	52	0.00	1.00	2008-05-23	0
2 	2 	63536351    	LUDY DUARTE GUERRERO                    	17	1	1982-11-13	1	CLL 8 No 8-32  FLORIDA	6826803	68276	1	1	0	2	0	60	2004-03-23	81	433700	68276	1	52	0.00	1.00	2005-03-15	0
1 	1 	28070443    	MIRLEY BAHAMON MEDEL                    	17	3	1980-05-25	1	COLOMBIA	6203547	68001	2	1	0	2	125456	8 	2005-02-01	123	433700	68001	1	52	0.00	1.00	2005-12-30	0
1 	1 	28061158    	DORIS YADIRA MAYORAL ALVAREZ            	17	3	1981-02-09	1	BARRANCA	6224514	68001	1	1	0	2	0	8 	2006-03-27	124	433700	68001	1	52	0.00	1.00	2007-03-26	0
2 	2 	60370364    	BLANCA ISABEL SANABRIA                  	17	1	1975-11-21	1	BUCARICA	000-00000	68276	1	1	0	2	0	60	2004-03-31	85	433700	68001	1	52	0.00	1.00	2006-05-15	0
2 	2 	5654487     	RAUL ANDRES GARCES PAEZ                 	15	1	1983-12-17	2	PROVENZA	000-00000	68001	1	1	0	2	0	60	2004-04-01	86	433700	68001	1	52	0.00	1.00	2005-04-01	0
6 	6 	37547571    	ADRIANA CHAPARRO AZA                    	17	3	1980-01-01	1	MASXMENOS	6447300	68001	1	5	0	2	107-	5 	2005-01-17	127	433700	68001	1	52	0.00	1.00	2005-12-01	0
0 	0 	63367541    	EDDY ROSMARY REATIGA RIVERA             	29	1	1980-01-01	1	MASXMENOS	6447300	68001	1	5	0	4	107-	5 	2004-09-28	128	680000	68001	1	51	0.00	1.00	2005-12-31	0
2 	2 	13747758    	WILLIAM GIOVANNY VILLAMIZAR             	15	3	1980-12-28	2	MXM	6447300	68001	2	5	0	2	107-	5 	2006-06-21	121	433700	68001	1	52	0.00	1.00	2006-12-20	0
4 	4 	91439589    	JOSE EVELIO DIAZ GUEVARA                	15	1	1971-12-16	2	CLL52 No 36B-101   BARRANCA	6219016	68081	1	1	0	2	0	60	2004-02-24	91	433700	68081	1	52	0.00	1.00	2005-04-30	0
6 	6 	28054669    	LEIDY MARIANA BLANCO                    	17	3	1980-05-26	1	PROVENZA	6312116	68001	1	1	0	2	46548545645	8 	2005-03-23	132	433700	68001	1	52	0.00	1.00	2005-03-23	0
2 	2 	13511029    	ANTONIO ROBLES HERNANDEZ                	15	1	1977-11-20	2	FLORIDA	000-00000	68276	1	1	0	2	0	60	2004-04-26	92	433700	68001	1	52	0.00	1.00	2004-12-30	0
12	12	93377960    	MIGUEL ANTONIO RAMOS SIERRA             	12	1	1969-12-11	2	BLOQUE 5 -3 APTO 201  FLORIDA	6483054	68276	1	1	0	2	0	60	2014-01-13	93	2600000	73001	0	52	0.00	1.00	2005-04-30	0
5 	5 	91181376    	ELKIN HELI CHARRIS DAVILIA              	31	1	1978-09-07	2	CRA 22 No 103-17  PROVENZA	6466148	68001	1	1	0	2	0	60	2004-05-10	94	550000	68001	1	52	0.00	1.00	2005-05-15	0
1 	1 	37844980    	MARITZA LUCIA HERAZO AMARIS             	20	1	1981-05-31	1	BARRANCA	000-00000	68081	1	1	0	2	0	60	2004-05-13	95	680000	68001	1	52	0.00	1.00	2005-03-30	0
2 	2 	37620613    	YENY CARELY RUEDA                       	17	3	1985-09-26	1	FLORIDA	6486189	68001	1	1	0	2	454564654	8 	2005-04-02	133	433700	68001	1	52	0.00	1.00	2005-12-30	0
3 	3 	91351364    	LUIS ERNESTO RAMIREZ ARANDA             	15	3	1979-05-20	1	SAN FRANCISCO	6320505	68001	2	1	0	5	5454546	8 	2005-04-18	135	433700	68001	1	52	0.00	1.00	2005-12-30	0
5 	5 	63450613    	MARTHA MEJIA MANTILLA                   	16	1	1979-11-13	1	CRA.42 Nø 88-63  FLORIDA	6487328	68276	1	1	0	2	0	60	2004-05-17	97	433700	68001	1	52	0.00	1.00	2005-04-01	0
2 	2 	1095789279  	JHON JAIRO BUITRAGO GARCIA              	15	3	1986-09-26	2	FLORIDA	6320505	68001	1	1	0	5	4545465	8 	2006-09-18	136	433700	68001	1	52	0.00	1.00	2005-12-30	0
6 	6 	91507076    	LUIS FERNANDO VELEZ MEZA                	15	3	1981-12-25	2	BUCARICA	6496724	68001	2	1	0	5	454554	8 	2005-04-06	134	433700	68001	1	52	0.00	1.00	2005-12-30	0
4 	4 	91538911    	RODRIGUEZ MORENO EDINSSON MAURICIO      	32	3	1981-05-10	2	BARRANCA	6203547	68001	2	1	0	2	5828757857	8 	2004-01-02	137	650000	68001	1	52	0.00	1.00	2005-12-08	0
2 	2 	63529727    	MARIA DEL CARMEN SANDOVAL               	17	3	1982-03-04	1	FLORIDA	6486189	68001	2	1	0	2	454845465	8 	2005-05-16	138	433700	68001	1	52	0.00	1.00	2005-06-15	0
3 	3 	91506135    	EDWIN GONZALO URIBE ORTIZ               	15	3	1981-12-17	2	PROVENZA	6312116	68001	2	1	0	2	45456456465	8 	2005-05-16	139	433700	68001	1	52	0.00	1.00	2005-12-30	0
6 	6 	32930622    	MARIA ALEJANDRA ACOSTA CAMPO            	17	3	1982-12-13	1	FLORIDABLANCA	6486189	68001	2	1	0	2	46546546	40	2005-06-24	144	461500	68001	1	52	0.00	1.00	2006-06-24	0
5 	5 	13716095    	JOAN MARCELLO MENESES GOMEZ             	15	3	1978-12-28	2	FLORIDA	6486189	68001	1	1	0	2	1552454	8 	2005-07-21	146	461500	68001	1	52	0.00	1.00	2005-12-31	0
5 	5 	37861455    	SILVIA JULIANA CORREDOR RODRIGUEZ       	17	3	1980-05-28	1	PROVENZA	6312116	68001	2	1	0	2	1524646462	8 	2005-08-11	148	433700	68001	1	52	0.00	1.00	2005-12-31	0
5 	5 	91530620    	EDDINSON  EDUARDO VILLAMIZAR FLOREZ     	15	3	1983-10-16	1	CLLE 70  N 44W-156	6447300	68001	1	1	0	2	15622445	8 	2005-08-25	149	433700	68001	1	52	0.00	1.00	2005-11-30	0
4 	4 	63492700    	SANDRA PATRICIA  AMAYA RAMIREZ          	12	1	1973-12-20	2	clle 70 n. 44w-156 km 04	6447300	68001	1	1	0	2	1544446	8 	2005-08-16	150	1200000	68001	1	52	0.00	1.00	2005-12-31	0
3 	3 	63543718    	YENNY RAMIREZ                           	17	3	1983-10-16	1	clle 70 n. 44ww-156	6447300	68001	1	1	0	2	15822532	25	2005-08-25	151	461500	68001	1	52	0.00	1.00	2005-12-31	0
4 	4 	13569008    	DANIEL BARBA DIAZ                       	22	3	1984-06-07	2	BARRBCA	6203547	68081	1	1	0	2	4545454	8 	2005-06-07	140	461500	68001	1	52	0.00	1.00	2005-12-30	0
6 	6 	91159649    	FERNANDO RAMIREZ TORRES                 	15	3	1981-03-30	2	PROVENZA	6447300	68001	2	1	0	5	45454	8 	2005-09-12	153	461500	68001	1	52	0.00	1.00	2005-12-31	0
4 	4 	37754614    	KELLY JOHANNA DURAN LOPEZ               	17	3	1980-10-25	1	BARRANCA	6203547	68081	1	1	0	2	578578787	40	2005-10-19	154	461500	68081	1	52	0.00	1.00	2006-02-18	0
6 	6 	91529373    	FERNEY DAVIAN SANTIESTEBAN JIMENEZ      	34	3	1984-04-11	2	MAS X MENOS SFCO	6320505	68001	1	1	0	2	2212333	40	2005-10-26	155	680000	68001	1	52	0.00	1.00	2006-02-25	0
7 	7 	1018407453  	GREIS CAROLINA SABIO BARRERA            	14	3	1986-12-07	1	PROVENZA	6312116	68001	1	1	0	2	545754567	8 	2007-04-16	145	650000	68001	1	52	0.00	1.00	2006-12-31	0
0 	0 	28152971    	ZAIDA JOHANNA ARCINIEGAS BUSTOS         	29	1	1980-11-06	1	cr 40no.107-17  B. SANTA FE	6492892	68276	1	1	0	3	7878787	40	2005-10-27	156	500000	68276	1	51	0.00	1.00	2006-02-26	0
2 	2 	28469373    	DORA NATHALIA BUENAHORA HERNANDEZ       	18	3	1972-11-12	1	PROVENZA	6312116	68001	2	1	0	5	45465654	5 	2010-03-30	160	1400000	68001	0	52	0.00	1.00	2006-12-30	0
2 	2 	63530843    	YUDDY ARLET RODRIGUEZ  HERNANDEZ        	17	3	1982-08-09	1	PROVENZA	6312116	68001	2	1	0	2	465756454654	8 	2005-08-11	147	433700	68001	1	52	0.00	1.00	2005-12-31	0
1 	1 	63469377    	MARIA EUGENIA BURITICA RODRIGUEZ        	17	3	1980-07-18	1	DIA 58A NO 50-57	6103599	68081	2	1	0	4	13809601	5 	2005-12-20	161	461500	50110	1	52	0.00	1.00	2006-04-19	0
6 	6 	1098628333  	ANGIE CATHERYN CADENA RANGEL            	17	3	1986-10-25	1	calle 39 N. 6 - 1E	6848916	68276	1	1	0	2	5555	40	2006-01-17	163	433700	68276	1	52	0.00	1.00	2006-05-16	0
4 	4 	63555693    	DIANA CAROLINA LLANES MIRA              	17	3	2004-11-23	1	TRANSV21NO. 62-24 B.BUENAVISTA	6204403	68081	0	1	0	3	123133	5 	2006-09-11	164	515000	68081	1	52	0.00	1.00	2006-07-17	0
1 	1 	63469467    	OLINDA ALVAREZ QUINTERO                 	17	3	2004-01-27	1	TRANSV46NO. 49-48 B.LAS GRANJAS	6023173	68081	1	1	0	2	31313	5 	2006-02-01	165	461500	68081	1	52	0.00	1.00	2007-01-30	0
0 	0 	72186842    	7                                       	29	1	2004-02-22	2	CLL 41 NO. 38-65 APT 1203 CABECERA	6345736	68001	4	1	0	6	2121	5 	2006-02-01	166	433700	68001	1	51	0.00	1.00	2007-05-10	0
3 	3 	37619853    	LEIDY CAROLINA HERNANDEZ FLOREZ         	17	3	2004-09-30	1	KRA 7 NO.12-75 CANDELARIA/PIEDECUESTA	6541306	68547	1	1	0	3	1223	5 	2006-02-10	167	461500	68001	1	52	0.00	1.00	2007-02-09	0
2 	2 	60392434    	LIZETH BIBIANA AMAYA SILVA              	17	3	2006-02-01	1	CRA9ANO. 8-60 CASA 201 Urbn COVI FLORIDA	6496798	68276	2	1	0	2	15454	5 	2006-02-01	168	433700	68547	1	52	0.00	1.00	2007-01-31	0
6 	6 	28229154    	YOLANDA MILENA LOZANO SIERRA            	16	3	1981-04-03	1	CRA15NO.1N-31 SAN CARLOS * PIEDECUESTA	6564632	68547	1	1	0	2	5454	5 	2007-06-25	169	461500	68425	1	52	0.00	1.00	2007-07-02	0
2 	2 	91510591    	DIDIER FERNANDO DUARTE MORERA           	15	3	1982-06-26	2	PROVENZA	63121116	68001	2	1	0	5	144454	8 	2005-09-01	152	433700	68001	1	52	0.00	1.00	2005-12-31	0
6 	6 	13510263    	LINARCO OCHOA JAIMES                    	34	4	1977-03-28	2	KRA18NO.57-47 EL PALENQUE	6464779	68307	1	1	0	2	2121	8 	2006-02-01	170	433700	68547	1	52	0.00	1.00	2007-01-31	0
2 	2 	63548230    	YESENIA GALEANO MONTERO                 	17	3	1984-03-20	1	FLORIDA	6486189	68001	2	1	1	2	1325413	8 	2006-03-13	178	433700	68001	1	52	0.00	1.00	2007-03-12	0
9 	9 	1098698490  	ANGIE LIZETH DURAN CARDONA              	17	3	1990-12-20	1	CALLE 60 N° 8w-160	6440515	68001	2	5	1	2	252525	8 	2012-02-14	701	566700	68081	1	52	1.00	1.00	2013-02-13	0
0 	0 	1098627914  	FRANCY HELENA SEPULVEDA NAVAS           	29	1	1985-12-05	1	CLL 14B N.19A-57 CONSUELO - GIRON	6999863	68307	1	1	1	3	2	95	2013-01-16	159	1200000	68001	0	51	1.00	1.00	2006-01-31	0
0 	0 	91255369    	ALBERTO BERNARDO ROSAS TIBANA           	29	1	2004-05-10	2	FKSFLKSFJ	6312548	68001	2	1	0	5	414545	8 	2006-01-05	162	700000	68001	1	51	0.00	1.00	2006-12-31	0
6 	6 	49670761    	BEYXI CAROLINA VALERO MANTILLA          	17	3	1983-02-07	1	CRA 40 NO. 107-15 B.SANTA FE	6492892	68001	1	1	0	3	212211	8 	2006-02-16	173	433700	20011	1	52	0.00	1.00	2006-06-15	0
1 	1 	91443589    	LUIS CARLOS ACUÑA CANTILLO              	15	3	1974-05-02	2	BARRANCA	6224514	68001	1	5	0	2	4545464	25	2005-06-17	141	433700	68001	1	52	0.00	1.00	2006-06-17	0
1 	1 	1096188092  	MONICA PLATA LOPEZ                      	17	3	1987-03-28	1	BARRANCA	6224514	68001	1	1	0	2	44456	8 	2005-06-17	142	433700	68001	1	52	0.00	1.00	2006-06-17	0
5 	5 	63508772    	ROCIO DEL PILAR ACEVEDO RAMIREZ         	17	3	1976-01-19	1	BUCARAMANGA	6312116	68001	1	1	0	2	445456465	5 	2005-06-22	143	433700	68001	1	52	0.00	1.00	2006-06-22	0
7 	7 	37862621    	JOHANA LOPEZ LIEVANO                    	17	3	1980-11-14	1	CLL 106 N. 50-33 B.SANTA HELENA	6771390	68001	3	1	1	2	1	95	2005-12-03	157	461500	68655	1	52	0.00	1.00	2006-12-02	\N
0 	0 	13723560    	EDUARDO NOVOA CORDOBA                   	29	1	1979-11-29	2	CALLE 14B No 19 A 57	6475890	68001	1	1	0	6	4545617	8 	2006-03-27	179	1100000	68001	1	51	0.00	1.00	2007-03-26	0
0 	0 	37545990    	JANNETH BALAGUERA MELENDEZ              	29	1	1977-07-14	1	CRA 20 NO 50-16	6590899	68001	1	2	0	5	124546	8 	2007-10-01	180	3700000	68001	0	51	0.00	1.00	2007-03-15	0
3 	3 	1098624150  	JESUS FERNANDO MARTINEZ SERRANO         	15	1	1986-06-25	2	CLL 44 NO 31-125	6328526	68001	1	1	0	4	6523	8 	2006-06-01	183	461500	68001	1	52	0.00	1.00	2007-11-05	0
6 	6 	13513313    	FAVIO RENE RODRIGUEZ ARDILA             	15	1	1977-07-25	2	CRA 40 N0 32-165	6532841	68001	1	1	0	1	4546565	40	2006-06-01	184	433700	68001	1	51	0.00	1.00	2007-05-31	0
4 	4 	13568755    	JULIAN ANDRES BOLIVAR VELASQUEZ         	15	1	1984-08-08	2	CALLE 14 B NO 13-52	6200527	68081	1	1	0	2	12161032	8 	2006-07-27	186	433700	68081	1	52	0.00	1.00	2008-12-06	0
5 	5 	63539644    	NANCY JANETH GOMEZ CARREÑO              	17	3	1983-06-19	1	CARRERA 2E No 29b-4  APTO 102	3156207806	68001	1	1	0	2	54131541	8 	2006-08-01	187	461500	68001	1	52	0.00	1.00	2007-07-31	0
2 	2 	13870136    	ELIAN DARIO QUINTERO VARGAS             	14	1	1981-03-30	2	CLL 70 No 44W-156 KM 4 VIA GIRON	6447330	68001	1	1	0	4	4454151	8 	2006-08-26	188	550000	68001	1	52	0.00	1.00	2007-08-25	0
0 	0 	13923777    	MIGUEL ANGEL LOZANO CASTELLANOS         	29	1	1966-04-17	2	CRA 23 No 11-50 MGKFG	441254	68001	2	1	0	5	321123	8 	2012-02-24	189	2000000	68001	1	51	0.00	1.00	2007-08-13	0
0 	0 	91521135    	NELSON IVAN AYALA BERNAL                	29	1	1983-07-11	2	FNSDFN.FDÇS	2	323  	1	1	0	4	1415616	8 	2007-01-04	190	433700	68001	1	51	0.00	1.00	2007-08-17	0
4 	4 	85166757    	ALVARO SAUCEDO CADENA                   	20	1	1978-09-29	2	MSADFKBVFDG	545522	68001	1	1	0	2	415413	8 	2011-01-04	191	1250000	68001	1	52	0.00	1.00	2007-08-14	0
4 	4 	13851597    	JUAN  DE JESUS URREA FERREIRA           	15	3	1980-06-03	2	VEREDA CAMPO 6 POZO No 432	6222362	68081	2	1	1	2	4313244	8 	2006-04-26	181	461500	68081	1	52	0.00	1.00	2007-04-25	0
2 	2 	13746377    	JAIME JULIAN CARREÑO GOMEZ              	15	1	1980-12-02	2	CLL 15 No 13-56	63256587	68001	1	1	0	4	4545644546	5 	2006-09-07	192	433700	68001	1	52	0.00	1.00	2007-09-06	0
7 	7 	63552136    	CLAUDIA PATRICIA DUARTE VARGAS          	17	1	1984-03-20	1	CLEE JFKSDFLFKSFSAÑ	6738930	68001	1	1	0	2	54541564151	8 	2007-01-04	198	433700	68001	1	52	0.00	1.00	2007-10-20	0
6 	6 	91507249    	OSCAR MAURICIO PANQUEVA ANGEL           	15	1	1982-01-14	2	CDSJKFNJSFL	6811735	68001	3	1	0	2	11221326	8 	2006-11-17	199	461500	68001	1	52	0.00	1.00	2007-11-16	0
3 	3 	37747992    	YESENIA PARDO HERNANDEZ                 	17	1	1980-01-28	1	Adbshfksdb6511	44655	68001	1	1	0	2	456156	8 	2006-12-22	203	433700	68001	1	52	0.00	1.00	2007-12-21	0
5 	5 	13720321    	WILLIAM RODOLFO MENDOZA QUIÑONEZ        	15	3	1979-04-05	2	SDAKF SDFWGFPA8+55267	565634345	68001	1	1	0	2	465213254	8 	2007-01-03	204	433700	68001	1	52	0.00	1.00	2007-12-02	0
6 	6 	63558879    	YURANY  MUÑOZ DUARTE                    	17	1	1985-02-15	1	CLL 70 NO 44W 165	6447535	68001	1	1	0	2	416532	8 	2006-06-16	185	433700	68001	1	52	0.00	1.00	2007-06-15	0
7 	7 	1098663763  	YURI KARINA BUENO RONDON                	16	3	1988-12-30	1	gjhjkhhjk	6496724	68001	2	1	0	5	45454	8 	2007-01-04	206	496900	68001	1	52	0.00	1.00	2008-01-03	0
2 	2 	55231658    	DAYANA PATRICIA MIRANDA OTERO           	17	3	1985-12-05	1	CKDSHKFDKSP´GHLFGHBÉ	524165565	68001	2	1	0	5	4455465	8 	2007-02-10	212	461500	68001	1	52	0.00	1.00	2007-12-30	0
2 	2 	1098638837  	LESLIE JULIET NAVARRO RODRIGUEZ         	17	3	1987-07-14	1	CALLE 19 No 11B -57 ROSALES	6799477	68001	1	1	0	2	4565332	8 	2007-02-21	214	433700	68001	1	52	0.00	1.00	2007-12-30	0
2 	2 	37559749    	CONSUELO ARIAS GONZALEZ                 	17	3	1978-08-02	1	CL 204DnO. BI40-42 LOS ANDRES	6827135	68276	1	1	0	2	545454	8 	2006-02-16	171	433700	68001	1	52	0.00	1.00	2006-06-15	0
2 	2 	52999599    	ERIKA YADIRA DELGADO PINTO              	17	3	1984-12-28	1	FLORIDABLANCA	6447300	68276	1	1	0	4	212121	8 	2006-02-01	172	515000	1001 	1	51	0.00	1.00	2006-12-31	0
0 	0 	63547471    	DIANA PATRICIA VARON PINZON             	29	1	1984-02-23	1	CALLE 104C No 12º - 09 MANUELA BELTRAN	6376261	68001	1	1	0	4	4154531	8 	2007-02-23	215	680000	68001	1	51	0.00	1.00	2007-12-30	0
0 	0 	63345846    	SONIA MEZA DUARTE                       	29	1	1998-02-13	1	JDKAJDJAD	6447300	68001	2	1	0	5	444465465	8 	2007-03-12	218	1000000	5002 	1	51	0.00	1.00	2008-03-11	0
2 	2 	91296346    	JAVIER HUMBERTO VIVIESCAS ALMEIDA       	33	3	1973-05-18	2	JDKLAJDKLJALKD	64545445	76100	2	1	0	5	546565	8 	2009-07-04	219	515000	5002 	1	52	0.00	1.00	2008-03-10	0
6 	6 	13716907    	JAIME ALEXANDER SILVA RAMIREZ           	15	3	1979-02-12	2	KALFKAKF	6447300	68001	2	1	0	5	454654	8 	2007-03-08	220	433700	68001	1	52	0.00	1.00	2008-03-08	0
2 	2 	1095789794  	MILENA ROCIO RINCON GONZALEZ            	17	1	1986-02-24	1	CARRERA 15 No 15-35	5415612	68001	2	1	0	5	4511156	8 	2006-09-20	194	433700	68001	1	52	0.00	1.00	2007-09-19	0
1 	1 	28061454    	BRINY LUCIA DONADO ARIZA                	17	1	1981-11-15	1	VDHJFFKFSJDF,A	4453225	68081	2	1	0	5	2311210231	8 	2006-09-27	195	433700	68081	1	52	0.00	1.00	2007-09-26	0
0 	0 	91178722    	JUAN PABLO VILLAMIZAR                   	29	1	1972-01-25	1	sec 17 bloq 3-8 apt 101 ALTO BELLAVISTA	6371571	68001	2	1	0	3	221212	8 	2006-02-16	174	1300000	68307	1	51	0.00	1.00	2007-02-15	0
2 	2 	63551140    	ELIZABETH DAVILA CASTAÑO                	17	3	1983-10-04	1	APT 402 SECTOR 9 TORRE13-11 BUCARICA	6497866	68001	1	1	0	2	32323	8 	2006-02-13	175	433700	5411 	1	52	0.00	1.00	2006-06-12	0
4 	4 	63463080    	ERNESTINA SERRANO MARTINEZ              	17	3	1974-01-15	1	CRA 42 NO. 29-30 EL CERRO	6107637	68081	3	1	0	2	322311	8 	2010-09-23	176	515000	68081	1	52	0.00	1.00	2006-06-16	0
4 	4 	37576793    	LELYS TATIANA ORTIZ                     	17	3	1983-07-05	1	CLL 56 NO. 32-06	6112444	68081	1	1	0	2	123	8 	2006-02-17	177	433700	68081	1	52	0.00	1.00	2006-06-16	0
1 	1 	63468914    	YOLIMA QUINTERO BOHORQUEZ               	17	1	1976-08-01	1	DFJWHSAHFA	6105221	68081	2	1	0	2	2355232	5 	2006-12-11	200	496900	68081	1	52	0.00	1.00	2007-12-10	0
6 	6 	91521051    	JHONATAN ADOLFO RAMIREZ PATIÑO          	15	1	1983-07-25	2	JFGGJSD112	654113	68001	3	1	0	2	54135645	8 	2006-12-02	201	433700	68001	1	52	0.00	1.00	2007-12-01	0
8 	8 	91539129    	MIGUEL OSWALDO  PALOMINO RIVERA         	13	3	1985-03-16	2	hfashfjah	6486189	68001	2	1	0	5	45465465	8 	2007-01-13	205	650000	76111	1	52	0.00	1.00	2008-01-12	0
1 	1 	1096188581  	VLADIMIR ROJAS CONTRERAS                	15	3	1987-01-19	2	R EWKRWEHPTFG4WSºº	56464	68081	2	1	0	2	234114	8 	2007-02-05	213	461500	68001	1	52	0.00	1.00	2007-12-31	0
4 	4 	1096191526  	ANGIE MARIA ARDILA DE LA ROCA           	17	1	1987-05-25	1	CRA 34 No 027 LA TORA	602249	68001	2	1	0	1	145645	8 	2007-02-17	217	433700	68001	1	52	0.00	1.00	2007-12-31	0
7 	7 	63549716    	MARIA JASZMIN ARIAS JAIMES              	17	1	1984-04-21	1	FKEAGMDN21541	5232532	68001	1	1	0	2	45653	8 	2006-12-02	202	461500	68001	1	52	0.00	1.00	2007-12-01	0
5 	5 	13721261    	WALTER ALIRIO MEZA SUAREZ               	15	1	1978-10-13	2	SDFGDGBDFGFS	6447300	68001	2	1	2	4	42122	32	2006-09-13	193	433700	68001	1	52	0.00	1.00	2007-09-06	0
1 	1 	13852434    	RAMIRO VARGAS MEJIA                     	15	3	2004-08-16	2	ADJADKLJA	6447300	68001	2	1	0	5	4564654	8 	2007-03-05	221	433700	68001	1	52	0.00	1.00	2008-03-08	0
7 	7 	49673581    	ROSSANA NORIEGA RINCON                  	39	3	2004-05-10	1	aiojsIOJDOIjdo	6447300	68001	2	1	0	5	5465464	8 	2008-01-15	222	496900	68001	1	52	0.00	1.00	2008-03-04	0
4 	4 	63467719    	FLOR ALBA GOMEZ                         	12	1	1975-11-03	1	CRA 11A No. 50-19 BUCARICA	6492726	68276	1	1	0	2	0	60	2004-03-23	82	3000000	68001	0	52	0.00	1.00	2005-03-15	0
6 	6 	1098619620  	GERSON ALBERTO SANCHEZ ROJAS            	15	3	1986-08-04	2	FLORIDA	6486189	68001	2	1	0	5	4564564	8 	2007-04-12	230	433700	68001	1	52	0.00	1.00	2008-04-11	0
0 	0 	63348401    	ELVA  CARRILLO CARRILLO                 	29	1	1966-09-24	1	DKALDKALK	6447300	68001	2	1	0	5	5454	8 	2015-01-30	231	900000	68001	0	51	1.00	1.00	2008-04-01	0
2 	2 	1098616828  	JENNY ALEXA CARVAJAL FLOREZ             	17	3	1986-06-17	1	salkdlaskjdlk	6486189	68001	2	1	0	5	4545644	8 	2007-04-04	232	433700	68001	1	52	0.00	1.00	2008-04-02	0
0 	0 	28214958    	MIREYA GOYENECHE UMAÑA                  	29	1	1981-04-01	1	DKLADKLAKD	6447300	68001	2	1	0	5	45465465	8 	2008-07-21	235	700000	68001	1	51	0.00	1.00	2008-05-02	0
0 	0 	13842089    	JORGE ENRIQUE DELGADO DUARTE            	29	1	1957-03-14	2	sdaskdakdlka	6447300	68001	2	1	0	5	132123123	8 	2015-02-03	236	6600000	68001	0	51	0.00	1.00	2008-05-01	0
2 	2 	1102354811  	MARDY LILIANA CAMACHO CAMACHO           	17	3	1988-01-20	1	DASD,ASDÑLAWK	6447300	68001	2	1	0	5	4545454	8 	2007-05-04	237	433700	68001	1	52	0.00	1.00	2008-05-04	0
7 	7 	1098605503  	EDINSON AQUILES SANTIESTEBAN JIMENEZ    	15	3	1985-10-15	2	aldklakdl	6447300	68001	2	1	0	5	4564564	8 	2007-05-10	238	461500	68001	1	52	0.00	1.00	2008-05-10	0
1 	1 	1096194924  	TEODOLINDA PINILLA CESPEDES             	20	3	1988-04-09	1	ajdkajkdjakl	6447300	68001	2	1	0	5	456456465	8 	2007-05-21	241	1700000	68001	0	52	0.00	1.00	2008-05-20	0
3 	3 	37861494    	ZAYRA SMITH BARRERA RAMIREZ             	17	3	1981-06-23	1	kdkadklakdñl	6447300	68001	2	1	0	5	5465465465	8 	2007-05-17	242	461500	68001	1	52	0.00	1.00	2008-05-16	0
0 	0 	91110988    	FABIAN AUGUSTO VARGAS NIETO             	29	1	1981-08-12	2	NADJAJDKAJ	6447300	68001	2	1	0	5	4454	8 	2007-03-26	223	450000	68001	1	51	0.00	1.00	2008-03-25	0
4 	4 	28488891    	LEONOR MARIA QUIÑONEZ SERRANO           	17	3	1980-11-22	1	KDLAKDLAK	6447300	68001	2	1	0	5	4545465	8 	2007-03-29	224	461500	68001	1	52	0.00	1.00	2008-03-28	0
6 	6 	1098604867  	JESUS ALBERTO MARTINEZ SERRANO          	15	3	1985-08-12	2	ALDLADK	6447300	68001	2	1	0	5	545454	8 	2007-03-28	225	433700	68001	1	52	0.00	1.00	2008-03-27	0
7 	7 	91508420    	JAIME ENRIQUE HERNANDEZ LUQUE           	15	3	1982-01-22	2	ALÑDLADKKA	6447300	68001	2	1	0	5	47564564	8 	2007-03-28	226	461500	68001	1	52	0.00	1.00	2008-03-27	0
2 	2 	1100502291  	LAURA MILENA CASTAÑEDA PEÑALOZA         	40	3	1988-05-05	1	ADLALDLLA	6447300	68001	2	1	0	5	54564564	8 	2010-10-10	227	515000	68001	1	52	0.00	1.00	2007-03-21	0
2 	2 	1098628055  	YENNIFER XIOMARA RUEDA GOMEZ            	17	3	1986-12-10	1	KLAJDKJAJD	6447300	68001	2	1	0	5	545454	8 	2007-03-20	228	433700	68001	1	52	0.00	1.00	2008-03-19	0
4 	4 	13540348    	MARIO TORRES SUAREZ                     	15	3	1978-02-09	2	KALKLASDKLADK	6447300	68001	2	1	0	5	1445445	8 	2007-03-17	229	433700	68001	1	52	0.00	1.00	2008-03-16	0
4 	4 	13571135    	ANDRES HUMBERTO RUEDA TOLOZA            	15	3	1985-11-20	2	KDALKDKAÑLDK	647300	68001	2	1	0	5	54544654654	8 	2007-05-16	243	433700	68001	1	52	0.00	1.00	2008-05-15	0
4 	4 	13569984    	CESAR AUGUSTO BARBOSA PINEDA            	15	3	1984-11-01	2	ALDKLAKDK	6447300	68001	2	1	0	5	5454556	8 	2007-05-16	244	496900	68001	1	52	0.00	1.00	2008-05-15	0
1 	1 	1096196379  	ANDREA MARCELA AVILA LONDOÑO            	17	3	1988-06-17	1	ADKMAKDKLAKD	6447300	68001	2	1	0	5	45454564	8 	2007-06-16	245	433700	68001	1	52	0.00	1.00	2007-06-16	0
6 	6 	13721826    	ERICK GIOVANNY PUENTES CASTILLO         	13	3	1979-07-13	2	DAPODPAOD	6320505	68001	2	1	0	5	44546	8 	2007-06-19	246	650000	68001	1	52	0.00	1.00	2008-06-18	0
3 	3 	1098609635  	VICTOR JULIO ARIAS JAIMES               	15	3	1986-03-01	2	ASDJASJDK	6486189	68001	2	1	0	5	454654654	8 	2007-06-16	247	496900	68001	1	52	0.00	1.00	2008-06-18	0
2 	2 	63541032    	GLORIA JOHANNA PEDRAZA SIZA             	17	3	1983-07-24	1	DJJMAKDLAK	6320505	19110	2	1	0	5	46546546	8 	2007-07-06	248	433700	68001	1	52	0.00	1.00	2008-07-01	0
4 	4 	43974768    	SILVIA SANDOVAL MEJIA                   	17	3	1984-06-18	1	ADJKLJDAJD	6203547	68081	1	1	0	5	4654455	8 	2011-07-02	249	566700	68081	1	52	1.00	1.00	2008-08-29	0
4 	4 	1042211186  	TATIANA  MARCELA ROLON                  	17	3	1988-05-07	1	DAJKKDADJJKA	6203547	68081	2	1	0	5	44546546	8 	2007-08-30	250	461500	68081	1	52	0.00	1.00	2008-08-30	0
1 	1 	88234897    	GILBERTO HERNANDEZ JARAMILLO            	15	3	1978-06-06	2	ADJAKSDJAJKD	6224514	68001	2	1	0	5	465465465	8 	2007-08-28	251	461500	68001	1	52	0.00	1.00	2008-08-28	0
0 	0 	91269992    	PEDRO JESUS RAMIREZ ROJAS               	29	1	1970-02-01	2	DADKADK	6447300	68001	2	1	0	5	4654646	8 	2007-09-11	252	700000	68001	1	51	0.00	1.00	2008-05-10	0
0 	0 	63563608    	KARENT YILLIANA GARCIA SALCEDO          	29	1	1985-06-03	1	DFKSLGNFf	6446577	68001	1	1	0	5	44653465	8 	2008-01-02	208	680000	68001	1	51	0.00	1.00	2008-06-29	0
5 	5 	37547190    	OLGA MARIA ARIZA TRIANA                 	17	3	1977-08-20	1	EWÑTFLWçkñ	6565	68001	1	1	0	2	144633	8 	2007-01-20	209	433700	68001	1	52	0.00	1.00	2007-04-19	0
4 	4 	91510135    	ROGELIO OSPINO GUEVARA                  	15	3	1981-11-08	2	FDSFHGFJH	54511	68081	1	1	0	1	234632	8 	2009-01-26	210	433700	68081	1	52	0.00	1.00	2007-04-25	0
0 	0 	91487698    	MARIO ALFREDO MACIAS SARMIENTO          	29	1	1976-01-20	2	BGR .H-GFMHRÇDGR	55433	68001	2	1	0	5	16546523	8 	2007-01-25	211	5638100	68001	1	51	0.00	1.00	2007-12-31	0
0 	0 	63502693    	ELSA TATIANA CASTELLANOS LASSO          	29	1	1975-04-30	1	CALLE 10 No 34-15 T2 APT 404 LOS PINOS	6361752	68001	2	2	0	4	265445441	8 	2007-01-18	182	1200000	68001	1	51	0.00	1.00	2007-05-01	0
2 	2 	91161913    	JONATHAN FERNANDO LINARES ROA           	15	3	1985-09-09	2	ADKASLDKALK	64861898	68001	2	1	0	5	454654	8 	2007-04-28	233	461500	68001	1	52	0.00	1.00	2008-04-27	0
5 	5 	91182799    	REYNALDO ROJAS VELASCO                  	31	3	1980-09-13	2	DALDKAKD	45465464	68001	2	1	0	5	4564654	8 	2007-04-16	234	750000	68001	1	52	0.00	1.00	2008-04-16	0
1 	1 	91429223    	DEOGRACIAS D J HERRERA NIÑO             	15	1	1966-09-01	2	CLL 55 No 35A-23 BARRANCA	6227603	68081	1	1	0	2	0	60	2004-07-21	19	535600	68081	1	52	0.00	1.00	2004-12-31	0
4 	4 	91449287    	ELIECER LUNA SOLORZANO                  	15	1	1978-07-25	2	JDHJFDHSKDJHDLAKF	3565322	68081	2	1	0	4	4541546	8 	2006-10-03	196	461500	68081	1	52	0.00	1.00	2007-02-02	0
6 	6 	1095792840  	GERMAN ALFONSO TARAZONA DURAN           	15	1	1987-07-25	2	DFH SD SJ	644541	68001	1	1	0	2	415233	8 	2006-10-04	197	433700	68001	1	52	0.00	1.00	2007-02-03	0
2 	2 	63494018    	DORIS REY ENCISO                        	19	3	1973-10-12	1	asdjkajdajd	6486189	68001	2	1	0	5	545646546	8 	2007-10-18	254	1250000	68001	1	52	0.00	1.00	2008-10-17	0
0 	0 	37722937    	PAOLA ANDREA FERRER FIGUEROA            	29	1	1979-01-19	1	JKAJFAJFLAF	6320505	68001	1	1	0	5	4546	8 	2007-12-12	255	2080000	68001	1	51	0.00	1.00	2008-12-10	0
1 	1 	1096187075  	AURORA TRASLAVIÑA SANDOVAL              	17	3	1986-07-28	1	ADADLADKOPAD	62245114	68081	2	1	0	5	454645	8 	2007-12-08	256	496900	68001	1	52	0.00	1.00	2008-12-10	0
4 	4 	13854733    	JOSE LUIS VESGA SANCHEZ                 	15	3	1981-04-03	2	ADKAPDKPAKD	6224514	68001	2	1	0	5	4654654	8 	2007-12-04	257	461500	68001	1	52	0.00	1.00	2007-12-04	0
2 	2 	63530521    	YENNY KATERINE PAIPA SARMIENTO          	17	3	1982-03-08	1	JDKAJDKJAKDJ	6203547	68001	2	1	0	5	45465465	65	2008-01-22	258	461500	68001	1	52	0.00	1.00	2009-01-23	0
2 	2 	1102348286  	VIVIANA CRISTINA MARIN MARTINEZ         	17	3	1985-10-26	1	AODAKDJAKD	6320505	68001	2	1	0	5	4654654	8 	2010-12-14	259	535600	68001	1	52	0.00	1.00	2009-02-01	0
7 	7 	91523634    	EDINSON QUINTERO GOMEZ                  	33	3	1983-09-03	2	jdkajdajd	6487819	68001	2	1	0	5	121211	8 	2010-08-27	260	515000	68001	1	52	0.00	1.00	2009-02-01	0
1 	1 	13852970    	DIRSEU CADENA MARMOL                    	15	3	1980-06-14	2	dadjahd	4464654	68001	2	1	0	5	4545465	8 	2008-02-09	261	496900	68001	1	52	0.00	1.00	2009-02-09	0
0 	0 	63550998    	KAROL VIVIANA ROA FLOREZ                	29	1	1984-03-21	1	dkalkdadk	6447300	68001	2	1	0	5	44454545	8 	2008-02-02	262	680000	68001	1	51	0.00	1.00	2009-02-02	0
0 	0 	91022439    	JACOB ROA ROJAS                         	29	1	1962-08-13	2	adlñadkadk	6447300	68001	2	1	0	5	4545465	8 	2015-01-08	263	2200000	68001	0	51	0.00	1.00	2009-02-01	0
3 	3 	1098645039  	YULEIMA ORTEGA RAMIREZ                  	17	3	1987-11-16	1	dadjajdjad	673000	68001	2	1	0	5	45464654	8 	2008-07-03	264	496900	68001	1	52	0.00	1.00	2008-02-01	0
7 	7 	28352692    	BELKY YURLEY MALDONADO PICO             	17	3	1982-06-19	1	hadjadkjadjkla	6447300	68001	2	1	0	5	545646546	8 	2010-09-11	265	535600	68001	1	52	0.00	1.00	2009-02-01	0
3 	3 	1099364700  	YURLEY GARAVITO GUALDRON                	16	3	1981-02-13	1	AJDKFJAKAFJ	6447300	68001	2	1	0	5	454654654	8 	2008-02-01	266	496900	68001	1	52	0.00	1.00	2009-02-01	0
0 	0 	1098646979  	MARLY NAYDU AGARITA VILLAMIZAR          	29	1	1987-12-21	1	adjadkjajdjad	645465465	68001	2	1	0	5	45465465	8 	2008-03-25	281	650000	68001	1	51	0.00	1.00	2009-03-25	0
1 	1 	91445814    	MARIO MARTINEZ MENDOZA                  	15	3	1976-07-29	1	FSFSFSF	44456654	68001	2	1	0	5	546546546	8 	2008-03-19	282	532500	68001	1	52	0.00	1.00	2009-03-19	0
4 	4 	1096193114  	MARIA ANGELICA PERDOMO SANCHEZ          	17	3	1987-12-16	1	DADKALKDLAK	56654654654	68001	2	1	0	5	454654	8 	2008-04-12	283	461500	68001	1	52	0.00	1.00	2009-04-13	0
9 	9 	1098666619  	JHON JAIRO ESPINOSA OSORIO              	15	3	2004-05-10	1	KRLAKRQKRQ	4546465465	68001	2	1	0	5	465465465	8 	2009-05-01	284	535600	68001	1	52	0.00	1.00	2010-05-01	0
1 	1 	1096187060  	YEIMYS FLOREZ SERRANO                   	17	3	2004-05-10	1	KLJKLJJ	465464465	68001	2	1	0	5	445445458	8 	2011-01-22	285	535600	68001	1	52	0.00	1.00	2011-07-06	0
7 	7 	91296412    	JUAN CARLOS SANABRIA HERRERA            	20	3	2004-05-10	1	AKLJFKLAJFKLJ	454654564	68001	2	1	0	5	54654564	65	2008-04-02	286	1248000	68001	1	52	0.00	1.00	2009-04-02	0
0 	0 	1098661394  	PAOLA ANDREA LOZANO SOLANO              	29	1	1985-05-10	1	LÑKDLAKDKLÑ	64654646	68001	2	1	0	5	46465465	8 	2008-05-14	288	700000	68001	1	51	0.00	1.00	2009-05-12	0
1 	1 	13570926    	RICHARD ALFONSO TANDAZO                 	15	3	1985-05-02	2	AÑLDLALLD	64654645	68001	2	1	0	5	151321	8 	2008-05-10	289	461500	68001	1	52	0.00	1.00	2009-05-09	0
5 	5 	1098648154  	SAMUEL ANDRES GUERRERO VEGA             	15	3	1981-05-01	2	DMKLADLJAD	556465465	68001	2	1	0	5	465465465	8 	2008-05-02	290	461500	68001	1	52	0.00	1.00	2009-05-01	0
1 	1 	37576025    	YENNY ECHEVERRY HERRERA                 	17	3	1982-05-01	1	DADADAD	5465654	68001	2	1	0	5	5646654	8 	2008-05-09	291	461500	68001	1	52	0.00	1.00	2009-05-09	0
4 	4 	91542641    	OSCAR JAVIER AYALA PLATA                	15	3	1985-08-29	2	DADJAKJD	52554	68001	2	1	0	5	46544456	8 	2008-05-03	292	496900	68001	1	52	0.00	1.00	2009-05-02	0
4 	4 	1096192688  	MIGUEL ANGEL HERNANDEZ VILLAREAL        	15	3	1985-02-14	2	COLOMBIA	54654654	68001	2	1	0	5	4654654	8 	2008-05-24	293	461500	68001	1	52	0.00	1.00	2009-05-23	0
2 	2 	1098623981  	LUIS ALEXANDER MOLINA BETANCOURT        	15	3	2004-05-10	2	CRA 8 NO 21-26	6486189	68001	1	3	0	2	65456	96	2008-10-31	294	515000	68001	1	52	0.00	1.00	2010-05-10	0
4 	4 	1037499167  	LEIDY CRISTINA GOMEZ SALAZAR            	17	3	1987-11-26	1	sfjksfklsfjsf	6447300	68001	2	1	0	5	454564654	8 	2008-02-01	267	496900	68001	1	52	0.00	1.00	2009-02-01	0
3 	3 	37728316    	ANA MILENA GUARIN BUENO                 	16	3	2004-05-10	1	CRA PTE 13-14 BUCARCIAA	6496727	68001	1	1	0	2	54543	40	2008-06-01	295	535600	68001	1	52	0.00	1.00	2010-05-10	0
1 	1 	1096201367  	AURA TATIANA DUEÑEZ OLIVERO             	17	3	1989-08-05	1	JADKAJDKJAKDJ	6203547	68001	2	1	0	5	4654564564	8 	2011-04-09	268	535600	68001	1	52	0.00	1.00	2009-02-01	0
2 	2 	63523720    	CARMEN ELISA CARREÑO RIVERA             	17	3	1981-11-18	1	ASJDKAJDKJADKJ	6203527	68001	2	1	0	5	4654645	8 	2008-02-01	269	515000	68001	1	52	0.00	1.00	2009-02-01	0
2 	2 	1095795771  	MANUEL FERNANDO CESPEDES PINZON         	15	3	2004-05-10	2	DAKDJKADJKJD	6447100	68001	2	1	0	5	4545546544	8 	2008-02-01	270	461500	68001	1	52	0.00	1.00	2009-02-01	0
9 	9 	1095797192  	DANIELA MERCEDES RINCON GALLARDO        	13	3	1988-08-04	1	adakdakdkad	64473000	68001	2	1	0	5	465456454	8 	2010-11-19	271	900000	68001	1	52	1.00	1.00	2009-02-01	0
5 	5 	13850296    	LUIS ALBEIRO LOPEZ PULIDO               	15	3	1978-07-15	1	NHADAJDJAKL	645465465	68001	2	1	0	5	46545454	8 	2008-02-01	272	496900	68001	1	52	0.00	1.00	2009-02-01	0
7 	7 	91354968    	LUIS EDUARDO ESPINOZA JAIMES            	15	3	2004-05-10	2	DADKLAJDKLAJDKJ	6447300	68001	2	1	0	5	45456464	8 	2008-02-01	273	461500	68001	1	52	0.00	1.00	2009-02-01	0
3 	3 	1095920049  	GREILY XIOMARA BLANCO SANCHEZ           	17	3	2004-05-10	1	SFHJGFHGJ	4543213	68001	1	1	0	2	54535	5 	2008-06-01	296	496900	68001	1	52	0.00	1.00	2010-05-10	0
2 	2 	63558817    	LAURA LIZETH GONZALEZ ESTUPIÑAN         	17	3	2004-05-10	1	gkdjhhçxdz	6542	68001	1	1	0	2	42521	40	2008-06-01	297	461500	68001	1	52	0.00	1.00	2010-05-10	0
5 	5 	63554843    	SANDRA LUCIA HERNANDEZ                  	17	3	2004-05-10	1	´lddf	654655	68001	2	1	0	5	1232	40	2006-06-01	298	461500	68001	1	52	0.00	1.00	2010-05-10	0
7 	7 	37513676    	YADITH ROCIO CASTRO MACIAS              	17	3	2004-05-10	1	dadafry	6544565	68001	1	1	0	2	14312	40	2008-06-01	299	461500	68001	1	52	0.00	1.00	2010-05-10	0
2 	2 	1098624241  	YULY ANDREA AVILA CASTRO                	17	3	2004-05-10	1	gdtffvkñt,gpe	655652	68001	1	1	0	2	15342132	40	2008-06-01	300	461500	68001	1	52	0.00	1.00	2010-05-10	0
5 	5 	13278801    	OMAR FERNANDO FUENTES ORDOÑEZ           	15	3	2004-05-10	1	mmsklg nfjhgmrtñd	445441	68001	1	1	0	2	454	40	2008-06-01	301	461500	68001	1	52	0.00	1.00	2010-06-01	0
8 	8 	1095916950  	NIDIA RUBIELA AGUILAR REMOLINA          	16	3	2004-05-10	1	jijgp`ldhpkgfh	652145653	68001	1	1	0	1	1435413	25	2008-06-01	302	515000	68001	1	52	0.00	1.00	2010-05-10	0
0 	0 	1065864812  	YERIS GUEVARA LEMUS                     	29	1	1986-06-09	1	ADKAODKPAKD	6546546	68001	2	1	0	5	46546546	8 	2010-06-01	287	1400000	68001	0	51	0.00	1.00	2008-12-30	0
0 	0 	1098646975  	MAYERLY MARTINEZ VARGAS                 	29	1	1986-12-01	1	tgeyrtyrtu	556463	68001	2	1	0	5	56453	8 	2010-02-01	425	680000	68001	1	51	0.00	1.00	2011-01-31	0
0 	0 	91288033    	ALDEMAR MONTAÑO OCHOA                   	29	3	1976-12-11	2	asdfsdghfgjh	24534	68001	1	1	0	5	4534	8 	2010-02-01	426	1200000	68001	1	52	0.00	1.00	2011-01-31	0
0 	0 	63354755    	FLOR EDDY CARRILLO CARRILLO             	29	1	1970-07-12	1	tetleryu	1456413	68001	2	1	0	5	2634654	8 	2010-02-01	427	770000	68001	0	51	1.00	1.00	2011-01-21	0
1 	1 	1095766197  	DENNYS FERNEY CADENA GARAVITO           	15	3	1987-12-01	2	weteryer	21313	68081	1	1	0	5	565463	8 	2010-03-02	428	515000	68081	1	52	0.00	1.00	2011-01-21	0
7 	7 	1098607918  	LEIDY LISETH SAAVEDRA CASALLAS          	17	3	1988-12-01	1	hgtrgyhry	1456356	68001	2	1	0	5	534635	8 	2010-02-06	429	515000	68001	1	52	0.00	1.00	2011-01-31	0
4 	4 	1096197023  	CYNTHIA JULIET ARRIETA PINTO            	17	3	1980-12-01	1	fsdtdry	3131	68081	2	1	0	5	26143	8 	2010-02-06	430	515000	68081	1	52	0.00	1.00	2011-01-31	0
7 	7 	37713241    	MARISELA FUENTES VALVUENA               	21	3	2004-05-10	1	cdjfisdfgd	453	68001	2	1	0	5	456436	8 	2011-07-03	431	1248000	68001	1	52	0.00	1.00	2011-01-31	0
8 	8 	1102367551  	BLADIMIR ANDRES ARIAS RAMIREZ           	15	3	1991-10-08	2	lofhefQ<ERUUKY7LO	456354	68001	2	1	0	5	53543	8 	2012-02-10	432	566700	68001	1	52	1.00	1.00	2011-01-31	0
3 	3 	63544170    	LEIDY JOHANNA SANABRIA DIAZ             	17	3	1986-12-01	1	TREWTLETKE	6356543	68001	2	1	0	5	4346354	8 	2010-02-12	433	535600	68001	1	52	0.00	1.00	2011-01-31	0
2 	2 	91510137    	ALEX ORLANDO MADRIGAL PINZON            	20	3	1985-12-01	2	CSDLÑFLÑSDKGLDH	5346465	68001	2	1	0	5	3113205621	8 	2010-04-22	448	800000	68001	1	52	0.00	1.00	2011-04-01	0
2 	2 	1098286190  	ADRIANO FERNANDO VALBUENA OCHOA         	33	3	1988-03-30	2	DSFHKDSHFJKSDD	54565465463	68001	2	1	0	5	565463	8 	2010-04-16	449	1050000	68001	0	52	1.00	1.00	2011-04-15	0
2 	2 	91473187    	WALTHER ALFONSO CELIS GOMEZ             	15	3	1985-12-01	2	CRA 8 No 3-61	6486189	68001	2	1	0	5	45242056	8 	2010-05-11	450	535600	68001	1	52	0.00	1.00	2011-05-10	0
8 	8 	1095794443  	JHON JAIRO RINCON LIZARAZO              	15	3	1988-01-09	2	CRA 8 3-61	6486189	68001	3	1	3	2	14546	8 	2010-05-07	451	515000	68001	1	52	0.00	1.00	2011-05-07	0
0 	0 	63508971    	ADRIANA PATRICIA BACCA RIVERA           	29	1	1975-12-23	1	CALLE 70 44W-156 KM 4 VIA GIRON	6370099	68001	2	1	1	5	4646	8 	2010-05-07	452	1800000	68001	1	51	0.00	1.00	2011-05-07	0
7 	7 	63553794    	LAURA MILENA DIAZ SARMIENTO             	16	3	1983-07-28	1	CRA 27 21-26	6350333	68001	1	5	1	2	53467	8 	2010-05-07	453	840000	68001	0	52	1.00	1.00	2011-05-07	0
3 	3 	1098656787  	MARY LUZ CARREÑO GONZALEZ               	17	3	1988-06-27	1	CRA 23 No 14-40	6320505	68001	2	1	0	5	5434163	8 	2010-05-15	454	515000	68001	1	52	0.00	1.00	2011-05-10	0
4 	4 	1121860373  	MONICA PATRICIA BERNAL PEÑUELA          	17	3	1990-01-12	1	cra 35 47-75	6218618	68081	1	5	0	2	468456456	8 	2010-06-01	462	515000	68081	1	52	0.00	1.00	2011-06-01	0
0 	0 	1098608933  	NATALY ESMERAL AMAYA                    	29	1	1986-01-22	1	CALLE 27 6-31 LAGOS 3	6849275	68001	3	5	1	3	144545386	8 	2010-06-16	464	860000	68001	1	51	1.00	1.00	2011-06-16	0
8 	8 	1117499195  	YURY MILDRED MARTINEZ MUÑOZ             	17	3	1988-12-01	1	xzcdgvfdhf	41241	68001	2	1	0	5	22323	8 	2010-02-16	434	515000	68001	1	52	0.00	1.00	2011-02-14	0
2 	2 	1098619151  	LEIDYZ JENIFER RUEDA FIGUEROA           	17	3	1989-12-01	1	ASDSFDFHHJK	563543	68001	2	1	0	5	4314136	8 	2010-02-16	435	515000	68001	1	52	0.00	1.00	2011-02-14	0
1 	1 	28070408    	LUZ ENITH CASTRO OSORIO                 	17	3	1981-09-30	1	DF´GLFÑGKHRF HG	45246351	68001	2	1	0	5	123121	8 	2012-07-03	436	680000	68001	1	52	1.00	1.00	2011-02-15	0
4 	4 	1096194676  	DAISSON TORRES SALGUERO                 	37	3	1987-08-18	2	CALLE 49 54-14  VILLARELIS II	3138121619	68081	1	5	0	2	5451454154	8 	2010-06-23	465	535600	68081	1	52	0.00	1.00	2011-06-22	0
1 	1 	1075232315  	KERLY JOHANNA CAICEDO CORDOBA           	17	3	1988-02-01	1	CALLE 46 36B-104  TAMARINDOS CLUB	3143433665	68081	3	5	1	2	2453454544	8 	2010-10-05	475	515000	68081	1	52	0.00	1.00	2011-10-04	0
0 	0 	63341171    	LIGIA JUDITH GOMEZ ZAMBRANO             	29	1	1968-04-09	1	CARRERA 30 # 16-61 PISO 2	6342389	68001	1	2	0	4	1256	8 	2010-10-12	476	900000	68001	1	51	0.00	1.00	2010-10-11	0
4 	4 	1096208924  	KELLY JOHANNA NOEL CARBALLO             	17	3	2004-05-10	1	CRA 19 # 49-37	6370099	68081	2	1	0	2	2356	8 	2011-02-17	477	535600	68081	1	52	0.00	1.00	2011-10-13	0
7 	7 	1095789311  	MARISOL JAIMES VELANDIA                 	39	3	1986-08-05	1	CRA 9AE  29A-27	6581332	68276	1	2	0	3	23659	8 	2010-10-26	480	515000	68001	1	52	0.00	1.00	2011-10-25	0
2 	2 	91533147    	HERNAN MAURICIO MORALES CUELLAR         	15	3	1984-09-05	2	CALLE 23C  1W-37 PORTAL DEL VALLE	6346243	68547	1	5	0	2	23569	8 	2012-11-16	487	566700	50001	1	52	1.00	1.00	2011-11-21	0
9 	9 	1098726878  	JOHAN NICOLAS ORTIZ ORTIZ               	15	3	1992-09-13	2	CALLE 61A  2W-66 MUTIS	6449219	68001	1	5	0	2	23569	8 	2013-05-09	488	680000	68001	1	52	1.00	1.00	2011-11-21	0
2 	2 	1095799119  	MARCELA MARGARITA PICO ALVAREZ          	17	3	1988-12-21	1	SECTOR 20 APTO 211 BUCARICA	6483866	68276	1	2	0	2	6825365	8 	2010-12-05	489	535600	47001	1	52	0.00	1.00	2011-12-05	0
7 	7 	91539981    	JOVANY ALBERTO PALOMINO                 	15	3	1985-03-10	2	CALLE 5  16-25 COMUNEROS	6719408	68001	1	5	0	2	236598	8 	2010-12-06	490	680000	68001	1	52	1.00	1.00	2011-12-05	0
9 	9 	1095915171  	SANDRA LILINA RUEDA BARRAGAN            	17	3	1988-10-20	1	CALLE 28  30-81 GIRON	6465338	68307	2	5	0	2	2536598	8 	2011-07-17	491	535600	68001	1	52	0.00	1.00	2011-12-05	0
9 	9 	91255772    	JOSE DANIEL OSORIO IBARRA               	35	3	1967-09-16	2	TRANSV. 128  63-15 CIUDAD JARDIN	6771845	68276	2	5	0	2	2356985421	8 	2010-12-01	492	650000	54810	1	52	1.00	1.00	2011-11-30	0
9 	9 	63541210    	ANDREA MILENA ACOSTA MERCHAN            	39	3	1983-08-07	1	CALLE 13  29-47 APTO 201 SAN ALONSO	6347124	68001	2	5	0	2	2536598	8 	2010-12-01	493	535600	68001	1	52	0.00	1.00	2011-11-30	0
7 	7 	1094270056  	XIOMARA PATRICIA CARRILLO CAICEDO       	17	3	1992-12-25	1	CRA. 18 N° 22-23	3204287529	68001	1	5	0	3	2525	8 	2012-03-02	705	680000	54518	1	52	1.00	1.00	2013-03-01	0
0 	0 	91299871    	FERNANDO FRANCISCO COLMENARES TELLEZ    	29	1	1974-06-21	2	LAGOS V ETAPA TORRE 18 APTO 401	6370099	68276	2	1	0	4	23659	8 	2010-11-08	484	0	8001 	1	51	0.00	1.00	2011-11-07	0
9 	9 	1095912535  	MERLY YURLEY LOPEZ PATIÑO               	17	3	1987-06-08	1	CRA 11  103E-75 MANUELA BELTRAN	6370792	68001	3	1	0	2	236598	8 	2011-08-18	481	535600	68001	1	52	0.00	1.00	2011-10-27	0
7 	7 	63357551    	MARIA EUGENIA SUAREZ MORENO             	41	3	1970-03-26	1	CALLE 61  3-91 SAMANES IV	6948708	68001	2	1	0	2	235698	8 	2010-12-06	494	535600	68169	1	52	0.00	1.00	2011-12-05	0
9 	9 	1098684831  	JOHNS DAYVER PALENCIA HERNANDEZ         	14	3	1990-04-04	2	CALLE 1  25B-26 REGADEROS	3104762158	68001	3	5	0	2	236598	8 	2010-11-06	485	900000	68001	1	52	1.00	1.00	2011-11-07	0
7 	7 	1095918772  	FABIO FERNANDO GARZON ROMERO            	15	3	1989-07-26	2	CARRERA 20  11-88 SAN FRANCISCO	3185949695	68001	1	2	0	2	326598	8 	2010-11-06	486	566700	1001 	1	52	1.00	1.00	2011-11-05	0
2 	2 	91530766    	OMAR AUGUSTO GARCIA GONZALEZ            	15	3	1984-07-14	2	CALLE 22  11B-31 LOS ROSALES	3153424512	68276	1	5	0	2	23569	8 	2010-12-01	495	535600	68001	1	52	0.00	1.00	2011-12-01	0
0 	0 	18496404    	GABRIEL MARIO LOPEZ ESTRADA             	29	1	1973-05-13	2	DADLADKADKLAKD	6370099	68001	2	1	0	5	546544	8 	2008-07-22	304	5999500	68001	1	51	0.00	1.00	2008-07-21	0
4 	4 	13707732    	JOSE OLMEDO BARRAGAN MOGOLLON           	15	3	1984-07-02	2	BARRANCA	6224514	68001	1	1	0	5	1545465	8 	2008-08-12	305	461500	68001	1	52	0.00	1.00	2008-05-12	0
4 	4 	28214988    	DEINY TASCO GOMEZ                       	41	3	1981-05-04	1	BARRANCA	6224514	68001	2	1	0	5	4654654	8 	2009-10-06	306	515000	68001	1	52	0.00	1.00	2010-10-08	0
7 	7 	1095805783  	JUAN CARLOS MARTINEZ FIGUEROA           	14	3	1990-07-26	2	DKLADKLAKD	465456465	68001	2	1	0	5	45456456	8 	2008-06-18	307	800000	68001	1	52	0.00	1.00	2009-06-17	0
0 	0 	90072656740 	0                                       	15	3	1992-04-10	2	LAKLAKDÑK	64565656	68001	2	1	0	5	4654654	8 	2008-06-18	303	461500	68001	1	52	0.00	1.00	2009-06-17	0
4 	4 	1095911964  	YEFERSON YESID GARCIA AMOROCHO          	14	3	1987-11-04	2	LÑKLADKKLADJD	6203595	68001	2	1	0	5	454654654	8 	2008-09-01	308	770000	68001	0	52	1.00	1.00	2009-09-01	0
4 	4 	37578618    	AIRELY RODRIGUEZ ORTIZ                  	16	3	1984-03-19	1	DADKALDK	87877878	68001	2	1	0	5	5454564	8 	2008-09-29	309	515000	68001	1	52	0.00	1.00	2009-09-28	0
1 	1 	1096189347  	RICHAR ALEXANDER ROJO HINCAPIE          	15	3	1985-12-11	2	ASDADAD	6224514	68001	2	1	0	5	446456456	8 	2008-09-26	310	496900	68001	1	52	0.00	1.00	2009-09-26	0
7 	7 	1095910534  	MARIA TERESA LUNA RINCON                	17	3	1987-05-19	1	DAHDJAHKDH	6350333	68001	2	1	0	5	46464	8 	2008-10-27	313	496900	68001	1	52	0.00	1.00	2009-10-26	0
0 	0 	63536113    	IRINA PAOLA CARDENAS CACERES            	29	1	1982-11-15	1	CALLE 14B Nº 25-59 URB. 1o de MAYO GIRON	6590940	68001	2	1	0	5	456454	8 	2008-12-19	314	650000	68001	1	51	0.00	1.00	2009-12-19	0
1 	1 	1096206513  	LEONARDO FABIO GARRIDO BENAVIDES        	15	3	1990-07-16	2	COLOMBIA	6203597	68001	2	1	0	5	4545646	8 	2008-12-20	315	532500	68001	1	52	0.00	1.00	2009-12-31	0
0 	0 	91219738    	CESAR MAURICIO PEDROZA VARGAS           	29	1	1962-06-30	2	CRA 8 Nº 3-61	6370099	68001	2	1	0	5	454564444	8 	2009-01-28	318	3640000	68001	1	51	0.00	1.00	2010-01-28	0
1 	1 	72241681    	ESNEIDER JOSE BONILLA BARBOSA           	15	3	1979-04-04	2	ADJAKLDJAKJD	6224514	68001	2	1	0	5	454564	8 	2009-01-27	319	496900	68001	1	52	0.00	1.00	2009-01-26	0
1 	1 	1096202324  	MARIA YESENIA DIAZ SERRANO              	16	3	1989-09-26	1	JDAJDKJ	6224514	68001	2	1	0	5	54564564	8 	2009-01-24	320	1100000	68001	0	52	1.00	1.00	2010-09-24	0
4 	4 	37575929    	TATIANA ALQUICHIRE CABALLERO            	39	3	1983-01-05	1	DADADA	6224514	68001	2	1	0	5	45456456	8 	2009-01-16	321	515000	68001	1	52	0.00	1.00	2010-01-16	0
4 	4 	77195390    	FRAHENGLIS JOSE BOHORQUEZ RAMIREZ       	15	3	1979-02-02	2	BARRANCA	6224514	68001	2	1	0	5	464564	8 	2009-02-13	322	535600	68001	1	52	0.00	1.00	2010-02-13	0
1 	1 	1096201253  	PAOLA ANDREA HERNANDEZ GOMEZ            	17	3	1989-05-11	1	BARRNACA	6224514	68001	2	1	0	5	454564	8 	2009-02-12	323	496900	68001	1	52	0.00	1.00	2010-02-11	0
4 	4 	37580201    	SHIRLEY TATIANA DURAN ARRIETA           	17	3	1984-12-05	1	BARRANCA	6224514	68001	2	1	0	5	454564	8 	2009-02-07	324	515000	68001	1	52	0.00	1.00	2010-02-06	0
1 	1 	1096201407  	JOHN JAVIER ROJAS FONSECA               	15	3	1989-08-17	2	COMERCIO	6224514	68001	2	1	0	5	4646465	8 	2009-02-18	325	496900	68001	1	52	0.00	1.00	2010-02-17	0
1 	1 	1098625711  	MIRYAM LEONOR CASTILLO LOPEZ            	17	3	1986-11-04	1	DAJDKLAJDL	6224514	68001	2	1	0	5	5454564	8 	2009-02-26	326	496900	68001	1	52	0.00	1.00	2010-02-25	0
1 	1 	1096203258  	IVETH YURANY ARDILA ROYERO              	17	3	2004-05-10	1	CRA 6 Nº 49-29	6224514	68001	2	1	0	5	454564	8 	2009-03-13	327	496900	68001	1	52	0.00	1.00	2010-03-12	0
1 	1 	1096194436  	INGRID PAOLA ZABALETA ALVAREZ           	17	3	2004-05-10	1	CARRERA 19 Nº 49-29	456456	68001	2	1	0	5	445465	8 	2009-03-11	328	496900	68001	1	52	0.00	1.00	2010-03-10	0
4 	4 	1096198366  	ERIKA MILENA RUEDA HERRERA              	17	3	2004-05-10	1	CRA 19 Nº 49-29	545454	68001	2	1	0	5	44654	8 	2009-03-11	329	496900	68001	1	52	0.00	1.00	2010-03-10	0
1 	1 	9692616     	JHON FABIO BOLIVAR URQUIJO              	10	3	1982-08-15	1	CRA 19 Nº 49-29	6224514	68001	2	1	0	5	445456	8 	2009-03-11	330	940000	68001	1	52	1.00	1.00	2010-03-11	0
1 	1 	91535132    	SERGIO DARIO ARTEAGA GOMEZ              	14	3	2004-05-10	1	CRA 8 Nº 3-61	454546	68001	2	1	0	5	45454	8 	2009-03-05	331	700000	68001	1	52	0.00	1.00	2010-03-04	0
1 	1 	35005795    	MAYRA ESTELA ALVAREZ NOVOA              	17	3	1985-02-03	1	CRA 6 Nº 49-27	6224514	68001	2	1	0	5	45454	8 	2014-07-06	337	680000	68001	0	52	1.00	1.00	2010-05-09	0
7 	7 	91041825    	NICEFORO ARDILA SAAVEDRA                	15	3	2004-05-10	1	cra 27 nº 21-26	6350333	68001	2	1	0	5	45454	8 	2010-06-22	338	515000	68001	1	52	0.00	1.00	2010-05-11	0
2 	2 	1098645436  	IVAN ANDRES BOHORQUEZ PALOMINO          	15	3	1987-11-19	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	5454564	8 	2010-07-08	339	515000	68001	1	52	0.00	1.00	2011-07-09	0
8 	8 	91352956    	JORGE MAURICIO QUIJANO FRANCO           	15	3	1980-11-01	2	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	15456456	8 	2009-05-01	340	496900	68001	1	52	0.00	1.00	2010-05-10	0
8 	8 	91519406    	JOSE FRANCISCO RODRIGUEZ CAMPOS         	15	3	1980-05-15	2	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	456454	8 	2009-05-01	341	515000	68001	1	52	0.00	1.00	2009-05-01	0
7 	7 	1098647444  	PATRICIA SAAVEDRA URIBE                 	17	3	1987-02-16	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	454564	8 	2009-05-01	342	496900	68001	1	52	0.00	1.00	2010-05-01	0
3 	3 	63559907    	DIANA CONSUELO NAVARRO NIÑO             	17	3	1985-05-20	1	CRA 23 Nº 14-40	6320505	68001	2	1	0	5	54564564	8 	2009-07-02	343	515000	68001	1	52	0.00	1.00	2010-05-10	0
7 	7 	1022330797  	LESLY JULIETH PORTILLA                  	17	3	1987-03-08	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	456454	8 	2009-05-01	344	515000	68001	1	52	0.00	1.00	2010-09-10	0
2 	2 	1098611843  	DORIA MILENA ARDILA MARTINEZ            	17	3	1986-02-01	1	CRA 8 Nº 49-27	6486189	68001	2	1	0	5	5454	8 	2009-05-01	345	515000	68001	1	52	0.00	1.00	2010-05-01	0
2 	2 	63557847    	DIANA MARCELA CABALLERO ROJAS           	17	3	2004-05-10	1	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	5454	8 	2009-05-01	346	496900	68001	1	52	0.00	1.00	2010-05-01	0
7 	7 	1098675708  	MONICA JOHANNA SOLANO LOZADA            	39	3	2004-05-10	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	54564	8 	2009-05-01	347	496900	68001	1	52	0.00	1.00	2010-05-01	0
7 	7 	1100221807  	ANGEL LEONARDO CALDERON ARGUELLO        	15	3	1992-06-07	1	CRA. 12 N° 42-62	3112370689	68001	1	5	0	2	2525	8 	2013-07-05	702	680000	68001	1	52	1.00	1.00	2013-02-15	0
4 	4 	1096197516  	CARMEN PAOLA ISAZA HERRERA              	15	3	2004-05-10	1	DOAIDOAIDOAI	45646546	68001	2	1	0	5	465465465	8 	2012-02-03	274	566700	68001	1	52	1.00	1.00	2009-05-27	0
4 	4 	28488892    	HELENITA ASPRILLA VARGAS                	17	3	2004-05-10	1	ADAPODIOAPDI	45454654	68001	2	1	0	5	46545465	8 	2008-02-27	275	461500	68001	1	52	0.00	1.00	2009-02-27	0
4 	4 	4984503     	MILTON HERNANDO HOYOS                   	15	3	1976-07-29	1	DADKOADKPO	64654654	68001	2	1	0	5	4654654	8 	2008-02-27	276	461500	68001	1	52	0.00	1.00	2009-02-27	0
1 	1 	1096188484  	CLAUDIA MILENA TORRES JIMENEZ           	17	3	2004-05-10	1	ADKALDKKL	465454654	68001	2	1	0	5	465464	8 	2008-02-16	277	515000	68001	1	52	0.00	1.00	2009-02-27	0
9 	9 	1098670146  	OSCAR GERARDO GOMEZ MORENO              	44	3	1989-05-14	1	CRA 23 Nº 17-40	6320505	68001	2	1	0	5	454564	8 	2009-05-01	348	700000	68001	1	52	1.00	1.00	2010-05-01	0
2 	2 	1098664282  	JUAN DAVID BALLESTEROS GIL              	15	3	2004-05-10	1	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	5454	8 	2009-05-01	349	515000	68001	1	52	0.00	1.00	2010-05-01	0
3 	3 	63545001    	IVONNE JOHANNA CARVAJAL DIAZ            	17	3	2004-05-10	1	CRA 23 Nº 14-40	6320505	68001	2	1	0	5	45456	8 	2009-05-01	350	515000	68001	1	52	0.00	1.00	2010-05-01	0
7 	7 	1098617036  	FAWER AVELLA BENAVIDEZ                  	15	3	2004-05-10	1	CRA 8 Nº 3-61	64861889	68001	2	1	0	5	454564	8 	2009-05-01	351	515000	68001	1	52	0.00	1.00	2010-05-01	0
2 	2 	1095805809  	ERICA YURLEY FLOREZ MANOSALVA           	17	3	1990-08-04	1	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	45456	8 	2009-05-01	352	535600	68001	1	52	0.00	1.00	2010-05-01	0
8 	8 	1110492712  	LINA PAOLA PEÑARANDA MEJIA              	17	3	2004-05-10	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	4564564	8 	2009-05-01	353	496900	68001	1	52	0.00	1.00	2010-05-01	0
7 	7 	1095786773  	LUDY PATRICIA MARTINEZ AMAYA            	39	3	2004-05-10	1	CRA 27 Nº 21-26	63503333	68001	2	1	0	5	454564	8 	2010-02-17	354	515000	68001	1	52	0.00	1.00	2010-05-01	0
7 	7 	37751159    	GENNY XIMENA PINZON OJEDA               	17	3	1980-06-08	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	5454	56	2009-05-01	355	496900	68001	1	52	0.00	1.00	2010-05-01	0
2 	2 	1094265589  	CINDY MILENA OTALORA ANTOLINEZ          	17	3	1990-11-24	1	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	45456	8 	2009-05-01	356	515000	68001	1	52	0.00	1.00	2010-05-01	0
7 	7 	1100889747  	LEIDY PAOLA FERNANDEZ JOYA              	39	3	1987-12-04	1	CRA 27 Nº 21-26	6330533	68001	2	1	0	5	45456	8 	2009-07-01	361	535600	68001	1	52	0.00	1.00	2010-07-01	0
1 	1 	13569512    	FARID ENRIQUE ARZUAGA RODRIGUEZ         	15	3	1984-11-20	1	CRA 19 Nº 49-296	54564564	68001	2	1	0	5	45645456	8 	2009-07-27	362	496900	68001	1	52	0.00	1.00	2010-07-29	0
4 	4 	1096198599  	MARIA IRENE OSPINA PINZON               	17	3	2004-05-10	1	ADKADJKA	4564546	68001	2	1	0	5	6454564	8 	2009-07-21	363	496900	68001	1	52	0.00	1.00	2010-07-20	0
0 	0 	1098611405  	MARTHA LILIANA SANCHEZ VELASQUEZ        	29	1	2004-05-10	1	ADAPDPLA	46456456	68001	2	1	0	5	45465456	8 	2009-07-17	364	580000	68001	1	51	0.00	1.00	2010-07-20	0
1 	1 	1096202323  	ALVARO FERNEY GOMEZ GONZALEZ            	15	3	2004-05-10	2	CARRERA 6 Nº 49-29	6224514	68001	2	1	0	5	5456465	8 	2009-08-25	365	496900	68001	1	52	0.00	1.00	2010-08-24	0
10	10	91346475    	CARLOS AUGUSTO SERRANO SERRANO          	12	3	1972-02-21	2	CALLE 7 N° 11-46	6562664	68001	2	1	0	5	46546546	8 	2012-01-09	366	3000000	68001	0	52	0.00	1.00	2013-01-08	0
0 	0 	63352538    	MARTHA BELTRAN QUIROGA                  	29	1	1970-03-05	1	CALLE 70 Nº 44W-156	545645646	68001	2	1	0	5	54564564	8 	2009-08-18	367	1560000	68001	1	52	0.00	1.00	2010-08-22	0
4 	4 	1096185899  	TERESA DEL PILAR ALEMAN APARICIO        	17	3	1986-10-09	1	adakldkadlkad	465464	68001	2	1	0	5	54564564	35	2012-01-20	384	566700	68001	1	52	1.00	1.00	2010-10-05	0
4 	4 	63560868    	LADY ELOISA GONZALEZ HERAZO             	17	3	1985-06-13	1	kajdkajkdj	456456456	68001	2	1	0	5	54564564	8 	2011-07-02	385	535600	68001	1	52	0.00	1.00	2010-10-05	0
4 	4 	1096194543  	NEYRA SIRLEY TOLOZA NIÑO                	17	3	1988-03-20	1	adadad	44654564	68001	2	1	0	5	54564564	8 	2009-10-06	386	515000	68001	1	52	0.00	1.00	2010-10-05	0
8 	8 	91527213    	WILLIAM FERNANDO CASTAÑEDA ALHUCEMA     	15	3	1983-12-01	1	KAJDKAJDJ	465564	68001	2	1	0	5	54654564	8 	2009-10-06	387	515000	68001	1	52	0.00	1.00	2010-10-05	0
0 	0 	13831852    	JAIME GOMEZ FORERO                      	29	1	1956-02-02	2	CALLE 70 Nº 44 W -156	6370099	68001	2	1	0	5	54564564	8 	2009-05-27	357	2000000	68001	1	52	0.00	1.00	2010-05-10	0
4 	4 	13570897    	JONATHAN JOSE SILVA MELLADO             	15	3	1985-08-28	2	CRA 6 Nº 4-29	6224514	68001	2	1	0	5	45464	8 	2009-05-27	358	496900	68001	1	52	0.00	1.00	2010-05-26	0
7 	7 	1098626644  	ZULLY YARITZA TRUJILLO URQUIJO          	17	3	1986-12-11	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	45454	8 	2009-05-18	359	496900	68001	1	52	0.00	1.00	2010-05-17	0
1 	1 	1096189664  	EDITH PAOLA RAMIREZ PERTUZ              	17	3	1987-06-21	1	CRA. 59 N° 47A-32	3212510910	68081	1	5	1	2	2525	8 	2012-04-03	718	680000	68081	1	52	1.00	1.00	2013-04-02	0
0 	0 	13874650    	EDWIN JESUS MUÑOZ LOPEZ                 	29	3	1982-01-11	2	CALLE 7 N° 48-26	3177480638	68001	2	1	0	5	456456	8 	2012-04-23	360	1500000	68001	1	52	0.00	1.00	2012-07-22	0
0 	0 	63533890    	MARIA XIMENA QUIJANO LOPEZ              	29	1	1983-07-20	1	CALLE 70 Nº 44W	6370099	68001	2	1	0	5	416464	8 	2009-01-09	316	800000	68001	1	51	0.00	1.00	2010-01-09	0
2 	2 	1098603022  	YENI ZONEY DIAZ SANCHEZ                 	17	3	1985-08-21	1	CALLE 70 Nº 44W -156	445645646	68001	2	1	0	5	445454	8 	2009-01-02	317	496900	68001	1	52	0.00	1.00	2010-01-02	0
7 	7 	63536406    	JEIDY YERCENIA DIAZ                     	20	3	1981-04-15	1	kaldklakdlñ	54564564	68001	2	1	0	5	54564654	8 	2009-09-24	369	1700000	68001	0	52	0.00	1.00	2010-09-27	0
7 	7 	1098669629  	LEYDY CAROLINA NAVAS GUTIERREZ          	39	3	2004-05-10	1	HAJHDJKAHD	45645646	68001	2	1	0	5	4546546	8 	2009-09-24	370	535600	68001	1	52	0.00	1.00	2010-05-27	0
8 	8 	37863164    	SHIRLEY MILENA ARIAS DULCEY             	12	3	1980-09-28	1	ADJAJDOJAD	66454565464	68001	2	1	0	5	4564564	8 	2009-09-24	371	2300000	68001	1	52	0.00	1.00	2010-09-23	0
2 	2 	1098664448  	CAROLINA PARADA BELTRAN                 	41	3	2004-05-10	1	JADJKADJADJL	454646	68001	2	1	0	5	45444	8 	2009-09-24	372	515000	68001	1	52	0.00	1.00	2010-09-23	0
1 	1 	1032358953  	ASTRID JOHANNA CAMPILLO BARRERA         	17	3	1986-03-06	1	KJDKAJDJK	45645646	68001	2	1	0	5	5456465	8 	2009-09-28	368	515000	68001	1	52	0.00	1.00	2010-09-27	0
4 	4 	1096187314  	KATHERINE ANDREA AZUERO                 	17	3	1986-11-15	1	KDAKDKDPKAD	645456456	68001	2	1	0	5	54564564	8 	2010-02-02	373	515000	68001	1	52	0.00	1.00	2010-09-23	0
4 	4 	1110483775  	NILSON MAYORGA RESTREPO                 	15	3	2004-05-10	1	DADKLALDÑL	4564564564	68001	2	1	0	5	54564564	8 	2010-10-23	381	515000	68001	1	52	0.00	1.00	2010-10-12	0
0 	0 	1098661156  	DIANA PATRICIA AVILA FERREIRA           	29	1	2004-05-10	1	DADADA	87848	68001	2	1	0	5	54564564	8 	2009-10-13	382	650000	68001	1	51	0.00	1.00	2010-10-12	0
4 	4 	1098633250  	JENNIFER LISSET RAMOS LEAL              	17	3	1987-04-15	1	DADADOAPODI	46456654	68001	2	1	0	5	4654564	8 	2009-10-06	383	496900	68001	1	52	0.00	1.00	2010-10-07	0
1 	1 	1096189320  	YESICA MILENA VALLE MACIAS              	17	3	1987-04-12	1	DJKAKDJKAJ	44654645	68001	2	1	0	5	4545465	8 	2008-03-12	278	461500	68001	1	52	0.00	1.00	2009-03-11	0
1 	1 	1096182199  	SHEILA MONTES SERRANO                   	17	3	1985-07-09	1	POPÀOFDPAO	6437000	68001	2	1	0	5	45465465	8 	2008-03-12	279	496900	68001	1	52	0.00	1.00	2009-03-11	0
4 	4 	1102714441  	MARITZA PATIÑO GALVIS                   	13	3	1985-10-01	1	ADAKDJJQ	644454654	68001	2	1	0	5	46546546	8 	2008-03-11	280	1000000	68001	0	52	1.00	1.00	2009-03-01	0
8 	8 	1095796768  	MAYRA ALEJANDRA RODRIGUEZ GARCIA        	17	3	2004-05-10	1	daldkladk	231231321	68001	2	1	0	5	4654564	8 	2009-10-06	388	515000	68001	1	52	0.00	1.00	2010-10-05	0
8 	8 	37901279    	NAYDU MAYERLY DIAZ ARIAS                	17	3	1984-12-20	1	dklakdlkad	56656	68001	2	1	0	5	656	8 	2009-10-06	389	515000	68001	1	52	0.00	1.00	2010-10-05	0
7 	7 	1098680757  	YESLI TALIA DIAZ CASTILLO               	17	3	1981-02-01	1	jajldjaldj	654564	68001	2	1	0	5	4564654	8 	2009-10-19	395	496900	68001	1	51	0.00	1.00	2010-10-19	0
1 	1 	37577175    	LUZ STELLA BENAVIDES BARRERA            	17	3	1981-02-01	1	dadada	564564564	68001	2	1	0	5	54564654	8 	2009-10-16	396	515000	68001	1	52	0.00	1.00	2010-10-16	0
4 	4 	1096204606  	YULI PAOLA TOLOZA GARCIA                	17	3	1990-02-13	1	dadjajkdk	46545646	68001	2	1	0	5	4564564	8 	2009-10-16	397	566700	68001	1	52	1.00	1.00	2010-10-15	0
4 	4 	1096186107  	MAYRA ALEJANDRA CARREÑO PUMAREJO        	17	3	1981-02-23	1	adadjaidj	4564564	68001	2	1	0	5	546546	8 	2009-10-16	398	496900	68001	1	52	0.00	1.00	2010-10-15	0
7 	7 	1098637894  	JEIMMY LIZETH BAUTISTA FIGUEROA         	17	3	1987-07-12	1	DKAJDKJAL	45645646	68001	2	1	0	5	5456465	8 	2009-10-16	399	515000	68001	1	52	0.00	1.00	2010-02-15	0
7 	7 	63548450    	LAURA CAROLINA TARAZONA SEPULVEDA       	39	3	1984-04-11	1	DADJKLADJ	64564564	68001	2	1	0	5	5456465	8 	2009-10-16	400	496900	68001	1	52	0.00	1.00	2010-10-15	0
9 	9 	91521633    	JORGE ARMANDO ALVAREZ ALVAREZ           	15	3	1983-08-27	1	JKDKLJAKLDJ	56	68001	2	1	0	6	5465465	8 	2009-10-06	390	535600	68001	1	52	0.00	1.00	2010-10-05	0
8 	8 	1095801732  	KARLA BRIJITH RUEDA FIGUEROA            	17	3	2004-05-10	1	ADADLÑALD	5564564	68001	2	1	0	5	465464	8 	2009-10-05	391	515000	68001	1	52	0.00	1.00	2010-10-04	0
8 	8 	37617617    	ISABEL CRISTINA DELGADO VILLAMIZAR      	20	3	1982-04-02	1	kadjadjjd	5644654	68001	2	1	0	5	5456456	8 	2009-10-05	392	900000	68001	1	52	1.00	1.00	2010-10-05	0
8 	8 	91530390    	JOHN FREDDY GRATERON GODOY              	15	3	1984-05-04	1	dadad	4655656	68001	2	1	0	5	4654564	8 	2009-10-05	393	680000	68001	1	52	1.00	1.00	2010-10-05	0
10	10	91159619    	JOSE VICENTE MORA FLOREZ                	10	3	1980-09-16	1	JKDA<LDJKALJD	4564654	68001	2	1	0	5	54564564	8 	2013-08-17	394	700000	68001	1	52	1.00	1.00	2010-10-09	0
7 	7 	1098667000  	SANDRA LILIANA BELTRAN RUEDA            	39	3	1989-01-13	1	ADADAOPDI	6465454	68001	2	1	0	5	54654564	8 	2009-10-16	401	515000	68001	1	52	0.00	1.00	2010-10-15	0
9 	9 	37727887    	ALYUL SANCHEZ OSORIO                    	17	3	1979-08-04	1	ADAKDJKAJD	4654564	68001	2	1	0	5	545454	8 	2009-10-16	402	535600	68001	1	52	0.00	1.00	2010-10-15	0
7 	7 	1098695707  	LEIDY TATIANA SANCHEZ TAMAYO            	17	3	1990-10-05	1	DADKAÑDK	45465	68001	2	1	0	5	456464654	8 	2009-11-10	403	515000	68001	1	52	0.00	1.00	2009-11-10	0
1 	1 	1096198087  	DIANA MARCELA PEREA VELASQUEZ           	17	3	1988-02-26	1	DADADAD	46545646	68001	2	1	0	5	54564564	8 	2009-11-05	404	515000	68001	1	52	0.00	1.00	2009-11-05	0
4 	4 	63471285    	DORIS JANET ROSAS DIAZ                  	41	3	1977-12-03	2	CRA 19 Nº 49-37	546545645	68001	2	1	0	5	546545646	8 	2009-11-23	405	515000	68001	1	52	0.00	1.00	2010-11-22	0
1 	1 	63545937    	MARIA YESENIA PIRATOA MALAVER           	17	3	1985-12-01	1	t.grdt,gdtfyh	3223	68001	1	1	0	2	54136	8 	2010-03-04	437	535600	68001	1	52	0.00	1.00	2011-03-03	0
1 	1 	63470625    	CLAUDIA LEONOR PINZON GOMEZ             	17	3	1977-06-10	1	CALLE 57 Nº 35-47 PRIMERO DE MAYO	6217117	68001	2	1	0	5	4545456	8 	2009-04-25	332	496900	68001	1	52	0.00	1.00	2010-04-24	0
4 	4 	1096202887  	JAIRO NOEL DURAN QUINTERO               	15	3	1989-10-19	2	CALLE 33 Nº 52-07 LA TOCCA	3167016171	68001	2	1	0	5	45644564	8 	2009-04-22	333	515000	68001	1	52	0.00	1.00	2010-04-25	0
1 	1 	1096188866  	VIVIANA ANDREA HERNANDEZ RAMIREZ        	17	3	1984-11-02	2	CRA 6 Nº 19-49	4545646	68001	2	1	0	5	454564	8 	2009-04-17	334	515000	68001	1	52	0.00	1.00	2010-04-25	0
1 	1 	13540980    	ALEXANDER MANTILLA FLOREZ               	15	3	1978-04-22	1	CRA 6 Nº 49-29	6224514	68001	2	1	0	5	456456	8 	2009-04-17	335	496900	68001	1	52	0.00	1.00	2010-04-25	0
0 	0 	91281218    	WILLIAM ALBERTO VELASCO MURILLO         	29	1	2004-05-10	2	CALLE 70 Nº 44 W-156 KM 4 VIA GIRON	6447300	68001	2	1	0	5	45645456	8 	2009-04-17	336	1560000	68001	1	52	0.00	1.00	2010-04-25	0
2 	2 	13718041    	WILLIAM ENRIQUE MATIZ PEDRAZA           	15	3	1981-12-01	2	fghfghtg	415435	68001	2	1	0	5	2121	8 	2010-03-04	438	515000	68001	1	52	0.00	1.00	2011-03-03	0
0 	0 	91296674    	JAIRO ENRIQUE JIMENEZ BAUTISTA          	29	3	1974-04-05	1	gfsdlgñf	452121	68001	2	1	0	5	52113	8 	2010-03-01	439	3500000	68001	0	52	0.00	1.00	2011-03-01	0
8 	8 	1102366278  	GENNY ROCIO ROMERO RAMIREZ              	17	3	1980-12-01	1	setdkterlñt	4153463	68001	2	1	0	5	341524	8 	2010-03-01	440	515000	68001	1	52	0.00	1.00	2011-02-28	0
3 	3 	63508926    	ELSSY KATHERYN GARZON FRIAS             	16	3	1980-05-10	1	klñklñsdfk	4456	68001	2	1	0	5	5341413	8 	2010-03-01	441	770000	68001	0	52	1.00	1.00	2011-02-28	0
2 	2 	91527583    	FREDY ARMANDO CACERES CAMACHO           	15	3	1983-05-08	2	SAFDDSFGDF	534546	68001	2	1	0	5	4341	8 	2010-04-01	447	535600	68001	1	52	0.00	1.00	2011-04-10	0
1 	1 	1096214156  	OLGA LUCIA ANTURY REYES                 	17	3	1992-01-22	1	CRA 48A 29-36  EL CERRO	6205969	68081	1	1	0	2	4444556	8 	2011-08-18	455	566700	68081	1	52	1.00	1.00	2011-05-15	0
0 	0 	37749364    	AMILDE SANCHEZ SOLER                    	29	1	1980-04-13	1	CRA. 23 N° 30-25 AP 501 TORRE 2	3152130752	68001	1	5	2	3	414124	8 	2015-02-04	720	2500000	68001	0	51	0.00	1.00	2013-04-18	0
3 	3 	1095811608  	CAMILO ANDRES RIATIGA BONILLA           	15	3	1992-03-24	2	CALLE 105A N° 41A-71	3183272628	68001	1	1	0	2	252525	8 	2014-02-21	722	680000	68001	1	52	1.00	1.00	2013-04-17	0
4 	4 	1096201612  	ANGIE SULAY CELIS CONTRERAS             	17	3	1988-05-25	1	KLDLADKLKAD	44545	68001	2	1	0	5	5464564	8 	2009-11-23	406	515000	68001	1	52	0.00	1.00	2010-11-22	0
4 	4 	1098612968  	LEIDY XIOMARA BARBOSA ALQUICHIRE        	41	3	1986-02-22	1	ADKKLKLÑKLDA	44654654	68001	2	1	0	5	54654564	8 	2009-11-20	407	515000	68001	1	52	0.00	1.00	2010-11-22	0
4 	4 	1033647618  	JOHANA CAROLINA LONDOÑO CORREA          	17	3	1987-09-07	1	ADLÑKLÑDÑAKDK	45645646	68001	2	1	0	5	554546	8 	2009-11-20	408	515000	68001	1	52	0.00	1.00	2010-11-20	0
2 	2 	91530378    	ANDRES RICARDO RODRIGUEZ SANTAMARIA     	15	3	1985-12-01	2	FGDCHGRF	14245687	68001	2	1	0	5	353436	8 	2010-01-08	415	515000	68001	1	52	0.00	1.00	2011-01-07	0
3 	3 	1075247106  	LEIDY PAOLA SEPULVEDA NAVAS             	17	3	1991-09-07	1	SAD FSDTFGRTDYG	14175253	68001	2	1	0	5	435	8 	2010-01-09	416	515000	68001	1	52	0.00	1.00	2011-01-08	0
2 	2 	91529181    	DIEGO FERNANDO HERNANDEZ AVILA          	15	3	1986-12-10	2	BFDHGTGFDHGFD	5643654	68001	2	1	0	5	4534	8 	2010-04-02	417	515000	68001	1	52	0.00	1.00	2011-01-11	0
3 	3 	91516835    	JOSE EFRAIN CASTRO MACIAS               	15	3	1986-12-01	2	DSAFDESTERD	465453	68001	1	1	0	2	12131	8 	2010-01-12	418	535600	68001	1	52	0.00	1.00	2011-01-11	0
2 	2 	1098712825  	ELISA TATIANA MANTILLA GONZALEZ         	17	3	1986-01-01	1	DSFSGREGFD	2423416	68001	2	1	0	5	536435	8 	2010-01-12	419	515000	68001	1	52	0.00	1.00	2011-01-11	0
0 	0 	1098647960  	ADRIANA CAROLINA RIVERA ZABALA          	29	1	1988-01-13	1	CALLE 11 28-	54654654	68001	2	1	0	5	32131	8 	2010-01-12	420	680000	68001	1	51	0.00	1.00	2011-01-15	0
7 	7 	63555993    	DERLY VIVIANA MEJIA RAMIREZ             	17	3	1984-12-01	1	ETAPA 11 MZ D ST E CS 9 BETANIA NORTE	3158674323	68001	3	1	0	2	545454545	40	2010-05-16	456	515000	68001	1	52	0.00	1.00	2011-05-16	0
7 	7 	1098679136  	JAVIER ANDRES BARAJAS ROJAS             	15	3	1989-12-07	2	CALLE 105 29-08 DIAMANTE 1	6829422	68001	1	1	0	2	534354230123	96	2010-05-26	457	515000	68001	1	52	0.00	1.00	2011-05-26	0
7 	7 	1098638394  	INGRID JULIETH DIAZ PABON               	17	3	1987-07-13	1	COLSEGUROS NORTE BLOQUE 3 APTO 101	6406374	68001	3	1	1	2	5453455646	40	2010-05-26	458	535600	68001	1	52	0.00	1.00	2011-05-26	0
1 	1 	1096183934  	DARWIN DAVID RINCON CARREÑO             	15	3	1986-06-12	2	MANZANA B CASA 18	6024120	68081	3	1	0	2	5454050453452	19	2010-05-27	459	535600	68081	1	52	0.00	1.00	2011-05-27	0
2 	2 	1129567116  	LEONARDO ANDRES GARRIDO GUARIN          	15	3	1986-04-20	2	BALCON DEL TEJAR 5 PORTERIA T-4 APTO 301	3116769208	68001	1	1	0	2	4641684654	8 	2010-05-29	460	566700	68001	1	52	1.00	1.00	2011-05-29	0
8 	8 	92031662577 	JULIETH MAYERLING RONDON RAMIREZ        	17	3	2004-05-10	1	REWTF	75272455	68001	2	1	0	2	44545234	8 	2009-12-23	411	515000	68001	1	52	0.00	1.00	2010-05-10	0
1 	1 	63469877    	MARIA HELENA CAMACHO GUILLEN            	17	3	2004-05-10	1	FDGSDGF	547274524	68001	2	3	0	2	146363	8 	2009-12-19	412	515000	68001	1	52	0.00	1.00	2010-12-22	0
1 	1 	1039682781  	JENNIFER TATIANA CASTILLO               	17	3	2004-05-10	1	DAFDFGF	745742	68001	2	1	0	5	4554352	8 	2009-12-19	413	532500	68001	1	52	0.00	1.00	2010-12-25	0
7 	7 	92031668311 	JURLEY TATIANA MACIAS QUIJANO           	17	3	2004-05-10	1	FDSGDSGFDHFD	4542361	68001	2	1	0	5	46542	8 	2009-12-19	414	535600	68001	1	52	0.00	1.00	2010-12-10	0
9 	9 	1098691032  	SANDRA YISETH CALDERON SEQUEDA          	17	3	1990-08-04	1	CRA 15 53-40  OASIS FLORIDA	6493963	68001	1	2	1	2	453453413574	8 	2010-07-24	466	535600	68001	1	52	0.00	1.00	2011-07-23	0
8 	8 	1095799436  	LUZ AMALIA PRIETO HERNANDEZ             	17	3	1988-12-29	1	MESA DE RUITOQUE VEREDA LA ESPERANZA	6844734	68001	3	1	0	2	42445243	8 	2014-09-13	467	680000	68001	1	52	1.00	1.00	2011-07-28	0
0 	0 	63366987    	CLAUDIA CECILIA CORZO PABON             	29	1	2010-12-04	1	CRA 26 34-18 APTO 1205  ANTONIA SANTOS	6343195	68001	2	1	1	5	12121545	8 	2011-01-01	468	6962800	68001	1	51	0.00	1.00	2011-07-27	0
8 	8 	1095808861  	MISLEYDY DIAZ DIAZ                      	17	3	1991-05-21	1	MESA DE RUITOQUE VEREDA BUENOS AIRES	33138071197	68001	1	5	0	2	5434560	8 	2010-07-30	469	566700	68001	1	52	1.00	1.00	2011-07-30	0
2 	2 	63538797    	ANGELA BARRIOS TORRES                   	17	3	1983-01-23	1	CALLE 70 44W-156 KM 4 VIA GIRON	6370099	68001	3	1	3	3	4787777565	8 	2010-08-07	470	535600	68001	1	52	0.00	1.00	2011-08-07	0
9 	9 	1098610976  	LILIANA MARCELA CAMARGO BARRAGAN        	17	3	1985-11-23	1	CALLE 112 32A-33   EL DORADO FLORIDA	6315606	68001	2	5	1	3	5454604	8 	2010-08-12	471	535600	68001	1	52	0.00	1.00	2011-08-12	0
4 	4 	1096208836  	MARIA GABRIELA GONZALEZ FORERO          	39	3	1990-06-07	1	CRA 46 36B-93 TAMARINDOS CLUB	3133955726	68081	1	1	0	2	55454545	8 	2010-08-13	472	535600	68081	1	52	0.00	1.00	2011-08-13	0
3 	3 	1102349862  	MARTHA LILIANA OLARTE FLOREZ            	17	3	1985-12-12	1	CALLE 43 23-06 EL POBLADO GIRON	3168563228	68001	1	5	0	3	546514861456	8 	2011-05-02	473	535600	68001	1	52	0.00	1.00	2011-09-07	0
8 	8 	1102353725  	ADRIANA KATHERINE DIAZ ESCOBAR          	17	3	1987-09-16	1	CRA 15C 19-03 PASEO DEL PUENTE PCTA	3115285853	68001	3	1	1	2	546545646	8 	2010-09-11	474	566700	68001	1	52	1.00	1.00	2011-09-11	0
1 	1 	1096201753  	YAJAIRA ELIANA ALVAREZ ARANGO           	17	3	1989-02-22	1	CALLE 26  47-174 BELLAVISTA	6106880	68081	3	1	0	2	236598	8 	2010-11-02	482	515000	68081	1	52	0.00	1.00	2011-11-01	0
2 	2 	1095800724  	MONICA MARCELA GUARGUATI FLOREZ         	17	3	1989-03-08	1	CAKKE 7  12-18 FLORIDABLANCA	3112155938	68276	1	5	0	2	235685214	8 	2010-12-07	507	535600	68001	1	52	0.00	1.00	2011-12-06	0
12	12	1072254925  	NIUBAR JOSE PERTUZ CONDE                	33	3	1988-08-29	2	CRA. 25A N° 55N-26	3203958451	68001	1	1	0	3	2525	8 	2012-04-20	725	770000	68001	0	52	1.00	1.00	2013-04-19	0
8 	8 	1095806899  	JESSICA PATRICIA GALINDO                	17	3	2004-05-01	1	CALLE 70 44W-156 KM 4 VIA GIRON	6370099	68001	1	1	0	2	5654545	8 	2010-04-01	461	515000	68001	1	52	0.00	1.00	2011-04-01	0
8 	8 	1095794560  	JENNY PAOLA GALVAN GOMEZ                	60	3	1987-12-22	1	MESA DE RUITOQUE VEREDA LOS PINARES	3174326764	68001	1	1	1	2	45154544	8 	2010-06-05	463	650000	68001	1	52	1.00	1.00	2011-06-05	0
9 	9 	1100955066  	JULIANA ANDREA RIVEROS ARENAS           	17	3	1989-06-05	1	CALLE 64A  17A-92 LA CEIBA	6949241	68001	2	5	1	2	235698	8 	2010-12-01	496	515000	68464	1	52	0.00	1.00	2011-11-30	0
8 	8 	1098698573  	GEIMY CAROLINA HERRERA GARCIA           	17	3	1990-12-10	1	CALLE 148  38-20 VILLA REAL DEL SUR	3134068138	68276	1	1	0	2	235698	8 	2010-12-01	497	680000	68276	1	52	1.00	1.00	2011-12-01	0
9 	9 	13872708    	WILLIAM RUEDA HERRERA                   	15	3	1981-05-30	2	calle 39  32-15  QUINTA DEL LLANITO GIRO	6467313	68307	1	4	0	2	235698	8 	2010-12-06	499	515000	68001	1	52	0.00	1.00	2011-12-05	0
9 	9 	13512764    	HENRY CUCHIA MANTILLA                   	15	3	1977-06-25	2	CALLE 69  10C-36 PABLO VI	6431788	68001	2	5	0	2	235698	8 	2010-12-06	500	535600	68001	1	52	0.00	1.00	2011-12-05	0
2 	2 	1102350133  	JHON ALEXIS RAMIREZ ROJAS               	15	3	1986-06-08	2	CALLE 3A  9C-12 VILLANUEVA PIEDECUESTA	6559418	68547	1	1	0	2	6589562	8 	2010-12-01	501	535600	68547	1	52	0.00	1.00	2011-11-30	0
9 	9 	1095923175  	ANDRES FELIPE MOLINA ALVAREZ            	15	3	1990-09-24	2	PORTAL DE SAN SEBASTIAN TORRE 3 APTO 202	3134673755	68001	2	5	0	2	235698	8 	2010-12-06	502	532500	68001	1	52	0.00	1.00	2011-12-05	0
1 	1 	13568102    	HAIR AGUIRRE PIÑERES                    	15	3	1987-05-13	2	KLWKDLAKDLAK	6224714	68001	2	1	0	5	45464	8 	2008-10-01	311	515000	68001	1	52	0.00	1.00	2009-10-01	0
8 	8 	1102361012  	MARGY LICETH CASTILLO DIAZ              	17	3	1989-08-13	1	CRA 16N  1B-08 SANFRANCISCO PIEDECUESTA	6560453	68547	1	1	0	2	2365	8 	2012-11-09	483	566700	68001	1	52	1.00	1.00	2011-11-01	0
4 	4 	30083035    	MARCELA CAMACHO CONTRERAS               	41	3	1969-05-22	1	CRA 50  14-58	3132831823	68081	2	2	0	3	23569	8 	2010-10-24	478	535600	68081	1	52	0.00	1.00	2011-10-23	0
1 	1 	1096216247  	KATHERINE SANDOVAL BLANCO               	17	3	1992-06-18	1	CRA 19  49-37	6203547	68081	1	5	0	2	52658	8 	2010-10-24	479	535600	68547	1	52	0.00	1.00	2011-10-23	0
7 	7 	1098683046  	SAMMI LOPEZ REYES                       	15	3	1990-12-01	2	WR WFDG	46345	68001	2	1	0	5	423	8 	2011-08-19	442	535600	68001	1	52	0.00	1.00	2011-04-28	0
1 	1 	111812433   	CINDY CAROLINA ORTIZ LONDOÑO            	17	3	1987-12-06	1	FPKSDKFKD	565635	68081	2	1	0	5	535233	8 	2010-01-28	421	515000	68081	1	52	0.00	1.00	2011-01-15	0
7 	7 	1098688483  	MAYERLI GELVEZ GARCIA                   	17	3	1990-03-14	1	CALLE 5  23-30 COMUNEROS	3187611681	68001	1	5	0	3	2356987	8 	2010-12-09	509	535600	5615 	1	52	0.00	1.00	2011-12-08	0
9 	9 	1098728800  	MARLY YARITZA DELGADO GUERRERO          	17	3	1992-08-13	1	SECTOR 6 BLOQUE 10-10 APTO 401 BUCARICA	3106488091	68001	1	5	0	3	235698	8 	2010-12-09	510	535600	68001	1	52	0.00	1.00	2011-12-09	0
4 	4 	1098612943  	DORIS HELENA DAVILA RODRIGUEZ           	17	3	1986-03-08	1	CALLE 33  34-04 EL REFUGIO	3115643006	68081	1	5	0	2	235698521	8 	2010-12-08	511	535600	68081	1	52	0.00	1.00	2011-12-07	0
9 	9 	22736320    	JULIE VIVIANA OROZCO QUINTERO           	17	3	1982-11-27	1	CALLE 22  30-34 GALLINERAL GIRON	3112432687	68307	1	5	0	2	235698	8 	2010-12-10	513	535600	68001	1	52	0.00	1.00	2011-12-09	0
4 	4 	1095807943  	DIVA CAROLINA DURAN MONSALVE            	17	3	1990-12-16	1	CRA 19  49-37	6203547	68081	3	5	0	2	235689	8 	2010-12-10	514	535600	68001	1	52	0.00	1.00	2011-04-08	0
2 	2 	1095807388  	JUAN DAVID CABALLERO GARCIA             	15	3	1990-12-06	2	CALLE 27A  32C-40 EL LIMONAR	6108545	68081	1	1	0	2	235412	8 	2011-07-03	515	566700	68276	1	52	1.00	1.00	2011-12-09	0
9 	9 	1098679248  	JOHANNA ANDREA ROJAS RIOS               	17	3	1989-11-19	1	CRA 8AW  58-22 MUTIS	6418854	68001	1	5	0	2	235698	8 	2010-12-06	503	535600	68001	1	52	0.00	1.00	2011-12-05	0
3 	3 	13715205    	EDWARD VILLANUEVA MARTINEZ              	34	3	1977-09-16	2	CALLE 58  1W-08 PISO 3 MUTIS	3163973920	68001	1	5	0	2	235698	8 	2010-12-06	504	900000	68001	1	52	1.00	1.00	2011-12-05	0
9 	9 	1065870255  	LUZ MERYS RUEDA RODRIGUEZ               	17	3	1987-06-19	1	CRA 5 OCC-  44-47 CAMPO HERMOSO	3182774220	68001	1	5	0	2	2356984	8 	2010-12-09	516	566700	13074	1	52	1.00	1.00	2011-12-08	0
2 	2 	1098602090  	AURA MERCEDES CARREÑO ZAMBRANO          	36	3	1985-09-02	1	TRANSV ORIENTAL  47-36 CONJUNTO PIEMONTI	6493583	68276	1	1	0	4	256897	8 	2010-12-11	517	1300000	68001	1	52	0.00	1.00	2011-12-10	0
9 	9 	1095923911  	SANDRA MILENA AMAYA GARZON              	18	3	1990-12-22	1	CRA 32  46-09 BELLAVISTA GIRON	6460144	68307	1	1	0	2	235697	8 	2010-12-11	518	1200000	25183	0	52	1.00	1.00	2011-12-10	0
9 	9 	1098725367  	YULY ANDREA RINCON ROJAS                	17	3	1992-08-14	1	CRA 17 A  55-76 RICAUTE	6391547	68001	1	5	0	2	236598	8 	2010-12-11	519	566700	68001	1	52	1.00	1.00	2011-12-10	0
2 	2 	1095798962  	TATIANA PAOLA RODRIGUEZ MANCILLA        	17	3	1988-05-18	1	CALLE 20  29-28 SAN ALONSO	6459184	68001	1	6	0	2	235698	8 	2010-12-11	520	535600	68001	1	52	0.00	1.00	2011-12-10	0
3 	3 	42447836    	LEIDY DIANA COGOLLO ARIAS               	17	3	1980-06-05	1	CALLE 18  19-57 SAN FRANCISCO	3163827882	68001	3	5	0	2	235984125	8 	2010-12-11	521	535600	20770	1	52	0.00	1.00	2011-12-10	0
1 	1 	1096195908  	VERONICA RODRIGUEZ SANABRIA             	33	3	1988-07-28	1	CALLE 49  13-72 COLOMBIA	3142622112	68081	2	5	0	2	235698	8 	2010-12-14	522	840000	68001	0	52	1.00	1.00	2011-12-13	0
7 	7 	63538599    	MARTHA LILIANA NOVOA CARREÑO            	17	3	1982-12-10	1	CRA 14W  46-22 CAMPOHERMOSO	3163738898	68001	1	6	0	3	21546	8 	2010-12-14	523	535600	20770	1	52	0.00	1.00	2011-12-14	0
9 	9 	63558388    	LISNEY NAILU MACIAS CARDENAS            	17	3	1984-09-03	1	CALLE 17  20A-50 EL CRISTAL	3123122951	68001	1	2	0	2	235698	8 	2010-12-22	527	566700	68001	1	52	1.00	1.00	2011-12-21	0
7 	7 	91509600    	CARLOS EDUARDO CIPAGAUTA BARAJAS        	15	3	1982-05-20	2	CRA 29  72-35 ANTONIA SANTOS SUR	6816642	68001	1	6	0	2	235698	8 	2010-12-15	524	535600	68001	1	52	0.00	1.00	2011-12-14	0
8 	8 	13925966    	RICARDO FLOREZ DUARTE                   	12	3	1972-08-08	2	CALLE 1A BIS  5-37 CASA 178 PASEO CATALU	3116685850	68547	2	7	0	4	235698	8 	2010-12-27	525	2000000	68001	1	52	0.00	1.00	2011-12-16	0
7 	7 	1098711290  	SLENDY RUEDA RUEDA                      	60	3	1991-09-19	1	CRA 8W  64-42 MONTERREDONDO	6410836	68001	1	1	0	2	23564	8 	2013-07-19	529	680000	68895	1	52	1.00	1.00	2012-01-04	0
2 	2 	13743737    	LUIS HIGUERA IBAÑEZ                     	35	3	1980-05-14	2	CARRERA 5  15-21 SANTA ANA	6395129	68276	1	5	0	2	235698	8 	2011-02-23	547	680000	68001	1	52	0.00	1.00	2012-02-22	0
4 	4 	1096189643  	ALFREDO MARTINEZ GOMEZ                  	15	3	1987-05-03	2	dadad	646544	68001	2	1	0	5	454564	8 	2012-07-05	312	680000	68001	1	52	1.00	1.00	2009-10-01	0
9 	9 	1102366957  	YULIETH VANESSA GARCIA FUENTES          	39	3	1991-06-27	1	METROPOLIS II TORRE 2 APTO 504	6419578	68001	3	5	0	3	235698	8 	2010-12-10	512	566700	68001	1	52	1.00	1.00	2011-12-09	0
3 	3 	1098694489  	CRISTIAN RENE VELASQUEZ HERNANDEZ       	15	3	1990-11-01	2	CALLE 19  21-31 APTO 201 SAN FRANCISCO	6322639	68001	1	5	0	2	2356852	8 	2010-12-06	498	535600	68001	1	52	0.00	1.00	2011-12-06	0
7 	7 	91230441    	JOSE IGNACIO CORREA                     	19	3	1978-12-01	1	VSDFFLGLÑRDFKG	56463	68001	2	1	0	5	53434	51	2011-01-03	443	1872000	68001	1	52	0.00	1.00	2011-12-01	0
0 	0 	1098685932  	YURI ALEXANDRA RODRIGUEZ URIBE          	29	1	1990-12-01	1	DAFASDFDS	35663	68001	2	1	0	5	23131	8 	2010-03-23	444	650000	68001	1	51	0.00	1.00	2011-03-01	0
0 	0 	1095801162  	YUDI ANDREA CAMACHO DURAN               	29	1	1980-12-01	1	FF.SALFÑL	545321	68001	2	1	0	5	5354	8 	2010-03-20	445	680000	68001	1	51	0.00	1.00	2011-12-01	0
0 	0 	37941653    	OLGA LUCIA NARANJO MARIN                	29	1	1963-05-27	1	SDASFDG	564634	68001	2	1	0	5	435543	8 	2010-03-17	446	3600000	68001	1	51	0.00	1.00	2011-01-03	0
8 	8 	63342106    	LINA DOLORES OSORIO PORRAS              	42	3	1968-10-08	1	KDALKDLAKD	655565	68001	2	1	0	5	545646	8 	2009-09-30	374	496900	68001	1	52	0.00	1.00	2010-09-29	0
3 	3 	1095786670  	EDINSON CHAPARRO CONTRERAS              	36	3	1985-12-07	2	CRA 8W-62-48 CASA D-7 MUTIS	6410678	68001	4	1	0	2	235698	8 	2010-12-01	505	1300000	68001	1	52	0.00	1.00	2011-11-30	0
5 	5 	63540864    	0                                       	42	3	2004-05-10	1	KADKALKD	545645646	68001	2	1	0	5	45456456	8 	2009-09-30	375	496900	68001	1	52	0.00	1.00	2010-09-29	0
8 	8 	37544391    	YANETH MENDEZ DELGADO                   	42	3	2004-05-10	1	HAKJDHKAHD	564545646	68001	2	1	0	5	564545	8 	2009-09-30	376	496900	68001	1	52	0.00	1.00	2010-09-30	0
8 	8 	37618242    	DIANA ADELAIDA DELGADO VILLAMIZAR       	42	3	2004-05-10	1	ASADOADIO	4465464	68001	2	1	0	5	544564	8 	2009-09-30	377	496900	68001	1	52	0.00	1.00	2010-09-29	0
8 	8 	63450391    	LAURA MARIA LEON MANTILLA               	42	3	2004-05-10	1	DKLAKDLAKD	54564564	68001	2	1	0	5	4554644	8 	2009-09-30	378	496900	68001	1	52	0.00	1.00	2010-09-29	0
8 	8 	1095917286  	JOHANNA DIAZ DIAZ                       	42	3	2004-05-10	1	XAKDADÑKLAKÑ	564564564	68001	2	1	0	5	16156456	8 	2009-09-30	379	496900	68001	1	52	0.00	1.00	2010-09-29	0
8 	8 	1095809598  	ANDREA DIAZ CACERES                     	42	3	2004-05-10	1	ADKALDKALKD	45456446	68001	2	1	0	5	5454564	8 	2009-09-30	380	496900	68001	1	52	0.00	1.00	2010-09-30	0
1 	1 	1116663911  	SINDY JAENCY MALDONADO GONZALEZ         	17	3	1989-06-25	1	CENTRO ECOPETROL CAMPO 22	3123406644	68081	3	5	0	2	235698	8 	2010-12-16	528	535600	85430	1	52	0.00	1.00	2011-12-15	0
4 	4 	1099367231  	RUTH AMPARO VEGA ANAYA                  	17	3	1990-02-07	1	BARRIO TORCOROMA BARRANCABERMEJA	3118690362	68081	3	2	0	2	235698	8 	2012-03-09	530	566700	68217	1	52	1.00	1.00	2012-01-08	0
3 	3 	1098655490  	EDINSON LOPEZ SANTAMARIA                	35	3	1988-02-21	2	CALLE 23  20-18 VILLA ROSA	6404204	68001	1	5	0	3	23569852	8 	2011-01-25	533	680000	68001	1	52	0.00	1.00	2012-01-24	0
7 	7 	1098712645  	INGRID XIOMARA ORTEGA CONTRERAS         	17	3	1991-08-01	1	CRA 12  104A-28 MANUELA BELTRAN	6373058	68001	1	5	0	3	2545621	8 	2011-01-25	534	535600	68001	1	52	0.00	1.00	2012-01-24	0
3 	3 	63539200    	LUZ STELLA RANGEL RUEDA                 	17	3	1983-04-05	1	CRA 12  64-14 MIRAMAR	6730281	68001	1	5	0	2	23598546	8 	2011-01-26	535	535600	68001	1	52	0.00	1.00	2012-01-25	0
3 	3 	1098643511  	JHON EMERSON GUIO BRICEÑO               	15	3	1987-10-07	2	CALLE 32  10CC-33	6940583	68001	1	1	0	2	235698	8 	2011-01-29	536	680000	68001	1	52	1.00	1.00	2012-01-28	0
1 	1 	1096198791  	CINDY JOHANNA REINA SILVA               	17	3	1989-02-12	1	CRA 8  47-87 CALLEJON GUTIERREZ	3102931509	68081	1	5	0	2	23569845	8 	2011-02-02	537	566700	68081	1	52	1.00	1.00	2012-02-01	0
2 	2 	63523645    	LUZ STELLA SOLANO CAMACHO               	16	3	1981-11-13	1	CRA 18B  15N-31 VILLA ROSA	6404666	68001	4	5	0	3	23569521	8 	2011-02-07	538	800000	68895	1	52	1.00	1.00	2012-02-05	0
1 	1 	1096198522  	CARLOS ANDRES CASTRO CADENA             	15	3	1989-01-08	2	CRA 6  49-29	6224514	68081	1	5	0	2	235698	8 	2011-01-09	531	566700	68081	1	52	1.00	1.00	2012-01-08	0
3 	3 	63352564    	LUZ VIANEY RINCON SUAREZ                	31	3	1970-02-28	1	CALLE 147  58A-66 MANZANA 6 RECODOS FLOR	6584076	68276	4	1	0	3	26598542	8 	2011-02-08	541	1000000	68001	1	52	0.00	1.00	2012-02-07	0
3 	3 	1101683539  	ROBINSON FABIAN CALDERON HOLGUIN        	15	3	1986-10-31	2	CALLE 4  3A-55 LA TACHUELA PIEDECUESTA	3124148587	68547	1	5	0	2	52653245	8 	2011-08-02	542	535600	68689	1	52	0.00	1.00	2012-02-10	0
2 	2 	63552920    	SANDRA MILENA VARGAS PARRA              	17	3	1983-12-17	1	SAFSNFJDG	6320505	68001	2	3	0	2	12132	8 	2011-04-19	409	535600	68001	1	52	0.00	1.00	2010-12-10	0
2 	2 	1098682133  	DORIAN LORENA REYES NAVARRO             	39	3	1989-12-25	1	GFDÑGLTFDH	6136231	68001	2	1	0	2	32121	25	2012-02-05	410	566700	68001	1	52	1.00	1.00	2010-12-09	0
2 	2 	1098623929  	GENIFER XIMENA PICO SANCHEZ             	17	3	1986-09-27	1	CALLE 115  45-15 ZAPAMANGA 4	6772349	68276	2	2	0	2	2569845	8 	2011-02-12	543	535600	68001	1	52	0.00	1.00	2012-02-11	0
7 	7 	1095918700  	NATHALY SOLANO CASTRO                   	17	3	1989-08-02	1	CRA 22  48-16 EL POBLADO	6810946	68307	1	5	0	2	235698	8 	2010-12-06	545	535600	68001	1	52	0.00	1.00	2011-12-05	0
3 	3 	37520638    	CARMEN ALICIA VELASQUEZ QUINTERO        	36	3	1980-04-13	1	CRA 25  35-21 TORRE 2 APTO 405 SAN MARCO	3115622258	68001	2	2	0	4	235698	8 	2011-02-15	546	1300000	68079	1	52	0.00	1.00	2011-02-15	0
1 	1 	65731095    	LUZ STELLA RUBIANO RODRIGUEZ            	41	3	1966-12-16	1	CRA 19  49-37	6203547	68081	2	5	0	2	25698	8 	2011-02-25	548	535600	68081	1	52	0.00	1.00	2011-02-25	0
0 	0 	63489810    	SANDRA LILIANA TAVERA PEREZ             	29	1	1973-12-09	1	calle 147  22-189 QUINTAS DEL PALMAR	3108518206	68276	1	1	0	4	235698	8 	2011-03-02	549	3000000	68001	1	51	0.00	1.00	2012-03-01	0
2 	2 	37713873    	YANETH MENESES BENITEZ                  	16	3	2013-11-28	1	AVENIDA EL TEJAR 104-25 CASA 7	6318127	68001	3	5	0	2	2456120	8 	2014-07-03	550	1000000	68679	0	52	1.00	1.00	2012-03-04	0
7 	7 	1098733004  	SANDRA LUCIA ACOSTA GARCIA              	39	3	1993-01-21	1	CRA 26  20-74 EDF. XENIA APTO 401	3214878886	68001	1	5	0	2	2562314	8 	2011-03-05	551	535600	76250	1	52	0.00	1.00	2012-03-04	0
7 	7 	1099622181  	TATIANA SIRLEY VILLAMIZAR               	17	3	1988-07-01	1	CRA 24  24-20 SAN FRANCISCO	6347285	68001	1	5	0	2	23569854	8 	2011-03-17	564	680000	68169	1	52	1.00	1.00	2012-03-16	0
3 	3 	1099364647  	SINDY TATIANA HERNANDEZ CARVAJAL        	40	3	1988-06-07	1	CRA 38W  59-16 ESTORAQUES	6416110	68001	3	5	0	2	2546	8 	2011-03-05	553	800000	47245	1	52	1.00	1.00	2012-03-04	0
7 	7 	1098687193  	CINDY MARCELA MELGAREJO MAYORGA         	17	3	1990-05-18	1	CRA 28  11-39 SAN ALONSO	6705718	68001	1	1	0	2	235697	8 	2011-03-05	554	535600	68152	1	52	0.00	1.00	2012-03-04	0
0 	0 	1098693946  	LISDI BRAJANA RODRIGUEZ ROMAN           	29	3	1990-10-07	1	CRA 27W  64-53 MONTERREDONDO	3158219263	68001	2	2	0	3	235698	8 	2011-03-09	555	900000	68001	0	52	1.00	1.00	2012-03-08	0
0 	0 	1020745702  	YENNY PAOLA CASALLAS                    	29	1	1989-09-26	1	cra 12  24-59	3115464723	68008	3	5	0	3	236412	8 	2011-02-02	539	750000	25513	1	51	1.00	1.00	2012-02-01	0
1 	1 	37581582    	MAYORLI SALCEDO ARDILA                  	17	3	1986-01-03	1	CALLE 77  77-46 BELEN	316446961	68081	1	5	0	2	2569845	8 	2011-02-02	540	535600	68081	1	52	0.00	1.00	2012-02-01	0
1 	1 	1096212532  	LUIS EDUARDO MARTINEZ VIANA             	15	3	1991-10-03	2	CALLE 27A  33-16 EL LIMONAR	6030309	68081	1	2	0	2	235698	8 	2011-03-11	557	535600	68081	1	52	0.00	1.00	2012-03-10	0
2 	2 	1095808754  	MARIA ALEJANDRA MENDOZA PICO            	17	3	1991-02-18	1	SECTOR 20  21-17 APTO 113 BUCARICA	6996710	68276	1	1	0	3	235698	8 	2011-03-12	561	535600	68001	1	52	0.00	1.00	2012-03-11	0
8 	8 	1098729102  	EDWING MAURICIO HERNANDEZ PEDRAZA       	44	3	1992-11-03	2	CRA 26  10-48 LA UNIVERSIDAD	6452063	68001	1	5	0	2	236598	8 	2013-08-27	506	700000	68001	1	52	1.00	1.00	2011-11-30	0
2 	2 	1004966303  	FRANKLIN LEONARDO BALLEN CORONEL        	15	3	1989-06-15	2	CRA 52  102-11 ARRAYANES FLORIDABLANCA	6814668	68276	3	2	0	2	235698542	8 	2013-07-19	556	680000	54001	1	52	1.00	1.00	2012-03-08	0
2 	2 	1121823575  	MARIA RUTH PINEDA RAMIREZ               	17	3	1986-08-09	1	DIAGONAL 34  197A-16 PARAGUITAS	3114679078	68276	1	1	0	3	25698	8 	2011-03-12	562	535600	68001	1	52	0.00	1.00	2012-03-11	0
3 	3 	1095917302  	MIGUEL ANGEL SANABRIA HERNANDEZ         	15	3	1989-05-05	2	DIAGONAL 9  20-26 ARENALES	3172458758	68307	2	1	0	2	236598	8 	2011-01-15	532	680000	68307	1	52	0.00	1.00	2012-01-14	0
1 	1 	1007949009  	WILLIAM MORALES FLOREZ                  	15	3	1985-12-12	2	tryutyiuyiy	415454	68081	2	1	0	5	434	8 	2010-02-01	423	515000	68081	1	52	0.00	1.00	2011-01-31	0
3 	3 	1098693004  	ERIKA TATIANA MUSKUS GELVEZ             	17	3	1985-12-12	1	gyrtuytuiy	4553	68001	2	1	0	5	1412	8 	2011-03-19	424	535600	68001	1	52	0.00	1.00	2011-01-31	0
0 	0 	63502338    	ELIZABETH PINILLA RINCON                	29	1	1974-03-09	1	CRA 40A  105-15 SAN BERNARDO	6773910	68276	1	1	0	2	235698	8 	2011-03-01	563	535600	68001	1	51	0.00	1.00	2012-02-28	0
0 	0 	1045669960  	JANETH FORERO RAMIREZ                   	29	1	1988-04-28	1	calle 47 nº 22 - 31	3205416410	68307	1	5	0	3	235698521	8 	2014-02-15	565	1000000	81736	1	51	1.00	1.00	2012-03-21	0
7 	7 	91534858    	ALEXANDER ESTUPIÑAN FLOREZ              	10	3	1984-09-21	2	CRA 12D  103C-19 MANUELA BELTRAN	6376169	68001	1	5	0	2	236598	8 	2011-03-24	566	900000	5615 	1	52	1.00	1.00	2012-03-23	0
0 	0 	1098604574  	GLADYS ROCIO BELTRAN VILLAMIZAR         	29	3	1985-10-12	1	CRA 18B  15N-67 CASA 4 VILLAROSA	3204473042	68001	1	5	0	3	236598542	8 	2011-03-29	567	4200000	68001	0	52	0.00	1.00	2012-03-27	0
0 	0 	91277148    	JOSE LUIS COA ZORRO                     	29	1	1975-02-09	2	UR. BOSQUE SEC C AGRUP S TORRE 4 AP 102B	6371119	68276	2	5	0	4	41545454	8 	2011-04-11	569	1500000	68575	0	51	0.00	1.00	2012-04-10	0
1 	1 	1096183748  	LUIS JONNATHAN ZULUAIKA TORRES          	15	3	1985-11-07	2	calle 36 a nº 77 -55	3143688691	68081	1	5	0	2	55454	8 	2011-04-02	568	535600	68081	1	52	0.00	1.00	2012-04-01	0
7 	7 	80810289    	ANGEL MARIA HERNANDEZ TURCA             	15	3	1984-05-07	2	CALLE 104 Nº 16A - 62	3115849383	68001	2	5	0	3	2553535	8 	2011-04-11	570	535600	1001 	1	52	0.00	1.00	2012-04-10	0
1 	1 	13569404    	OSMAN DE JESUS NAVARRO MORALES          	15	3	1984-12-15	2	CALLE 52A Nº 41 - 28	3202074817	68081	1	2	0	2	5454545	8 	2011-04-06	571	535600	47707	1	52	0.00	1.00	2011-04-05	0
1 	1 	28070539    	SANDRA PATRICIA CASTRILLON GALEANO      	17	3	1981-07-09	1	TRV. 45 Nº 57 - 54	3144856920	68081	2	5	0	2	1424	8 	2011-04-11	572	535600	5579 	1	52	0.00	1.00	2012-04-10	0
4 	4 	1096186026  	NELLY MARLEY JARAMILLO BAUTISTA         	17	3	1985-04-25	1	lkslksjkogj	2545	68081	2	5	0	2	54545	8 	2011-04-14	574	535600	68081	1	52	0.00	1.00	2012-04-13	0
7 	7 	1098617703  	LEIDY YUSELY QUIROGA DURAN              	17	3	1986-01-06	1	calle 49 n° 9c- 36	6496050	68001	2	5	0	3	5454	8 	2011-04-13	575	535600	68001	1	52	0.00	1.00	2012-04-12	0
7 	7 	1098721370  	JURLEY TATIANA MACIAS QUIJANO           	17	4	1992-03-16	1	CALLE 43 N° 26-31	3185397220	68001	1	5	0	2	5465	8 	2009-12-19	576	535600	68001	1	52	0.00	1.00	2012-03-17	0
9 	9 	1102365957  	MIKE HENRY SALAZAR AMAYA                	15	3	1991-03-12	2	CALLE 1A N° 4A -11	6901418	68547	1	5	0	2	5141564	8 	2011-04-16	577	566700	68001	1	52	1.00	1.00	2012-04-15	0
3 	3 	1098687096  	LISSETH MAYERLY TORRES LANDAZABAL       	17	3	1990-03-16	1	CALLE 125A N° 66A-35	3168617581	68001	1	5	0	3	54556466	8 	2011-05-05	578	566700	68001	1	52	1.00	1.00	2012-05-04	0
4 	4 	60261054    	NUBIA YADIRA CAÑAS LIZCANO              	42	3	1976-06-14	1	carrera 33 n° 71 - 18	3118831512	68001	3	1	0	2	25451541	8 	2011-04-30	580	535600	68001	1	52	0.00	1.00	2012-04-29	0
1 	1 	1096197804  	MARIVEL CARDENAS AFANADOR               	42	3	1988-11-05	1	CALLE 44 N° 59B - 17	321315130	68081	3	2	0	2	645464	8 	2011-05-07	581	535600	68081	1	52	0.00	1.00	2012-05-06	0
0 	0 	37900833    	KATHERINE FIALLO CASTRO                 	29	1	1984-01-28	1	CALLE 68B N° 10C-12	3174293213	68001	1	5	0	5	5451236	8 	2011-05-09	582	3000000	68679	1	51	0.00	1.00	2012-05-08	0
0 	0 	37724507    	JOHANNA MILENA CUEVAS CELY              	29	1	1978-05-09	1	CALLE 60C N° 16F - 58	3157347074	68001	2	1	1	4	513213	8 	2011-05-09	583	1200000	68001	1	51	0.00	1.00	2012-05-08	0
4 	4 	37651994    	SOLLEY MONSALVE DIAZ                    	17	3	1988-04-05	1	CALLE 30 N° 54-52	6201458	68081	2	1	0	2	5461654	8 	2011-05-08	584	535600	68081	1	52	0.00	1.00	2012-05-07	0
8 	8 	1095791572  	CONSTANTINO ROJAS NIÑO                  	10	3	1985-07-27	2	CR. 19 N° 59-147	6492254	68001	1	5	0	2	65646464	8 	2011-05-12	585	800000	68001	0	52	1.00	1.00	2012-05-11	0
4 	4 	1096203405  	IVONNE ELENA GOMEZ RODRIGUEZ            	17	3	1989-09-27	1	TRANSVERSAL 45 N° 57-16	3118627861	68081	3	5	0	2	5641554	8 	2011-05-19	586	680000	68081	1	52	1.00	1.00	2012-05-18	0
1 	1 	1096214308  	LINDA LUCIA RESTREPO VILLALBA           	17	4	1992-01-20	1	TV 43 Nº 56 BARRIO PROGRESO I ETAPA	3116854248	68081	1	1	0	2	35454	8 	2011-04-09	573	535600	68081	1	52	0.00	1.00	2012-04-08	0
8 	8 	1098626614  	CARLOS ALBERTO VALBUENA MORENO          	15	3	1986-11-12	2	CR. 27 N° 64-86	6446028	68001	1	5	0	2	2131324	8 	2011-05-26	588	680000	68444	1	52	1.00	1.00	2012-05-25	0
2 	2 	1095811713  	ANGY KARELLY TORRES DIAZ                	17	3	1992-03-27	1	SECTOR B TORRE 1 AP 302 BELLAVISTA	6384664	68276	1	5	1	3	11326	8 	2011-05-28	593	535600	68276	1	52	0.00	1.00	2012-05-27	0
0 	0 	1098682904  	JENIFER MARCELA NUÑEZ RUEDA             	29	1	1990-02-24	1	CARRERA 1B CASA 81 CIUDAD BOLIVAR	3182428431	68001	1	5	0	3	54651	8 	2011-06-01	594	650000	68001	1	51	0.00	1.00	2012-05-30	0
2 	2 	88170940    	WILMER FLOREZ                           	14	3	1972-10-13	2	CALLE 112 N° 32A - 33	6315606	68001	2	5	2	3	45452112	8 	2011-06-08	597	800000	68001	1	52	0.00	1.00	2012-06-07	0
9 	9 	1095806631  	SULAY VIVIANA VARGAS DUARTE             	17	3	1990-11-10	1	CR. 21 N° 10B-30	6490506	68001	1	1	0	3	5423154	8 	2011-06-14	602	535600	68001	1	52	0.00	1.00	2012-06-13	0
0 	0 	1098699834  	ANGIE VANESSA CACERES NOCUA             	29	1	1991-01-27	1	CRA. 12W N° 60 BIS-79	6942111	68001	1	5	0	3	12336	8 	2012-01-16	695	650000	68001	1	51	1.00	1.00	2013-01-15	0
4 	4 	22524543    	LIDYS MILDRED MUNERA CARREÑO            	42	3	1981-03-05	1	CALLE 27A N° 44-37	3007238902	68081	1	5	0	2	45454	8 	2011-04-28	579	535600	8001 	1	52	0.00	1.00	2012-04-27	0
9 	9 	28359941    	NIDIA YESMITH PEDRAZA BERNAL            	17	3	1984-11-03	1	AVENICA BUCAROS OESTE 3-11 T 6 AP 502	3124896502	68001	1	5	0	3	4253	8 	2011-05-19	587	535600	68669	1	52	0.00	1.00	2012-05-18	0
1 	1 	1039691159  	YOMAIRA ARSENY GUTIERREZ CATAÑO         	34	3	1990-09-05	1	CALLE 63 N° 36D-29	3116212341	68081	2	5	0	3	45132131	8 	2015-01-09	589	1200000	5579 	1	52	1.00	1.00	2012-05-20	0
7 	7 	1095790632  	LEIDY DIANA GUALDRON CETINA             	17	3	1986-09-06	1	CALLE 71B N° 31A-09	3122223562	68276	1	5	0	3	574321	8 	2011-05-26	591	535600	68276	1	52	0.00	1.00	2012-05-25	0
0 	0 	1098698539  	NEYLA LIZETH MEDINA ACERO               	29	1	1990-11-02	1	CR. 24 N° 31-49	3154505248	68001	1	5	0	4	54654	8 	2011-06-01	595	1500000	68001	0	51	0.00	1.00	2012-05-30	0
4 	4 	1096201988  	JESSICA PAOLA BERNAL YANEZ              	17	3	1988-12-06	1	CALLE 48E  54A-21 VILLARELIS II ETAPA	3114483494	68081	1	5	0	2	2356	8 	2011-02-10	544	566700	68081	1	52	1.00	1.00	2012-02-09	0
7 	7 	63369610    	DORIS JANETH FLOREZ VIVIESCAS           	14	3	1971-12-30	1	CALLE 8 N° 6 - 36	6499057	68001	2	5	0	4	432	8 	2011-05-26	590	800000	68001	1	52	0.00	1.00	2012-05-25	0
1 	1 	1096214247  	JORGE IVAN BASTIDA BEDOYA               	15	3	1991-12-09	2	BARRIO TIERRADENTRO MANZANA B CASA 18	6021069	68081	1	5	0	2	2569845	8 	2011-03-11	558	566700	68081	1	52	1.00	1.00	2012-03-10	0
9 	9 	1098645631  	MARIA YESENIA ULLOA RUEDA               	15	3	1987-11-21	1	CRA 5  24-38	6330132	68001	1	1	0	3	235698	8 	2011-03-12	559	535600	68001	1	52	0.00	1.00	2012-03-11	0
9 	9 	91523755    	EDWIN ALFREDO BENITEZ CASTRO            	15	3	1983-11-09	2	CALLE 12B  23-39 RIO PRADO	6593789	68307	1	5	0	2	23569854	8 	2011-03-12	560	566700	68001	1	52	1.00	1.00	2012-03-11	0
7 	7 	1099363529  	JENNY PAOLA OCHOA RUEDA                 	17	3	1987-04-14	1	CR. 5 N° 12-36	3156908761	68406	1	5	0	3	21103	8 	2011-07-02	603	566700	68406	1	52	1.00	1.00	2012-06-13	0
9 	9 	1098686663  	OSCAR ORLANDO BAUTISTA MALDONADO        	15	3	1990-05-13	2	CR. 13 N° 65 - 39	6479426	68001	1	5	1	3	223154	8 	2011-06-18	604	535600	68001	1	52	0.00	1.00	2012-06-17	0
9 	9 	1098690764  	ZAIDA CATALINA RAMIREZ CACERES          	17	3	1990-08-06	1	CONJUNTO RESIDENCIAS ACROPOLIS T.3 AP 13	6414345	68001	1	5	0	3	545421	8 	2011-06-22	605	535600	68001	1	52	0.00	1.00	2012-06-21	0
1 	1 	1096208674  	YEISON ALEXANDER CARREÑO PEREZ          	15	3	1990-11-27	2	CARRERA 37 A N° 52-68	3132870300	68081	1	5	0	2	454545	8 	2011-07-06	608	535600	68081	1	52	0.00	1.00	2012-07-06	0
4 	4 	1096211137  	FABIAN ANDRES RIOS ORTIZ                	33	3	1991-06-18	2	PEATONAL 7 N° 36E - 21 VILLA ROSITA	6101556	68081	1	2	0	3	41544	8 	2011-07-06	611	1050000	68081	0	52	1.00	1.00	2012-07-06	0
9 	9 	1095930684  	ANA MARIA LINARES PEREIRA               	60	3	1992-07-25	1	CALLE 33 N° 15-48	6468818	68307	1	1	0	3	4545	8 	2011-07-12	615	700000	68307	1	52	1.00	1.00	2012-07-11	0
7 	7 	1098711322  	LUISA FERNANDA GUTIERREZ JAIMES         	15	3	1991-09-25	1	CR. 18 N° 48-65	6424164	68001	1	3	0	3	4613214	8 	2011-05-26	592	566700	68001	1	52	1.00	1.00	2012-05-25	0
3 	3 	13870438    	CARLOS ANDRES SUAREZ FRANCO             	13	3	1981-07-15	2	CALLE 17 N° 31-34	3173988648	68001	2	5	1	4	54521	8 	2011-07-12	616	800000	68081	1	52	1.00	1.00	2012-07-11	0
7 	7 	91542854    	DIEGO FABIAN VELASQUEZ CAÑAS            	13	3	1985-07-16	2	CRA. 16 N° 108-21 CAMPO REAL	6374569	68001	1	5	0	4	123456	8 	2011-08-01	617	1300000	68001	1	52	0.00	1.00	2012-07-31	0
9 	9 	37390146    	YULY ANDREA DIAZ SUAREZ                 	17	3	1983-08-12	1	CRA. 8 N° 60-113 CASA 87 PARQUE SAN REMO	3172911931	68001	2	1	1	3	123456	8 	2011-08-06	618	535600	68001	1	52	0.00	1.00	2012-08-05	0
1 	1 	1096193904  	DIANA CRISTINA CASTAÑO CASTRO           	17	3	1988-01-07	1	CR. 4 N° 6A - 19	3105215166	68081	1	5	0	2	546545	8 	2011-08-11	621	680000	68081	1	52	1.00	1.00	2012-08-10	0
0 	0 	63529046    	ROSA ADELINA ARENIS HERNANDEZ           	29	1	1982-04-07	1	CRA. 6 N° 28-48 T-1 AP904	3104924961	68001	2	2	0	4	123456	8 	2011-08-16	624	1200000	68780	1	51	0.00	1.00	2012-08-15	0
4 	4 	1067715477  	GABRIEL ALEXANDER ROLDAN MEJIA          	15	4	1988-05-23	2	DIAGONAL 58 N° 20-56	3205518924	68081	3	5	2	2	123456	8 	2011-08-17	626	680000	68001	1	52	1.00	1.00	2012-08-16	0
1 	1 	1056773529  	LICETH LORENA OSORIO MORENO             	17	3	1989-02-20	1	CALLE 53 N° 14-17	3115011103	68081	1	1	1	3	12233	8 	2012-08-02	629	566700	68081	1	52	1.00	1.00	2012-08-22	0
4 	4 	1096221566  	YARE MARCELA SANGUINO PLATA             	17	3	1991-11-22	1	AV FERTILIZANTES CASA 67	6031197	68081	1	1	0	3	1223	8 	2011-08-26	630	535600	68092	1	52	0.00	1.00	2012-08-25	0
2 	2 	63452696    	LEIDY DIANA LOZANO GARCIA               	17	3	1982-08-06	1	CALLE 202B N° 28-22	6498824	68276	2	5	1	2	545415	8 	2011-06-30	609	680000	68001	1	52	1.00	1.00	2012-06-29	0
2 	2 	1097304024  	LEIDY TAMI ANAYA                        	17	3	1990-05-08	1	CR. 9 N° 7-33	3187653305	68276	2	5	1	2	63454	8 	2011-07-05	610	566700	68255	1	52	1.00	1.00	2012-07-04	0
1 	1 	1042212467  	LAURA URIBE BELEÑO                      	17	3	1992-04-04	1	BARRIO EL PARAISO	3134635629	68081	1	2	0	3	1233	8 	2012-04-02	632	566700	68081	1	52	1.00	1.00	2012-08-26	0
4 	4 	1096202007  	CRISTIAN CAMILO SERRANO PEREZ           	15	3	1989-11-02	2	cra. 36H N° 50-25	3204267328	68081	1	1	0	3	123456	8 	2011-08-02	619	535600	68001	1	52	0.00	1.00	2012-08-01	0
9 	9 	1101689753  	LUZ EDITH VILLAMIL HERRERA              	17	3	1991-08-31	1	CALLE 48 N° 26-62 POBLADO	3142693366	68001	1	1	0	3	123456	8 	2011-08-04	620	566700	68001	1	52	1.00	1.00	2012-08-03	0
1 	1 	1095930316  	LEIDY PAOLA MEJIA GUALDRON              	17	3	1992-10-08	1	CALLE 59A N° 45 -19	3155635790	68081	1	1	0	2	5465454	8 	2011-08-11	622	535600	68081	1	52	0.00	1.00	2012-08-10	0
9 	9 	1098665494  	LAURA MARCELA SILVA LARROTTA            	10	3	1989-01-01	1	CR. 12 N° 11 - 57	3013576218	68001	1	5	0	3	54123143	8 	2011-06-01	598	700000	68001	1	52	1.00	1.00	2012-05-30	0
2 	2 	1098694301  	LILIANA ROJAS BARON                     	17	3	1990-10-15	1	CRA. 7E N° 35 CASA 15	3154938037	68001	1	6	1	3	123456	8 	2013-03-02	628	680000	68001	1	52	1.00	1.00	2012-08-23	0
1 	1 	1096196544  	KAREN LICETH RADA GUTIERREZ             	39	3	1988-09-15	1	CARRERA 9A N° 48-43	3105503392	68081	1	5	0	2	12233	8 	2011-08-27	631	680000	68081	0	52	1.00	1.00	2012-08-26	0
7 	7 	1098675462  	DIANA MARCELA BERNAL MARTINEZ           	17	3	1989-09-10	1	CALLE 11 N°27-45	3115756020	68001	3	5	0	2	121255	8 	2011-09-06	634	566700	68679	1	52	0.00	1.00	2012-09-05	0
0 	0 	80114933    	JOHN JAIRO BERNAL REYES                 	29	3	1982-02-04	2	CRA. 13A N° 103-19	3184527676	68001	1	6	0	4	123455	8 	2013-05-19	639	2800000	1001 	1	52	0.00	1.00	2012-08-30	0
7 	7 	1102716990  	ORANGEL INFANTE ROJAS                   	15	3	1988-03-23	2	CALLE 13 N° 29-47	3125283913	68001	1	5	1	3	54124	8 	2011-07-18	606	535600	68001	1	52	0.00	1.00	2012-06-16	0
1 	1 	1096217223  	ANGIE KATERINE PEREZ CAMPOS             	17	3	1992-08-05	1	CALLE 46 N° 59A - 11	3105148574	68081	1	5	0	2	213132	8 	2011-07-09	613	566700	68001	1	52	1.00	1.00	2012-07-08	0
1 	1 	63451521    	AURA ISABEL RAPALINO ARIAS              	60	3	1980-11-11	1	CALLE 2C ESTE N°7-50 P-2	8900631	68081	1	1	2	3	31313	8 	2011-07-02	612	700000	68081	1	52	1.00	1.00	2012-06-30	0
1 	1 	1096198292  	MARISOL MATIZ SARMIENTO                 	17	3	1989-01-15	1	DIAGONAL 58 N° 43-170	6028222	68081	1	5	0	3	45132	8 	2011-08-20	614	535600	68081	1	52	0.00	1.00	2012-07-08	0
9 	9 	1095916602  	LAURA MILENA FEO GELVES                 	39	3	1988-04-04	1	CALLE 19 PEATONAL 2 SUR 08	3164318497	68001	1	5	0	2	12333	8 	2011-08-12	623	680000	68001	1	52	1.00	1.00	2012-08-11	0
3 	3 	37713943    	JAQUELINE SUAREZ NAVARRO                	17	3	1977-10-17	1	CALLE 22 N° 26-112 PISO 2	3175330244	68001	1	5	1	2	541264	8 	2011-06-01	596	566700	68001	1	52	1.00	1.00	2012-05-30	0
7 	7 	1098675366  	MIGUEL ANGEL LEAÑO JAIMES               	43	3	1989-09-06	2	CALLE 19 N° 22-15	6454066	68001	1	1	0	3	451321	8 	2011-06-01	599	535600	68001	1	52	0.00	1.00	2012-05-30	0
7 	7 	1098711363  	JONATHAN LEONARDO ALONSO MARTINEZ       	43	3	1991-09-25	2	CALLE 19 N° 6 - 34	6406900	68001	2	5	0	3	246541	8 	2011-06-20	607	535600	68001	1	52	0.00	1.00	2012-06-19	0
7 	7 	1049613946  	JESICA ANDREA APONTE AGUIRRE            	17	3	1988-07-30	1	CALLE 48 N° 2A OCCIDENTE 18	3115675749	68001	1	1	0	3	21231	8 	2011-06-08	600	535600	1001 	1	52	0.00	1.00	2012-06-07	0
2 	2 	1095798459  	YASMID DEL ROSARIO VILLAMIZAR SIERRA    	17	3	1988-12-26	1	CRA. 7E N° 28-16	3157789498	68001	3	1	1	3	1252525	8 	2011-09-16	641	535600	68001	1	52	0.00	1.00	2012-09-15	0
3 	3 	1112932219  	ERIKA OSORIO MURCIA                     	17	3	1990-10-17	0	CRA. 26 N° 21-74 AP 401	3105033533	68001	1	5	0	3	3321455	8 	2011-09-17	642	535600	68001	1	52	0.00	1.00	2012-09-16	0
1 	1 	1096196457  	FREDY ESNEIDER AGUAS GALINDO            	15	3	1988-07-28	2	CRA. 34A N° 44-68	6222222	68081	1	1	0	3	12525	8 	2011-09-26	644	535600	68081	1	52	0.00	1.00	2012-09-25	0
7 	7 	13742114    	JOSE ROBERTO ALVAREZ ALVAREZ            	35	3	1980-05-20	2	CALLE 47 N° 29-15	6530008	68001	1	2	0	3	252525	8 	2011-11-17	645	680000	68001	1	52	0.00	1.00	2012-09-30	0
7 	7 	1100892765  	JHON FERNEY RODRIGUEZ JAIMES            	35	3	1991-08-18	2	FINCA EL KIOSKO VDA VEGA CARREÑO	3168872606	68001	1	1	0	2	236565	8 	2011-10-22	654	680000	68615	1	52	1.00	1.00	2012-10-21	0
12	12	1098716392  	YESICA YULIET VARGAS PIÑA               	17	3	1991-11-05	1	CALLE 10 N° 10-13	3166380101	68001	1	5	0	3	123123	8 	2011-11-03	658	680000	68001	0	52	1.00	1.00	2012-11-02	0
12	12	63536045    	ALBA LUCIA GARZON LOPEZ                 	16	3	1982-07-19	1	CRA. 3 N° 2-126 CASA 14	3188750586	68001	3	6	1	3	123123	8 	2015-01-02	665	1000000	68001	0	52	1.00	1.00	2012-11-10	0
7 	7 	1095802868  	MARIA BELEN IBARRA ROPERO               	17	3	1989-08-30	1	SECTOR 4 TORRE 125 AP 504	6192827	68001	1	5	0	3	252525	8 	2011-11-23	670	680000	68001	1	52	1.00	1.00	2012-11-22	0
8 	8 	1095787323  	EDINSON PEREIRA DELGADO                 	15	3	1986-02-16	2	CRA. 66 N° 125-45	3168154500	68001	1	5	0	3	1252525	8 	2011-11-24	671	680000	68001	1	52	1.00	1.00	2012-11-23	0
10	10	57299385    	ELIZABETH BAYONA ROJAS                  	16	3	1984-03-11	1	CALLE 1B N° 16-68	3007000862	68001	2	5	0	3	125525	8 	2011-09-24	643	1100000	68001	0	52	1.00	1.00	2011-09-24	0
8 	8 	1100890816  	CLAUDIA PATRICIA CRUZ MARTINEZ          	17	3	1988-09-26	1	CALLE 41 N° 22-69	3163712635	68001	2	1	0	2	20525	8 	2011-11-23	673	566700	52693	1	52	1.00	1.00	2012-11-22	0
0 	0 	1098658145  	DIANA OBANDO RESTREPO                   	29	1	1988-08-21	1	CRA. 24 n° 80-12 CJTO NEPTUNO TORRE 3 AP	6941206	68001	2	3	0	4	252525	8 	2011-11-25	678	800000	68001	1	51	1.00	1.00	2012-11-24	0
9 	9 	1095913200  	VIVIANA PATRICIA PEREZ PEREZ            	17	3	1989-06-06	1	CALLE 44 N° 16-53	6460526	68307	1	5	0	2	252525	8 	2011-12-02	679	566700	68307	1	52	1.00	1.00	2012-12-01	0
7 	7 	1098624232  	MARIA DEL PILAR RODRIGUEZ RUEDA         	20	3	1986-10-28	1	CALLE 41 N°33-13 AP 502B ED. MIRAGE	3182436016	68001	2	1	0	4	25252	8 	2011-12-02	683	1300000	68001	1	52	0.00	1.00	2012-12-01	0
0 	0 	37713938    	BELKY MAYERLY RODRIGUEZ CARDENAS        	29	1	1978-10-21	1	TV OR. CJ PIEMONTI T. 16 AP 402	3182819844	68001	1	1	0	4	252525	8 	2011-10-04	646	2000000	68001	1	52	0.00	1.00	2012-10-03	0
7 	7 	1098655323  	DANIEL ENRIQUE LOZANO MUÑOZ             	15	3	1988-07-15	2	CRA. 41w N° 59-59	6416220	68001	3	5	1	2	11222	8 	2011-10-13	648	566700	68001	1	52	1.00	1.00	2012-10-12	0
2 	2 	1098646174  	FABIO ALONSO RIVERO CASTAÑO             	15	3	1987-12-03	2	CALLE 14 N° 11-64	6990675	68001	1	5	0	2	121251	8 	2011-10-13	651	566700	68001	1	52	1.00	1.00	2012-10-12	0
1 	1 	1102370573  	DIANA MARCELA TORRES NIETO              	17	3	1993-01-20	1	CRA. 17A N° 55-39	3186261605	68081	1	5	0	3	3352	8 	2011-10-15	652	566700	68547	1	52	1.00	1.00	2012-10-14	0
7 	7 	63562172    	LUZ STELLA MENDOZA HERNANDEZ            	39	3	1985-06-11	1	CARRERA 17 N° 6-45	3117354974	68001	1	5	0	3	123654	8 	2011-10-22	655	680000	68001	1	52	1.00	1.00	2012-10-21	0
9 	9 	63559386    	MARIELA HERNANDEZ GOMEZ                 	17	3	1985-04-21	1	SECTOR S TORRE 11 AP 104A	6396473	68001	0	5	0	3	122552	8 	2011-10-22	656	680000	68001	0	52	1.00	1.00	2012-10-21	0
4 	4 	1104700671  	DIEGO ARMANDO CORTES RETAVISCA          	15	3	1989-06-01	2	CRA. 23 N° 77B-04	3163021418	68081	1	5	0	2	123123	8 	2011-11-02	659	680000	73411	1	52	1.00	1.00	2012-11-01	0
2 	2 	1095812374  	ANDREA PAOLA AVILA USECHE               	17	3	1992-06-20	1	CRA. 2E N° 32-126	3213658728	68001	1	5	0	2	125525	8 	2012-02-17	666	566700	1001 	1	52	1.00	1.00	2012-11-10	0
2 	2 	1095805383  	YICED MAYERLY BAYONA MARTINEZ           	17	3	1990-06-26	1	CALLE 110 N° 34-09	3154593114	68001	1	1	0	2	122363	8 	2011-07-02	635	566700	68679	1	52	1.00	1.00	2012-09-08	0
3 	3 	91513363    	JOSE ANAEL CADENA CARVAJAL              	10	3	1982-11-05	2	CALLE 15 NA N° 19A-17 MZ 5	3168408883	68001	3	5	4	3	25255	8 	2011-11-11	667	700000	68001	1	52	1.00	1.00	2012-11-10	0
1 	1 	1122405421  	IRINA PAOLA ARIAS MARTINEZ              	17	3	1990-09-23	1	CALLE 57 N° 21-55	3144234540	68081	1	5	0	2	252525	8 	2013-03-28	669	680000	68081	1	52	1.00	1.00	2012-11-11	0
4 	4 	1096212299  	MARIA ALEJANDRA MURILLO NORIEGA         	17	3	1991-06-20	1	CALLE 52 N° 37A-26	3142322247	68081	1	5	0	2	152525	8 	2012-07-03	672	680000	68081	1	52	1.00	1.00	2012-11-18	0
2 	2 	1095795201  	JOHANNA ANDREA LARROTTA RODRIGUEZ       	17	3	1988-03-20	1	SECTOR 13 BLOQUE 18-11 AP 302	3178754490	68001	1	2	0	3	124255	8 	2011-11-24	674	680000	68001	1	52	1.00	1.00	2012-11-23	0
4 	4 	1096221876  	LUZ ANGELICA AHUMADA ORTIZ              	17	3	1993-04-27	1	CALLE 33 N°39-36	6106815	68081	1	1	0	2	123554	8 	2012-07-03	640	680000	68081	1	52	1.00	1.00	2012-09-07	0
7 	7 	91512109    	GABRIEL CARREÑO CALA                    	15	3	1982-03-29	2	CALLE 82 CASA 2 ALTOS DEL CACIQUE	3154609279	68001	1	5	0	2	123123	8 	2011-11-01	660	566700	68655	1	52	1.00	1.00	2012-10-30	0
1 	1 	91438366    	WISTON SANCHEZ CAMPUZANO                	15	3	1970-02-25	2	CALLE 64 N° 36D-84	3124139151	68081	2	1	2	2	556855	8 	2011-11-11	668	535600	68745	1	52	0.00	1.00	2012-11-10	0
3 	3 	1095912918  	JHONNATAN FERNEY QUINTERO ORTIZ         	10	3	1988-01-30	2	CRA. 21 N° 15-29	3168603252	68001	1	5	0	3	123456	8 	2011-08-16	625	700000	68001	1	52	1.00	1.00	2012-08-15	0
3 	3 	1095813605  	ARNEY GUTIERREZ ROSAS                   	15	3	1992-10-04	2	CR. 60 N° 5- 41	6495621	68001	1	5	0	2	654123	8 	2011-06-11	601	535600	68001	1	52	0.00	1.00	2012-06-10	0
3 	3 	1098698292  	FREDY ARMANDO RODRIGUEZ RINCON          	15	3	1990-09-06	2	CALLE 103B N° 40-06	6495636	68001	1	5	0	2	121321	8 	2013-04-18	649	680000	68001	1	52	1.00	1.00	2012-10-12	0
0 	0 	13834794    	JESUS CABEZAS HERRERA                   	29	1	1956-03-31	2	CALLE 62 N° 45-78	3177535654	68001	2	1	1	4	14441	8 	2011-10-03	647	2000000	68001	1	51	0.00	1.00	2012-10-02	0
8 	8 	1095816175  	SOLCIDET QUINTERO CASTILLO              	17	3	1993-07-01	1	RUITOQUE ALTO TRES ESQUINAS	3153339290	68001	1	1	0	2	1233	8 	2011-09-09	636	535600	68276	1	52	0.00	1.00	2012-09-08	0
2 	2 	1095807557  	YESSICA JULIANA VARGAS SUAREZ           	60	3	1990-12-28	1	CALLE 205 N° 40-187	3175473691	68001	1	5	0	2	123655	8 	2011-10-23	657	680000	68001	1	52	1.00	1.00	2012-10-22	0
0 	0 	1098665658  	CINDY JOHANA ALMEIDA BARAJAS            	29	1	1988-10-02	1	CALLE 28 N° 1-01	6582922	68001	1	7	0	3	12233	8 	2011-08-19	627	1800000	68001	0	51	0.00	1.00	2012-08-19	0
1 	1 	1065373103  	BLADIMIR LOPEZ MARTEZ                   	15	3	1986-05-02	2	AV. 52 N° 59-45	3208156779	68081	1	5	0	2	252525	8 	2011-12-01	684	680000	23464	1	52	1.00	1.00	2012-11-30	0
0 	0 	91245593    	OSCAR ANGULO ALMARIO                    	29	1	1966-02-20	2	CRA. 17B N° 14C-13	3115465494	68001	2	5	2	3	363636	8 	2011-12-01	685	1200000	68001	0	51	1.00	1.00	2012-11-30	0
9 	9 	1095908259  	JENNY ROCIO LEAL MURILLO                	17	3	1986-03-15	1	CRA. 10 N° 22-18	3156046114	68001	1	5	0	3	205255	8 	2011-12-07	687	680000	68001	0	52	1.00	1.00	2012-12-06	0
1 	1 	1096184025  	JEAN CARLOS ALCOCER NARVAEZ             	15	3	1986-02-11	2	CRA. 21 N° 46-59	3128445089	68081	1	5	1	2	1231414	8 	2011-12-01	688	566700	68081	1	52	1.00	1.00	2011-12-01	0
9 	9 	1098666992  	MARIBEL ARIZMENDI RAMIREZ               	17	3	1987-11-20	1	CASA 25 MZ D SECTOR 5 CRISTAL BAJO	3172181014	68001	3	1	0	3	252525	8 	2011-12-10	690	535600	68001	1	52	0.00	1.00	2012-12-09	0
9 	9 	79901766    	FABIAN ANDRES SOLANO OCAMPO             	16	3	1978-03-11	2	CALLE 57A N° 20-90	3133552680	68001	2	1	1	3	1252525	8 	2011-12-16	692	800000	68001	1	52	1.00	1.00	2012-12-15	0
2 	2 	91520950    	JUAN FRANCISCO GARZON ZAMBRANO          	14	3	1983-06-13	2	CALLE 103B N° 16A-57	3123124320	68001	1	1	0	3	2141444	8 	2012-01-04	693	800000	68001	1	52	1.00	1.00	2012-12-19	0
0 	0 	37863968    	OLGA LUCIA ALVAREZ VASQUEZ              	29	1	1980-08-09	1	CALLE 40 N° 19-32 BLOQUE 1 AP 501	6533932	68307	1	5	1	3	252525	8 	2012-01-16	696	650000	13001	1	51	1.00	1.00	2013-01-15	0
7 	7 	1098647773  	INGRID CAROLINA URIBE PAEZ              	17	3	1987-12-31	1	CALLE 101A N° 42-08	6772284	68001	1	6	0	3	252525	8 	2012-01-25	698	566700	68001	1	52	1.00	1.00	2013-01-24	0
7 	7 	63563464    	ANGEL CAROLINA MARTINEZ PORRAS          	17	3	1985-08-03	1	CALLE 18 N° 32A-49	3205464194	68001	1	5	0	2	252525	8 	2012-02-23	703	566700	68001	1	52	1.00	1.00	2013-02-22	0
8 	8 	1098694338  	KAREN JULIETH ATENCIO PEREA             	34	3	1990-10-18	1	CRA. 5 N° 9-50	3156806424	68001	1	1	1	2	2525	8 	2013-07-04	707	1000000	68001	1	52	1.00	1.00	2013-03-04	0
9 	9 	1095931090  	JUAN CARLOS TAPIAS OSORIO               	15	3	1993-01-04	2	CRA. 20A N° 56-26 PALENQUE	3165575404	68001	1	2	0	2	2525	8 	2012-03-06	709	566700	68001	1	52	1.00	1.00	2013-03-05	0
9 	9 	91538015    	EMANUEL ANDRES BERNAL MAYORGA           	15	3	1985-03-20	2	BLOQUE 28 AP 301 COLSEGUROS	3175672282	68001	1	5	0	2	2525	8 	2012-03-08	710	566700	68001	1	52	1.00	1.00	2013-03-06	0
4 	4 	1096226990  	ANGIE JULIETH MIZAR TOLOZA              	17	3	1994-04-10	1	AV. 52 N° 34-85	3106586837	68081	1	5	0	2	2525	8 	2012-04-20	726	566700	68081	1	52	1.00	1.00	2013-04-19	0
1 	1 	1096202766  	YURLEY ANDREA BELTRAN HERNANDEZ         	17	3	1989-12-26	1	CRA. 35 N° 75 BIS-07	3214742543	68081	1	5	0	2	2525	8 	2012-04-24	727	680000	68081	1	52	1.00	1.00	2013-04-23	0
7 	7 	37721148    	VIRSA VASQUEZ NIÑO                      	39	3	1978-11-13	1	CALLE 30 N° 9OCC-05	3173381911	68001	2	5	4	2	2525	8 	2012-04-26	729	566700	68001	1	52	1.00	1.00	2013-04-25	0
7 	7 	1098739769  	GRACE JULIANA MORENO ARENAS             	17	3	1993-06-19	1	CALLE 14 N° 30-52	3154390771	68001	1	1	0	2	252525	8 	2011-09-01	637	535600	68001	1	52	0.00	1.00	2012-08-30	0
7 	7 	1098664995  	DIANA MARCELA TORRES RIVERA             	17	3	1988-01-06	1	CALLE 105 N° 22-115	3164357857	68001	1	5	0	2	2525	8 	2012-04-27	730	566700	68001	1	52	1.00	1.00	2013-04-26	0
1 	1 	1096221673  	PAOLA ANDREA VILLAMIZAR LOZANO          	40	3	1993-05-27	1	CRA. 48 N° 40-11	3178585929	68001	1	5	0	2	2252525	8 	2011-12-01	689	680000	68001	0	52	1.00	1.00	2012-11-30	0
4 	4 	1096207830  	JHONATHAN JULIAN LEIRA NEGRON           	15	3	1990-10-09	1	CRA. 37F N° 75-77	3167566499	68081	1	5	0	2	25252	8 	2011-11-16	675	566700	5059 	1	52	1.00	1.00	2012-11-16	0
7 	7 	1098729444  	JONATHAN GAMBOA MARTINEZ                	15	3	1992-11-10	2	CALLE 24 N° 11-68	6348437	68001	1	1	0	2	123123	8 	2013-07-05	661	680000	68001	1	52	1.00	1.00	2012-10-30	0
4 	4 	52899775    	BEATRIZ BELTRAN RAMIREZ                 	17	3	1981-10-20	1	CRA. 20 N° 54-71	3104940074	68081	1	2	0	2	252525	8 	2011-11-15	677	566700	17380	1	52	1.00	1.00	2012-11-14	0
3 	3 	1098691833  	LEIDY BIBIANA DIAZ SALAMANCA            	17	3	1990-08-17	1	CALLE 31 N° 18-15	3154433245	68001	1	3	0	3	1414144	8 	2012-02-23	704	680000	68001	1	52	1.00	1.00	2012-02-23	0
7 	7 	1098688438  	LESLY VANESSA GUALDRON ESTUPIÑAN        	17	3	1990-05-15	1	CALLE 11 N° 18-40	6718428	68001	2	5	1	2	2525	8 	2012-01-25	699	566700	68001	1	52	1.00	1.00	2013-01-24	0
1 	1 	1096223209  	LISETH PAOLA MUÑOZ URANGO               	17	3	1993-08-26	1	TV. 49 N° 63 LOTE 120	3168688401	68081	1	5	1	2	2525	8 	2012-03-01	708	566700	68001	1	52	1.00	1.00	2013-02-28	0
0 	0 	1098671153  	SANDRA MARCELA MARTINEZ ORTIZ           	29	1	1989-06-06	1	CALLE 68 N° 10A-147	6835607	68001	1	5	0	3	124144	8 	2013-01-02	680	860000	68001	1	51	1.00	1.00	2012-11-30	0
3 	3 	37723805    	YURLEY ORTIZ BARRERA                    	60	3	1978-09-01	1	CRA. 12 N° 103D-06	3174310279	68001	2	1	0	2	1222222	8 	2013-04-18	633	700000	68001	1	52	1.00	1.00	2012-09-05	0
1 	1 	13566525    	EDGAR LEON GONZALEZ                     	14	3	1983-03-03	1	CALLE 55 N° 19-07	3006474102	68081	1	5	0	2	252525	8 	2012-01-20	697	900000	68081	1	52	1.00	1.00	2013-01-19	0
9 	9 	1095803789  	CHRISTIAM ALEXANDER ACOSTA OLAYA        	15	3	1990-01-23	2	AV VILLALUZ 121-82	3168084179	68001	1	5	0	3	2525	8 	2012-04-19	721	680000	68001	1	52	1.00	1.00	2013-04-18	0
0 	0 	63542491    	DIANA CAROLINA MORA REY                 	29	1	1983-07-02	1	SANTA CATALINA TORRES 10 AP 528	3003152759	68001	2	5	0	4	252525	8 	2012-03-26	717	1800000	68001	1	51	0.00	1.00	2013-03-25	0
13	13	60265570    	SILVIA CAROLINA GAMBOA                  	20	3	1982-10-06	1	CRA. 31W N° 63A-14 AP 301	3132901507	68001	1	1	1	2	2525	8 	2014-08-16	700	1000000	68001	1	52	1.00	1.00	2013-01-25	0
0 	0 	91493878    	SERGIO DAVID OVIEDO PIMENTEL            	29	1	1976-11-06	2	TV. 29A N° 105-40	3173683761	68001	2	5	3	5	2525	8 	2012-04-18	723	8000000	68001	1	51	0.00	1.00	2013-04-17	0
7 	7 	1098739664  	LEIDY JOHANNA CAICEDO VILLAMIZAR        	39	3	1993-04-19	1	CRA. 19 N° 60-33	6493426	68001	2	5	1	3	5254	8 	2011-10-20	653	680000	68001	0	52	1.00	1.00	2012-10-19	0
4 	4 	1096206775  	CIRO ANDRES ALVAREZ MENESES             	15	3	1990-04-23	2	CALLE 25 N° 46-46	6029117	68001	3	2	0	2	52525	8 	2011-11-19	676	566700	68001	1	52	1.00	1.00	2012-11-18	0
7 	7 	13851732    	JOHN ALEXANDER TREJOS FERNANDEZ         	15	3	1980-05-30	1	CRA. 26 N° 15-58	3162917587	68001	1	1	0	2	123123	8 	2012-02-02	662	566700	68001	1	52	1.00	1.00	2012-11-02	0
9 	9 	1098689407  	LAURA MARCELA URIBE RUEDA               	17	3	1990-02-18	1	CRA. 2 MZ E CASA 26	6837006	68001	1	1	0	2	2525	8 	2014-05-09	681	680000	68001	1	52	1.00	1.00	2012-11-30	0
7 	7 	1095815356  	SILVIA JULIANA SANCHEZ BAYONA           	17	3	1993-04-06	1	BLOQUE 6-8 AP 301 BUCARICA	3154448640	68001	1	5	0	2	1252525	8 	2011-09-09	638	566700	68001	1	52	1.00	1.00	2012-09-08	0
7 	7 	1102353881  	NIDIA YANETH MOSQUERA GOMEZ             	17	3	1987-02-01	1	TV 1J N° 542	6558833	68001	2	5	2	2	1414143	8 	2012-05-02	733	566700	68001	1	52	1.00	1.00	2013-05-01	0
8 	8 	1102361481  	GUSTAVO ADOLFO GOMEZ SALON              	15	3	1989-01-15	2	CALLE 52 N° 16-63	6427397	68081	2	5	1	2	2525	8 	2012-05-16	737	566700	68001	1	52	1.00	1.00	2013-05-15	0
7 	7 	91518298    	OSCAR IVAN ZAPATA HERNANDEZ             	44	3	1983-04-26	2	CALLE 53 N° 21-22	6940283	68001	1	1	1	3	2525	8 	2012-05-29	738	566700	68001	1	52	1.00	1.00	2013-05-22	0
9 	9 	1098617048  	ZAIRA MARIA TOLEDO TORRES               	17	3	1985-08-30	1	CRA. 7A N° 18-71	3183109181	68001	2	1	1	2	2525	8 	2012-05-26	739	566700	68001	1	52	1.00	1.00	2013-05-25	0
0 	0 	13542411    	JAIRO ALEXANDER GONZALEZ BUENO          	29	1	1978-07-27	2	CALLE 106C N° 15B-10	6801749	68001	1	1	1	5	252525	8 	2012-06-19	745	2500000	68001	1	51	0.00	1.00	2013-06-18	0
9 	9 	1098648629  	DIANA CATALINA MANTILLA NARANJO         	17	3	1987-08-22	1	URB. SANTA CATALINA TORRE 5 AP 313	3177729967	68001	1	2	1	2	123123	8 	2011-11-04	663	566700	68001	1	52	1.00	1.00	2012-11-03	0
10	10	91211415    	PEDRO JAVIER LOPEZ JOYA                 	10	3	1956-11-08	2	TORRE 2 AP 903 TAIRONA	3006126108	68001	2	3	1	5	252525	8 	2012-07-03	747	2500000	68001	1	52	0.00	1.00	2013-07-02	0
0 	0 	63502998    	CLAUDIA ROCIO CABALLERO AVILA           	29	1	1975-06-14	1	CRA. 9E N° 27-53	3132543889	68001	4	1	2	3	252525	8 	2012-07-05	748	860000	68001	1	51	1.00	1.00	2013-07-04	0
7 	7 	1098746664  	ANGIE SLENDY AYALA AYALA                	17	3	1983-11-21	1	CALLE 106 N° 15B-33 VILLA SARA	3154479655	68001	1	5	0	2	2525	8 	2012-07-19	750	566700	68001	1	52	1.00	1.00	2013-07-18	0
9 	9 	1098660405  	CAROL DAYANA MARTINEZ SANCHEZ           	17	3	1988-10-06	1	CALLE 200A N° 19-17	6440602	68001	2	5	0	2	2255	8 	2012-08-18	734	566700	68001	1	52	1.00	1.00	2013-05-03	0
9 	9 	1098645075  	LEIDY MILENA OREJARENA REYES            	17	3	1987-07-11	1	CALLE 58 N° 42W-27	3178737906	68001	1	1	0	2	87288	8 	2012-07-27	756	680000	68001	0	52	1.00	1.00	2013-07-26	0
7 	7 	28214745    	LUZ DEICY BOHORQUEZ MORENO              	17	3	1989-07-26	1	DG. 7 N° 18-31	6591123	68307	1	1	1	2	252525	8 	2010-11-15	759	566700	68307	1	52	1.00	1.00	2011-11-14	0
1 	1 	1096189974  	JOHANA ANZOLA TRIANA                    	17	3	1986-02-19	1	DG 64 N° 013 LAS GRANJAS	3214417227	68081	1	2	0	3	25252	8 	2012-08-23	763	680000	68190	1	52	1.00	1.00	2013-08-22	0
7 	7 	63553195    	MONICA PATRICIA MORENO RUEDA            	17	3	1984-09-21	1	CALLE 57A N° 43AW-35	6418328	68001	2	2	2	3	2525	8 	2012-08-29	764	680000	68001	1	52	1.00	1.00	2013-08-28	0
8 	8 	1098688604  	MAURY LISETH URIBE COLMENARES           	17	3	1990-06-13	1	CRA. 29A N° 70-24	3184009630	68001	1	5	0	3	32525	8 	2012-09-06	765	566700	68001	1	52	1.00	1.00	2013-08-29	0
7 	7 	1098709186  	LUISA FERNANDA VALDIVIESO ACOSTA        	17	3	1991-04-15	1	CALLE 18 N° 30-45	3175871952	68001	1	6	1	3	252525	8 	2012-03-01	706	566700	68001	1	52	1.00	1.00	2013-02-28	0
1 	1 	1096184168  	JIMENA MARCELA LOPEZ GARRIDO            	17	3	1986-08-01	1	TV. 51 DG 64	3144437418	68081	1	5	0	2	2525	8 	2012-08-02	728	566700	68081	1	52	1.00	1.00	2013-04-22	0
9 	9 	1098746124  	KELLY ALEXANDRA SUAREZ MAYORGA          	39	3	1993-10-23	1	CALLE 25 N° 1A-23	3126584661	68001	1	1	1	3	2525	8 	2012-06-01	743	680000	68001	0	52	1.00	1.00	2013-05-30	0
4 	4 	24415595    	MARISOL MUÑOZ PUERTA                    	16	3	1986-01-01	1	CRA. 31B  N° 35-35	3115155781	68081	1	5	0	2	252525	8 	2012-06-19	746	840000	66045	0	52	1.00	1.00	2013-06-18	0
7 	7 	37550746    	LINA MARCELA MORA CASTAÑEDA             	39	3	1983-11-24	1	CALLE 201A N° 21A-39	3133218339	68001	1	5	0	3	2525	8 	2012-07-17	751	566700	68001	1	52	1.00	1.00	2013-07-16	0
8 	8 	37844585    	JENNY MILENA ARIAS ROJAS                	12	1	1981-02-20	1	CRA. 29 N° 29-59 CONDOMINIO EL LAGO	3006496567	68001	1	5	1	4	2525	23	2012-07-23	753	2300000	68001	0	52	0.00	1.00	2013-07-22	0
9 	9 	1095907628  	OSCAR FABIAN PRADA ESTUPIÑAN            	35	3	1986-06-05	2	CALLE 23 N° 27-26 RIO DE ORO	6591908	68001	2	5	2	3	252525	8 	2012-08-01	757	640000	68001	1	52	1.00	1.00	2013-07-30	0
7 	7 	1098678633  	GLENIS GENIT QUINTERO MARTINEZ          	17	3	1989-07-10	1	CALLE 6 N° 24-36	3173111113	68001	1	5	1	2	2525252	8 	2012-08-15	762	680000	68001	1	52	1.00	1.00	2013-08-14	0
7 	7 	1098717470  	NADIA PATRICIA BARRERA MENDOZA          	17	3	1991-12-22	1	CRA. 9 N° 8-52	3157562769	68001	1	5	0	2	2525	8 	2012-04-13	719	566700	68001	1	52	1.00	1.00	2013-04-12	0
7 	7 	1098733095  	JESUS DAVID CARVAJAL DUEÑEZ             	15	3	1992-12-26	2	CRA. 9CC N° 29-09	6300455	68001	1	1	0	2	2525	8 	2012-08-30	766	680000	68001	1	52	1.00	1.00	2013-08-29	0
9 	9 	1095915518  	DIANA LILIANA FLOREZ MURILLO            	17	3	1988-03-16	1	CALLE 25 N° 27-21	3142545788	68307	1	5	0	2	252525	8 	2012-06-04	741	566700	68307	1	52	1.00	1.00	2013-06-03	0
7 	7 	1095510498  	LUZ DARY RUIZ AVENDAÑO                  	17	3	1998-11-30	1	CRA. 15A N° 57A-21	31442867030	68001	1	5	0	2	252525	8 	2011-12-01	682	566700	68001	1	52	1.00	1.00	2012-11-30	0
0 	0 	28155098    	CAROLINA PARRA GONZALEZ                 	29	1	1981-07-01	1	CALLE 34 N° 25-51	3164481977	68001	2	5	3	5	25252	8 	2012-08-01	758	3500000	68001	1	51	0.00	1.00	2013-07-30	0
7 	7 	1098715899  	WILLIAM SANCHEZ AUSECHA                 	15	3	1992-01-13	2	CRA. 5 N° 1A-22 CAMPO VERDE	3115640622	68001	1	1	1	3	2525	8 	2012-07-24	754	680000	68001	1	52	1.00	1.00	2013-07-23	0
3 	3 	1014244435  	AURA ROSA RIOS MARTINEZ                 	17	3	1993-06-01	1	CALLE 31A N° 16-06	3124795914	68001	1	5	0	2	2525	8 	2012-05-07	735	680000	68001	1	52	1.00	1.00	2013-05-06	0
1 	1 	1096483852  	JESUS ANDRES GALEANO GALEANO            	15	3	1992-05-17	2	CFA. 6 N° 49-29	3216721584	68081	1	5	0	2	2525	8 	2012-06-01	742	566700	68081	1	52	1.00	1.00	2013-05-30	0
2 	2 	13872786    	OSCAR ENRIQUE RUEDA NIÑO                	15	3	1981-10-16	2	CALLE 64 N° 17A-66	3164755004	68001	1	5	0	3	123123	8 	2014-06-20	664	680000	68001	1	52	1.00	1.00	2012-10-30	0
2 	2 	1049019468  	JOHANA GARCIA CABALLERO                 	17	3	1986-09-26	1	BLOQUE 14 N° 19B- AP 223	3132418148	68001	1	5	0	3	25250	8 	2014-04-11	724	680000	68001	1	52	1.00	1.00	2013-04-18	0
0 	0 	37754353    	NHORA ZULEYMA CARDENAS PAIPA            	29	1	1980-07-29	1	SAN JORGE IV CASA 164-LOS CANEYES	3167247342	68001	3	5	0	3	2525	8 	2011-10-13	650	650000	68001	1	51	0.00	1.00	2012-10-12	0
4 	4 	1065594761  	ZUNIRY DURAN NAVARRO                    	17	3	1987-12-30	1	CALLE 76A N° 31a-54	3135031034	68081	1	5	0	2	2525	8 	2012-04-27	731	566700	68081	1	52	1.00	1.00	2013-04-26	0
4 	4 	1098706497  	VIVIANA CRUZ NAVAS                      	17	3	1991-06-08	1	CALLE 61 N° 36E-52	3126814064	68081	3	6	1	2	252525	8 	2012-05-11	736	680000	68001	1	52	1.00	1.00	2013-05-10	0
2 	2 	1098642486  	JUAN PABLO RUIZ VASQUEZ                 	15	3	1987-09-26	1	CRA. 13 N° 65-47	3162327348	68001	1	5	1	2	2525	8 	2012-09-11	769	566700	68001	1	52	1.00	1.00	2013-09-10	0
1 	1 	1085097349  	ROSIRIS QUIROZ GUALDRON                 	17	3	1990-12-25	1	BARRANCA	3116517339	68001	1	1	0	2	2525	8 	2012-09-13	771	680000	68001	1	52	1.00	1.00	2013-09-07	0
9 	9 	1098652834  	DAVID FRANCISCO DUARTE                  	15	3	1988-02-14	2	CALLE 85 N° 24-46	6369650	68001	1	5	0	2	2525	8 	2012-09-20	772	680000	68001	1	52	1.00	1.00	2013-09-19	0
7 	7 	1101755183  	NORYDA JAZMIN GONZALEZ LEON             	17	3	1989-03-26	1	CALLE 19 N° 31-60	6904252	68001	1	5	0	2	2525250	8 	2012-09-24	773	566700	68001	1	52	1.00	1.00	2013-09-23	0
9 	9 	1095816140  	OSCAR MAURICIO TARAZONA DIAZ            	14	3	1993-07-02	2	SECTOR B TORRE 4 APT 101	3172976275	68276	1	5	0	2	2525	8 	2012-09-27	776	700000	68001	1	52	1.00	1.00	2013-09-26	0
9 	9 	1099368420  	MIGUEL ANGEL MORALES ACOSTA             	15	3	1992-02-07	1	CALLE 7 N° 22-74	3166211804	68001	1	4	0	2	525	8 	2012-10-01	777	566700	68001	1	52	1.00	1.00	2013-09-30	0
4 	4 	1096194727  	NORBERTO LOPEZ BENAVIDES                	15	3	1987-10-26	2	CALLE 48A N 7-9	3114701468	68081	1	7	0	2	2525	8 	2012-10-01	778	566700	68081	1	52	1.00	1.00	2013-09-30	0
8 	8 	1102353677  	ADRIANA MARCELA BAUTISTA CHANAGA        	17	3	2012-10-05	1	CALLE 4 N° 10-46	3107086215	68001	1	5	0	2	2525	8 	2012-10-05	779	566700	68001	1	52	1.00	1.00	2013-10-04	0
9 	9 	30008975    	CLAUDIA ALEXANDRA ARDILA PARDO          	17	3	2004-05-10	2	METROPOLIS I T4 AP 208	6741718	68001	2	1	1	3	252525	8 	2012-10-15	783	680000	68211	1	52	1.00	1.00	2013-10-15	0
4 	4 	1096198754  	MARGIE GISELL GOMEZ LASERNA             	17	3	1988-10-30	1	DG. 60 N° 44-122	3112801866	68001	2	5	2	4	2525	8 	2012-07-16	752	566700	68001	1	52	1.00	1.00	2013-07-15	0
8 	8 	1005331296  	LUISA FERNANDA LIZCANO LIZARAZO         	17	3	1986-12-30	1	VEREDA LA ESPERANZA FINCA LA FORTUNA	3158787178	68001	1	5	2	2	2525	8 	2012-10-17	784	566700	68001	1	52	1.00	1.00	2013-10-16	0
9 	9 	1095935252  	AMANDA MORELA CRISTANCHO CARRILLO       	17	3	1993-01-30	1	CRA. 36 N° 29B-33 CAMPIÑA	3118256476	68307	1	1	0	2	252525	8 	2012-03-21	713	680000	54051	1	52	1.00	1.00	2013-03-20	0
0 	0 	1098674021  	JULIETH ALEXANDRA RUIZ MEJIA            	29	1	1989-08-12	1	CALLE 13 C N° 15-64	3167581820	68307	1	5	0	3	25255	8 	2012-08-08	760	1200000	68001	0	51	1.00	1.00	2013-08-07	0
4 	4 	1091654855  	YENNY MARCELA RINCON RAMOS              	17	3	1986-11-28	1	AVENIDA NACIONAL CASA 65	3204754236	68081	1	5	0	2	25252	8 	2012-09-08	770	566700	68081	1	52	1.00	1.00	2013-09-07	0
0 	0 	1098610897  	HANS KEVIN VEGA GUTIERREZ               	29	3	1985-09-23	1	CRA. 47B N° 30-09	6452258	68001	1	5	3	3	14144	8 	2012-10-22	785	1300000	68001	1	52	0.00	1.00	2013-10-21	0
9 	9 	1116775897  	JUAN CARLOS CEDEÑOCHAVEZ                	15	3	1986-11-02	2	CRA 3 58 15	3143990088	68001	1	5	0	2	252514	8 	2012-11-01	787	680000	68001	1	52	1.00	1.00	2013-10-30	0
7 	7 	1098714292  	INGRID PAOLA CASALINAS MORENO           	17	3	1991-12-02	1	CALLE 62 17 C 72	6952016	68001	3	5	0	2	252525	8 	2012-11-01	788	680000	68001	1	52	1.00	1.00	2013-10-30	0
7 	7 	1098602530  	SERGIO FERNANDO ROMERO CABALLERO        	15	3	1985-10-05	2	CRA 24 5- 16	6343022	68001	1	1	0	2	252525	8 	2012-11-01	789	680000	68001	1	52	1.00	1.00	2013-10-30	0
7 	7 	1098696907  	HENRY ALBERTO ROJAS VARGAS              	33	3	1990-10-01	2	CALLE 9 N° 22-22	6716636	68001	1	5	0	2	252525	8 	2012-11-06	790	840000	68001	0	52	1.00	1.00	2013-11-05	0
9 	9 	1098678722  	MONICA MAYERLY SOCHA MARTINEZ           	17	3	1989-11-16	1	CALLE 49 20-21	3132474005	68001	1	5	0	2	252525	8 	2013-07-02	791	680000	68001	1	52	1.00	1.00	2013-11-05	0
1 	1 	1096208059  	EUDYS REDONDO SIERRA                    	17	3	1990-09-08	1	DG 62 N° 46-115	3144546747	68081	1	5	0	2	252525	8 	2012-09-22	774	680000	68081	1	52	1.00	1.00	2013-09-23	0
7 	7 	1070596479  	IVONNE TATIANA LEAL MARTINEZ            	17	3	1989-03-28	1	CALLE 11 23-68	3183980935	68001	3	5	0	2	252525	8 	2012-11-06	792	680000	68001	1	52	1.00	1.00	2013-11-05	0
10	10	13539791    	LIBARDO ESPINOSA PEÑA                   	15	3	1983-12-11	2	CALLE 3 N 1 SEGUNDO PISO	3165589958	68547	1	5	0	2	252525	8 	2013-07-04	793	680000	68307	1	52	1.00	1.00	2013-11-06	0
10	10	91468661    	ARNULFO PEREZ VELANDIA                  	33	3	1984-08-28	2	CRA 36 CALLE 111 -97	3186660906	68276	1	5	0	2	252525	8 	2012-11-07	794	1050000	68615	0	52	1.00	1.00	2013-11-06	0
4 	4 	63531096    	LESLI MILEIDIS MORENO LIEVANO           	17	3	1982-05-24	1	CRA 31 65 40	3213542955	68081	1	5	0	2	252525	8 	2012-11-21	802	566700	68081	1	52	1.00	1.00	2013-11-20	0
10	10	34330896    	LUISA FERNANDA CARDENAS ROJAS           	17	3	1985-07-30	1	CRA 17 13 05	6046385	68547	1	5	0	2	252525	8 	2012-11-21	803	680000	19001	0	52	1.00	1.00	2013-11-20	0
10	10	1102355726  	JOSE LUIS MARTINEZ CASTILLO             	15	3	1988-04-25	2	MANZANA A CASA 8 P3	3133811791	68001	3	5	0	2	2525	8 	2012-10-04	780	680000	68001	1	52	1.00	1.00	2013-10-03	0
9 	9 	1098656211  	FABIO ANDRES GALVIS GOMEZ               	15	3	1988-03-21	2	CALLE 64C N° 9B-13	3183113049	68001	1	5	0	2	20202	8 	2012-09-01	767	680000	68001	1	52	1.00	1.00	2013-08-30	0
9 	9 	1098741680  	LEIDY PAOLA MARIN GARCES                	17	3	1993-05-26	1	BARRIO EL CARMEN	3175551968	68001	1	5	0	2	255520	8 	2012-09-26	775	680000	5001 	1	52	1.00	1.00	2013-09-25	0
8 	8 	1100892942  	JAIME ANDRES CEPEDA FLOREZ              	15	3	1990-10-03	2	CRA 18 CALLE 17	3166560391	68001	1	5	0	2	252525	8 	2012-11-17	801	680000	68001	1	52	1.00	1.00	2013-11-16	0
9 	9 	1098732027  	YURLENY MAYERLY CORREA FRANCO           	17	3	2012-10-04	1	CALLE 95 N° 13-13	3167319975	68001	1	1	0	2	2525	8 	2012-10-04	781	680000	68001	1	52	1.00	1.00	2013-10-03	0
7 	7 	1098759313  	AURA MARCELA CASTRO BARAJAS             	17	3	1994-08-30	1	CRA. 26 N° 32-58	3105594397	68001	1	1	0	2	2525	8 	2012-09-04	768	680000	68001	1	52	1.00	1.00	2013-09-03	0
3 	3 	1098604432  	OSCAR EDUARDO VILLAMIZAR LOPEZ          	34	3	1985-12-02	2	CALLE 199A N° 38-19	6827240	68001	2	5	0	3	5525	8 	2012-03-15	714	1000000	68001	1	52	1.00	1.00	2013-03-14	0
4 	4 	1096188881  	ELIAS ARDILA FLOREZ                     	15	3	1986-03-24	2	CRA.35A N° 75BIS - 305	3208938275	68081	1	5	1	2	2525	8 	2012-07-25	755	680000	68081	1	52	1.00	1.00	2013-07-24	0
2 	2 	1102358207  	NATALY BARBOSA CHAVES                   	17	3	1988-10-18	1	CRA. 4B N° 4A-20	3177981669	68001	1	1	1	2	2525	8 	2012-04-28	732	566700	68001	1	52	1.00	1.00	2013-04-27	0
8 	8 	37747931    	DIANA MARIA ORTIZ BALAGUERA             	60	3	1979-12-18	1	MESA DE RUITOQUE	3214870485	68001	1	5	1	2	2525	8 	2012-03-14	712	700000	68001	1	52	1.00	1.00	2013-03-13	0
9 	9 	1102548409  	JAIRO ALBERTO SUAREZ CALA               	15	3	1987-10-22	2	DIG 8 21A 13	3164909192	68307	1	5	0	2	252525	8 	2012-11-21	804	566700	68001	1	52	1.00	1.00	2013-11-20	0
1 	1 	13567178    	ANGEL ALBERTO VARGAS TORRES             	15	3	1983-07-05	1	TRAV 64 LOTE 15 20 DE AGOSTO	3136153291	68081	1	5	0	2	252525	8 	2012-11-13	795	566700	68081	1	52	1.00	1.00	2013-11-12	0
1 	1 	1096206469  	MAIRA ALEJANDRA VERGARA PABUENA         	17	3	1990-07-24	1	DIG 57 CASA 101 EL DANUBIO	6100897	68081	3	5	0	2	252525	8 	2012-11-09	796	680000	13430	1	52	1.00	1.00	2013-11-12	0
9 	9 	1098709980  	YURY KATHERINE GONZALEZ AFANADOR        	17	3	1991-09-01	1	CALLE 28 N° 8 OCC 05	6522045	68001	3	1	0	2	252525	8 	2012-11-09	797	566700	68001	1	52	1.00	1.00	2013-11-08	0
9 	9 	1102370888  	SILVIA MARCELA CARREÑO GONZALEZ         	17	3	1993-04-15	1	CALLE 5 391	6554027	68001	1	5	0	2	252525	8 	2012-12-01	806	566700	68001	1	52	1.00	1.00	2013-11-30	0
12	12	1095813196  	HEYDER RICARDO JAIMES ARDILA            	15	3	1992-07-04	2	CRA 17 B 14 C 23	6592396	68307	1	5	0	2	252525	8 	2013-07-01	807	680000	68001	0	52	1.00	1.00	2013-11-30	0
9 	9 	1102774565  	JHON JAIRO TOLOZA GUERRERO              	15	3	1992-11-12	2	CRA 22 19 68	6805955	68307	1	5	0	2	252525	8 	2012-12-01	808	680000	68001	1	52	1.00	1.00	2013-11-30	0
4 	4 	1037624218  	YENNIFER CAMILA ALARCON URIBE           	17	3	1992-09-30	1	CALLE 52 57-29	3203109215	68081	1	1	0	2	252525	8 	2012-12-05	809	680000	5001 	1	52	1.00	1.00	2013-12-04	0
10	10	1098680295  	DIANA MARCELA SANTOS VELANDIA           	17	3	1989-11-10	1	CALLE 1 A 16 20	6542575	68547	1	2	0	2	252525	8 	2012-12-05	810	680000	68001	1	52	1.00	1.00	2013-12-04	0
0 	0 	1095925850  	LAURA CATALINA GONZALEZ DOMINGUEZ       	29	1	1991-04-22	1	CALLE 28 A 31-33	6469831	68307	1	1	0	3	252525	8 	2012-12-11	811	1000000	68001	1	51	1.00	1.00	2013-12-11	0
4 	4 	1095796778  	JENNIFER MARION UMAÑA ORTEGA            	17	3	1988-04-20	1	CRA 19 49-17	3174928179	68081	1	5	0	2	252525	8 	2012-12-07	812	680000	68276	1	52	1.00	1.00	2013-12-06	0
2 	2 	63544653    	LUZ DARY JEREZ MUÑOZ                    	17	3	1983-11-12	1	MANZANA 4 CASA 1	3157029347	68276	1	1	0	2	252525	8 	2015-02-19	816	680000	1001 	0	52	1.00	1.00	2013-12-21	0
10	10	1102363927  	CAROLINA SANCHEZ GUTIERREZ              	17	3	1990-05-29	1	CRA 4 A 4-04	3134172524	68547	1	5	0	2	252525	8 	2012-12-22	817	680000	68547	1	52	1.00	1.00	2013-12-22	0
10	10	1102369100  	PAOLA ANDREA DIAZ BAUTISTA              	39	3	1992-09-08	1	CALLE 14 1-09	6542580	68547	1	5	0	2	252525	8 	2012-12-22	818	680000	68547	0	52	1.00	1.00	2013-12-21	0
7 	7 	1098667093  	GUZMAN ANTONIO PARDO PAEZ               	15	3	1988-04-07	2	CALLE 104 16-24	6376274	68001	1	1	0	2	252525	8 	2012-12-27	819	680000	68001	1	52	1.00	1.00	2013-12-26	0
9 	9 	1098754672  	YADIRIS LAGOS GARCIA                    	17	3	1994-05-04	1	CALLE 61 17 A 14	6411533	68001	1	5	0	2	252525	8 	2012-12-27	820	680000	68001	1	52	1.00	1.00	2013-12-26	0
10	10	1085094885  	ANA EDIS DIAZ ARIAS                     	17	3	1990-07-20	1	PASEO REAL C 21 2-61	3116909672	68547	1	5	0	2	252525	8 	2013-01-02	821	680000	47245	1	52	1.00	1.00	2014-01-01	0
2 	2 	91354494    	LUIS FERNANDO BLANCO VARGAS             	15	3	1982-12-01	2	CRA 27 C 14-18	6556804	68547	1	5	0	2	252525	8 	2013-01-02	822	680000	20710	1	52	1.00	1.00	2014-01-01	0
10	10	1102363678  	VIVIANA ANDREA GARCIA ADARME            	60	3	1990-05-27	1	TRANSVERSAL 11 A 12-49	6562497	68547	3	1	0	2	252525	8 	2013-01-02	823	700000	68001	1	52	1.00	1.00	2014-01-01	0
10	10	1102369344  	DIANA MARCELA FLOREZ GUTIERREZ          	39	3	1992-07-11	1	CALLE 14 1-19	3167313561	68547	1	2	0	2	252525	8 	2013-01-02	824	680000	68547	1	52	1.00	1.00	2014-01-01	0
10	10	1097609382  	VICTORIA ACUÑA BELTRAN                  	17	3	1989-08-23	1	CRA E 3-22	3134667460	68547	1	1	0	2	252525	8 	2014-03-19	825	680000	68013	1	52	1.00	1.00	2014-01-01	0
7 	7 	6794125     	FRANCISCO MINORTA MONTEJO               	12	3	1964-05-10	2	CRA 40 C 105-18	6772883	68276	2	6	0	2	252525	8 	2013-01-09	826	3000000	20517	0	52	0.00	1.00	2014-01-08	0
0 	0 	1096186055  	CARMEN ROSA TEJADA                      	29	1	1986-08-25	1	CALLE 47 12 C 25	6203645	68081	2	5	0	3	252525	8 	2013-01-09	827	1100000	68081	0	51	1.00	1.00	2014-01-08	0
8 	8 	1102366318  	LEIDY MARIA LEAL CAMACHO                	17	3	1991-03-01	1	CALLE 9 3-32	3156469672	68547	1	5	0	2	252525	8 	2013-01-10	828	680000	68547	1	52	1.00	1.00	2014-01-09	0
4 	4 	1098706150  	YERALDIN SALAS DURAN                    	17	3	1991-05-29	1	CRA 73 19 A 43	3167449881	68081	2	5	0	2	252525	8 	2013-07-02	829	680000	68081	1	52	1.00	1.00	2014-01-09	0
0 	0 	63508027    	HERMINDA CONTRERAS VARGAS               	29	1	1976-01-18	1	DIAG. 21B No 17-121 CASA15 MANZ L	3176959119	68001	2	1	1	2	34564	8 	2013-01-14	838	1800000	68001	0	51	0.00	1.00	2014-01-13	0
9 	9 	1098752349  	MARGARETH ALEXANDRA RUEDA VELASCO       	39	3	1994-03-16	1	CRA 11w-64-44 MONTERREDONDO	6417088	68001	1	1	0	2	43123	8 	2013-01-18	839	680000	68001	1	52	1.00	1.00	2014-01-17	0
3 	3 	1085048477  	ROSAURA RADA NAVARRO                    	60	3	1989-04-14	1	CRA 22 N o 18-15 APTO 504	3103931412	68001	1	1	0	2	1315416	8 	2013-01-14	832	680000	68001	1	52	1.00	1.00	2014-01-13	0
2 	2 	1098670738  	OLGA YAJAIRA LIÑAN ALQUICHIRE           	17	3	1989-05-18	1	CRA 44 No 147D-03	3168031212	68001	1	3	0	2	65464	8 	2013-01-12	833	680000	68001	1	52	1.00	1.00	2014-01-11	0
4 	4 	1096201827  	EDWARD MAURICIO ALMANZA ASCENCIO        	15	3	1989-07-14	2	CLL 50 No 35-129	6212084	68001	1	5	0	2	24345	8 	2013-02-21	834	680000	68001	1	52	1.00	1.00	2014-01-11	0
4 	4 	1096215920  	JUAN CARLOS BARON ROJAS                 	15	3	1992-05-18	2	DIG 74 E 35-41	6020519	68081	1	5	0	2	654	8 	2013-01-12	835	680000	68081	1	52	1.00	1.00	2014-01-11	0
2 	2 	7227564     	LUIS EDUARDO CEPEDA  HERNANDEZ          	20	3	1969-12-10	2	CALLE 19 NO 27A-28	3134971378	68001	3	5	0	2	135	8 	2013-01-15	836	1400000	15104	1	52	1.00	1.00	2014-01-14	0
4 	4 	37861250    	GINA VANESSA VERGARA RAMIREZ            	17	3	1981-04-09	1	CRARRERA 29 No 4-58	3144220215	68081	1	5	0	2	231	8 	2013-01-11	837	680000	68081	1	52	1.00	1.00	2014-01-10	0
2 	2 	1098684344  	CRISTHY YURLEY CAICEDO                  	17	3	1990-01-26	1	CRA 59 A 146 20	6160434	68276	1	5	0	2	252525	8 	2012-11-08	798	680000	68001	1	52	1.00	1.00	2013-11-07	0
9 	9 	1102718799  	SILVIA JULIANA FIALLO SANDOVAL          	17	3	1990-02-02	1	CALLE 41 N° 53A BIS - 30	6204329	68081	1	5	0	2	252525	8 	2013-12-17	686	680000	68001	1	52	1.00	1.00	2012-11-30	0
0 	0 	1095915931  	NATALIA ACEVEDO AGUILAR                 	29	1	1989-01-04	1	CALLE 14 No 16-58	3173528180	68001	1	1	0	4	132136	8 	2013-04-17	840	900000	68001	1	51	1.00	1.00	2014-01-16	0
10	10	1102370065  	LEIDY KATHERINE MUÑOZ CASTELLANOS       	17	3	1992-10-25	1	CLL 1C No 8A-49 APTO 201	6551415	68001	1	1	0	2	13	8 	2013-01-18	841	680000	68001	1	52	1.00	1.00	2014-01-17	0
0 	0 	63530043    	KELLY JOHANA NIÑO GONZALEZ              	29	1	1982-03-22	1	CLL 7 No 16-06 LIMONCITO	6184770	68001	1	1	0	5	131	8 	2013-01-30	850	3700000	68001	0	51	0.00	1.00	2014-01-15	0
10	10	1102372925  	LINA FERNANDA MONSALVE TOSCANO          	17	3	1994-02-20	1	MANZ 0 CASA 217-523	3166419754	68001	1	1	0	2	3123132	8 	2013-02-20	857	680000	68001	0	52	1.00	1.00	2014-02-19	0
2 	2 	1095810482  	LINA ANDREA SOSA CAMARGO                	17	3	1991-10-29	1	CRA 6 NO 7-24	6488828	68001	1	1	0	2	666666663265	8 	2013-02-23	858	680000	68001	1	52	1.00	1.00	2014-02-22	0
8 	8 	1098736737  	LUISA GABRIELA LEON DIAZ                	17	3	1993-04-23	1	MESA DE RUITOQUE- LAS COLINAS	6786358	68001	1	1	0	2	23221	8 	2013-01-18	842	680000	68001	1	52	1.00	1.00	2014-01-17	0
10	10	1102364844  	WILLINGTON MENESES GALVIZ               	10	3	1990-10-07	2	CALL 14 No 6B-19	6555876	68001	1	1	0	2	2356	8 	2013-02-23	859	700000	68001	1	52	1.00	1.00	2013-02-22	0
10	10	1098649891  	CARLOS ANDRES QUESADA MONTOYA           	43	3	1988-03-01	2	CRA 13 No 7-57 SAN RAFAEL	6557162	68001	2	1	0	2	21454456	8 	2013-02-21	860	680000	68001	0	52	1.00	1.00	2014-02-20	0
10	10	37619881    	DIANA MARCELA RUEDA MALAGON             	17	3	1984-12-04	1	CLL 1C-No 8A-81	6557049	68001	1	1	0	2	32	9 	2013-02-16	861	680000	68001	0	52	1.00	1.00	2014-02-15	0
7 	7 	1098654562  	LILIBETH MELO MORALES                   	17	3	1988-05-26	1	CRA. 7 N° 66-50	3142898611	68001	2	1	1	2	202025	8 	2012-03-21	715	566700	68001	1	52	1.00	1.00	2013-03-20	0
10	10	1102359659  	JUAN CARLOS VERA CHANAGA                	15	3	1989-04-06	2	CRA 11 NO 3-39	6564533	68001	1	1	0	2	23	8 	2013-02-07	851	680000	68001	1	52	1.00	1.00	2014-02-06	0
7 	7 	1098637258  	EDGAR ANDRES ARDILA NUÑEZ               	15	3	1986-09-18	2	CLL 114 No 45-02	6481218	68001	1	1	0	2	5131	8 	2013-02-12	852	680000	68001	1	52	1.00	1.00	2014-02-11	0
1 	1 	1030575326  	JUNIOR ANDRES CHACON CANO               	15	3	1990-06-17	2	CLL 48 No 8-39 CARDALES	3203281379	68081	1	1	0	2	431	8 	2013-02-07	853	680000	68081	1	52	1.00	1.00	2014-02-06	0
7 	7 	1102369381  	JHON EDINSON CARRENO MORALES            	33	3	1992-10-08	2	CALLE 12 No 4-15	6556129	68001	1	1	0	2	213212	8 	2013-11-07	854	770000	68001	0	52	1.00	1.00	2014-02-04	0
3 	3 	91480148    	ALEXANDER RIBERO LOPEZ                  	102	3	1975-10-08	2	CRQA 6 No 13-18	6551389	68001	2	1	0	3	232	8 	2013-02-06	855	1550000	68001	1	52	0.00	1.00	2014-02-05	0
1 	1 	1096207333  	MARLON YESID JARAMILLO LOPEZ            	15	3	1990-09-02	2	CALLE 74 No 34C-17 CIUDADELA PIATON	3134464275	68001	1	1	0	2	1346531	8 	2013-02-23	862	680000	68001	1	52	1.00	1.00	2014-02-22	0
2 	2 	1098709281  	OLGA CECILIAN SEPULVEDA PINEDA          	17	3	1991-08-18	1	VGFDGR	56325312	68001	2	1	0	5	213145	8 	2013-02-26	863	680000	68001	1	52	1.00	1.00	2014-02-25	0
10	10	1102372778  	WILLIAM FERNEY RUEDA ORTIZ              	15	3	1994-01-10	2	GGDFGF	413636	68001	2	1	0	5	131	8 	2014-06-27	864	680000	68001	1	52	1.00	1.00	2014-02-26	0
3 	3 	1098750962  	MARTIN EDUARDO LOZANO MUÑOZ             	10	3	1993-12-09	2	CRA 41 nO 59-59	6416220	68001	2	1	0	5	221	2 	2013-03-08	865	800000	68001	0	52	1.00	1.00	0201-03-07	0
1 	1 	1096205408  	NILSON TORRES SALGUERO                  	15	3	1990-03-08	2	CALLE 49 No 54-14 VILLARELIS 2	3208970218	68081	2	1	0	5	0	8 	2013-03-06	866	680000	68081	1	52	1.00	1.00	2014-03-05	0
7 	7 	1098606572  	JOHANNA MARCELA PINZON LOPEZ            	17	3	1985-06-28	1	CLL 28 NO 3 OCC NAPOLES	6530094	68001	2	1	0	5	323213	8 	2013-03-01	867	680000	68001	1	52	1.00	1.00	2014-03-01	0
7 	7 	1101320923  	LUZ MIREYA CALDERON RAMIREZ             	39	3	1992-05-11	1	CRA 7 nO 42-41 EDIF. OVIEDO	6422134	68001	1	1	0	2	132131	8 	2014-08-29	868	680000	68001	1	52	1.00	1.00	2014-03-01	0
1 	1 	1099370145  	YESSICA MARCELA FORERO NAVARRO          	17	3	1993-06-19	1	CALLE 48 No 11-34 EL DORADO	3157060889	68001	1	1	0	2	451536	8 	2013-03-15	869	680000	68001	1	52	1.00	1.00	2014-03-14	0
4 	4 	1096219159  	KELLY JOHANA BALLESTEROS GUTIERREZ      	17	3	1992-12-24	1	CRA 36B No 37B-55B ALTOS DE CAÑAVERAL	3134253328	68081	1	1	0	2	13121	8 	2013-03-15	870	680000	68081	0	52	1.00	1.00	2014-03-14	0
4 	4 	1096193001  	JAN CARLOS LIÑAN SANCHEZ                	15	3	1987-11-24	2	CALLE 49 NO 54-41	3204122805	68081	1	3	0	2	21323	8 	2013-03-16	871	680000	68081	0	52	1.00	1.00	2014-03-15	0
0 	0 	91522709    	DAVID GOYENECHE RAMIREZ                 	29	3	1983-09-23	2	CARRERA 28A No 67-37 LA SALLE	3003735306	68001	1	1	0	5	131331	8 	2013-04-08	872	3500000	68001	1	52	0.00	1.00	2014-04-08	0
10	10	1102370890  	LEIDY KATERIN GOMEZ ORDUZ               	17	3	1993-04-04	1	CALLE 2 nO 8-37 VILLALUZ	6544262	68001	1	1	0	2	323121	8 	2013-04-26	880	680000	68001	0	52	1.00	1.00	2014-04-25	0
2 	2 	1095806431  	CARLOS EDUARDO SANCHEZ HERNANDEZ        	15	3	1990-10-11	1	BLOQUE 13-4 APTO 301 BUCARICA	3118069434	68001	1	1	0	2	21312	8 	2013-04-23	881	680000	68001	1	52	1.00	1.00	2014-04-22	0
2 	2 	1095791180  	MONICA MARCELA DIAZ MARTINEZ            	17	3	1992-03-10	1	CALLE 22B No 7A-51 MONTEBLANCO	6485727	68001	2	1	0	5	2131231	8 	2013-04-18	882	680000	68001	1	52	1.00	1.00	2014-04-18	0
8 	8 	91519228    	JORGE LUIS JAIMES PATIÑO                	15	3	1983-05-24	2	SECTOR 4 BLOQUE 1-18 APTO 403	6720526	68001	1	7	0	2	54312	8 	2013-04-21	883	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1095819116  	ZULLY TATIANA PINZON GARNICA            	40	3	1994-04-25	1	BLOQ 7 -4 APTO 401	6049431	68001	1	1	0	2	1321	8 	2013-04-20	884	680000	68001	0	52	1.00	1.00	2014-04-19	0
3 	3 	80734086    	EDUARD CABRERA CASTELLANOS              	12	3	1982-10-10	2	LAGOS 5 ETAPA TORRE 1 APTO 503	6374739	68001	2	1	0	5	231312	8 	2013-04-17	885	2300000	68001	0	52	0.00	1.00	2014-04-10	0
9 	9 	1098758160  	LICETH KARINA TORRES CABALLERO          	17	3	1994-07-11	1	CRA 10 No 7N-40	6408793	68001	1	1	0	2	1312	8 	2013-04-26	886	680000	68001	1	52	1.00	1.00	2014-04-25	0
7 	7 	1098624324  	JEIMY LUCERO ZAMORA RAMIREZ             	17	3	1986-10-10	1	CALLE 22 N° 24-69 ED. ARAPAIMA	6452165	68001	3	5	0	2	25255	8 	2011-12-29	694	566700	68001	1	52	1.00	1.00	2012-12-28	0
0 	0 	79709738    	RAUL RODRIGUEZ GARCIA                   	29	1	1974-03-27	2	DIAGONAL 105 No 104E-196 TORRE 4 APTO 10	6906544	68001	2	3	0	5	321	8 	2013-04-02	873	3800000	68001	1	51	0.00	1.00	2014-05-30	0
4 	4 	1095800932  	ALEXANDER ESTRADA SALAZAR               	15	3	1989-06-16	2	DG. 62 N° 46-93	3118179785	68001	2	5	1	2	2525	8 	2012-07-02	711	566700	68001	1	52	1.00	1.00	2013-03-02	0
4 	4 	1096193381  	ROGELIO ANDRES PRADA VERGARA            	15	3	1987-11-15	2	CALLE 52C N° 34-139	6100206	68081	1	5	0	2	2525	8 	2012-03-16	716	680000	68081	1	52	1.00	1.00	2013-03-15	0
9 	9 	1095927966  	JHON JAIRO ROJAS VELASQUEZ              	15	3	1992-02-13	2	CALLE 11A No 18-11 RIO PRADO	6595790	68001	2	1	0	5	31213	8 	2013-04-25	887	680000	68001	0	52	1.00	1.00	2014-04-09	0
0 	0 	63540998    	ESTEFANIA ALVIS ORTEGA                  	29	1	1986-12-01	1	1	524654	68001	2	1	0	5	2413243	8 	2013-07-02	889	860000	68001	1	51	1.00	1.00	2014-05-01	0
0 	0 	1098615250  	YENY PAOLA GOMEZ FLOREZ                 	29	1	1985-10-01	1	CALL 52 No 23-68/ EDIF SOTO MAYO	6576066	68001	2	1	0	5	13132	8 	2013-05-02	890	1500000	68001	1	51	0.00	1.00	2014-05-01	0
2 	2 	1098638134  	JAVIER CELIX OREJARENA                  	20	3	1987-05-06	2	CALL 51 No 21-27 NUEVO SOTOMAYOR	3016032779	68001	2	1	0	5	258285	8 	2014-10-19	891	1550000	68001	1	52	0.00	1.00	2014-05-01	0
2 	2 	63555794    	STELLA ANDRADE SOSA                     	17	3	1986-12-01	1	CALLE 147 C No 44-39 PRADOS DEL SUR	313351764	68001	2	1	0	5	213	20	2013-05-07	892	680000	68001	1	52	1.00	1.00	2014-05-07	0
4 	4 	1098756409  	LEIDY PAOLA RODRIGUEZ CAMACHO           	17	3	1994-06-05	1	villa plata casa 42	3108593690	68001	2	1	0	5	3	13	2013-05-04	893	680000	68081	1	52	1.00	1.00	2014-05-04	0
4 	4 	1096228126  	JHOLLMAN CERVANTES DURAN                	15	3	1994-06-05	2	cra 34 nO 58d-50	3163870258	68001	2	1	0	5	23213	8 	2013-05-05	894	680000	68001	1	52	1.00	1.00	2014-05-05	0
1 	1 	1096216121  	ELOISA MANTILLA ARIAS                   	17	3	1992-07-08	1	CRA 36B No 75-58 LA PAZ	6113795	68081	2	1	0	5	212	8 	2013-07-04	895	680000	68081	1	52	1.00	1.00	2014-05-17	0
4 	4 	1097609320  	JERSON DAVID LOPEZ GARNICA              	15	3	1989-04-14	2	CALL 29 LOTE 13 LOS COMUNEROS	31233917171	68081	2	1	0	5	23362	8 	2014-08-02	896	680000	68081	1	52	1.00	1.00	2014-05-15	0
4 	4 	1096223243  	MARLON ANDRES DIAZ RODRIGUEZ            	15	3	1993-08-31	2	CARRERA 60 NO 38-30 LA ESPERANZA	3133537159	68081	1	1	0	5	322	8 	2013-05-16	897	680000	68081	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096226764  	GERALDINE VANESSA CRUZ SANGUINETTI      	17	3	1994-03-23	1	CRA 35 No 37 -46 BUIENOS AIRES	6024348	68081	1	1	0	2	1313	8 	2013-05-26	898	680000	68081	0	52	1.00	1.00	2014-05-25	0
4 	4 	1096212660  	YESSICA ANDREA RIVERA GONZALEZ          	17	3	1991-10-05	1	CLL 71 No 24-77 LA LIBERTAD	6027637	68081	2	1	0	5	61312	8 	2013-05-22	899	680000	68081	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096222932  	ANDRES ALEXIS MARQUEZ LAGOS             	15	3	1993-07-30	2	CRA 36 76-21	3115007538	68081	1	1	0	2	252525	8 	2012-12-17	813	680000	68081	1	52	1.00	1.00	2013-12-16	0
0 	0 	1095938538  	KATHERIN VERA OSMA                      	29	1	1994-12-08	1	CALLE 31 No 30-15 VILLA CAROLINA	6462939	68001	1	5	0	3	5321	8 	2013-04-26	888	650000	68001	1	51	1.00	1.00	2014-04-25	0
9 	9 	1098697064  	HEIDY CAROLINA VARGAS                   	17	3	1990-07-30	1	CALLE 64C No 81 CIUDAD BOLIVAR	6410349	68001	2	1	0	5	2133213	8 	2013-06-08	900	680000	68001	1	52	1.00	1.00	2014-06-07	0
10	10	1102354586  	LUZ EDILMA ORTIZ ORTIZ                  	17	3	1987-11-24	1	DIAG. 7 TRANV 1N-03 LA ARGENTINA	3164033615	68001	2	1	0	5	2332352	8 	2013-06-12	901	680000	68001	0	52	1.00	1.00	2014-06-01	0
9 	9 	1098686379  	YULI CAROLINA BOTIA HERRERA             	17	3	1989-05-26	1	CALLE 15 No 18-23 PAISAJES DEL NORTE	3153607361	68001	2	1	0	2	13222	8 	2013-06-12	902	680000	68001	1	52	1.00	1.00	2014-06-11	0
4 	4 	1094165749  	ENNY YURLEY LUQUE RUEDA                 	39	3	1993-12-09	1	1	3134442022	68081	2	1	0	2	332223	8 	2013-06-09	903	680000	68081	0	52	1.00	1.00	2014-06-08	0
2 	2 	1098720164  	ANA TERESA HERNANDEZ                    	17	3	1992-04-12	1	CRA 6AN No 11-127 SANTA ANA	6393039	68001	2	1	0	5	23132	8 	2013-06-16	904	680000	68001	1	52	1.00	1.00	2014-05-10	0
0 	0 	91222098    	HERNANDO DULCEY ORDUZ                   	29	1	1962-02-26	2	cra 30 nO 20-47 apto 301	6994592	68001	2	1	0	5	52143	8 	2014-08-08	905	3800000	68001	1	51	0.00	1.00	2014-05-10	0
0 	0 	5338778     	CARLOS ANDRES GALVIS ROJAS              	29	3	1984-10-23	2	CRA 12C-No 103C-31 SAN TA MARIA	6370612	68001	2	1	0	5	2232	2 	2014-04-21	906	2000000	68001	1	52	0.00	1.00	2014-05-10	0
1 	1 	1039687496  	ARISLEYDA JIMENEZ SERNA                 	17	3	1988-05-15	1	1	1	68081	2	1	0	5	232232	8 	2013-06-28	911	680000	68081	1	52	1.00	1.00	2014-05-10	0
10	10	1102370751  	JUAN DIEGO RAMIREZ RODRIGUEZ            	15	3	1993-03-23	2	CARRERA 4C No 1C-22 CAMPO VERDE	3175554766	68001	2	1	0	5	1321	8 	2013-07-04	912	680000	68001	0	52	1.00	1.00	2014-05-10	0
12	12	1095938209  	SILVIA JULIANA PINILLA SILVA            	17	3	1994-10-15	1	CRA 22B No 19-51 PORTAL CAMPESTRE	6596216	68001	2	1	0	5	23231	8 	2013-07-09	913	680000	68001	0	52	1.00	1.00	2014-05-10	0
2 	2 	1098648863  	YINETH DAYANA ROJAS ROJAS               	17	3	1987-09-26	1	CARRERA 2E NO 32-150	6052493	68001	2	1	0	5	12005	51	2013-07-20	914	680000	68001	1	52	1.00	1.00	2014-05-01	0
8 	8 	1098700580  	OSCAR IVAN BARAJAS RAMIREZ              	15	3	1991-02-15	2	MESA DE RUITOQUE VERESA PALMERAS	6786644	68001	1	5	0	2	46323	8 	2013-07-18	915	680000	68001	1	52	1.00	1.00	2014-05-10	0
3 	3 	91521255    	EDWIN ALFONSO GALVIS RICO               	15	3	1980-12-29	2	CALLE 30 A 33 63	6531729	68307	3	1	0	2	252525	8 	2012-11-08	799	680000	68051	1	52	1.00	1.00	2013-11-07	0
3 	3 	1095933580  	ANGIE VANESSA ORTIZ PRADA               	17	3	1993-08-22	1	CALLE 14 12 S 16	3176503408	68307	3	5	0	2	252525	8 	2012-11-09	800	680000	68001	1	52	1.00	1.00	2013-11-08	0
10	10	1102720444  	YUDY ANDREA LLANES LOPEZ                	17	3	1991-10-04	1	CRA 4 DIG 4 A 10	3143454154	68547	1	5	0	2	252525	8 	2012-12-19	814	680000	68689	0	52	1.00	1.00	2013-12-18	0
9 	9 	1095815354  	SILVIA JULIANA RINCON PEÑA              	104	3	1993-04-04	1	CRA 13 7-38	3178871884	68276	1	5	0	2	252525	8 	2013-07-02	815	680000	68001	1	52	1.00	1.00	2013-12-17	0
1 	1 	72289586    	HERNANDO RAFAEL BARIOS ALEMAN           	15	3	1982-07-07	2	TRANV 44 No 51C-25	3182657910	68081	1	1	0	2	56436	8 	2013-01-25	843	680000	68081	1	52	1.00	1.00	2014-01-24	0
1 	1 	63467463    	ROSALBA SANCHEZ AGUILAR                 	17	3	1976-02-27	1	TRAV 46 NO 46-45	6103958	68081	1	1	0	2	5463	8 	2013-01-25	844	680000	68081	1	52	1.00	1.00	2014-01-24	0
4 	4 	1096212485  	CRISTIAN LONDOÑO MONCADA                	15	3	1991-12-19	1	CLL 34 No 34C -04 PRIMERO DE MAYO	3142458347	68001	1	1	0	2	536210	8 	2013-01-23	845	680000	68001	1	52	1.00	1.00	2014-01-22	0
4 	4 	1096229123  	YALITZA JOHANA MORA ALBIS               	40	3	1994-07-07	1	CRA 17A NO 43-40 BUENOS AIRES	6223448	68081	1	1	0	2	563	8 	2013-01-23	846	680000	68081	0	52	1.00	1.00	2014-01-22	0
2 	2 	1102349683  	ADRIANA ARENAS CORDERO                  	16	3	1986-05-08	1	CRA 4 No 16-33 HOYO GRANDE	3177605469	68001	1	1	0	2	252525	8 	2013-01-25	847	840000	68001	0	52	1.00	1.00	2014-01-24	0
7 	7 	72298456    	EDWIN ALBERTO ESCOBAR CASTILLO          	15	3	1985-12-03	2	BARRIO ALVAREZ	3172905403	68001	1	5	0	2	2525	8 	2011-12-19	691	566700	68001	1	52	1.00	1.00	2012-12-18	0
13	13	1102369513  	ANGY LICETH CARO FUENTES                	17	3	1992-08-10	1	CALLE 15A No 3WA-80 PORTAL DE BELEN	3156770646	68001	2	1	0	2	41321	8 	2014-09-20	916	680000	68001	1	52	1.00	1.00	2014-05-10	0
3 	3 	1098745687  	LORENA RANGEL CHAPARRO                  	17	3	1993-07-25	1	CALLE 10 No 23-27 LA UNIVERSIDAD	6770372	68001	2	1	0	2	523632	8 	2014-08-29	917	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	28484410    	ANSELMA KARINA SANTAMARIA NAVARRO       	17	3	1980-03-28	1	CALLE 26 No 64-21	3178763514	68001	2	1	0	2	4132	8 	2013-07-20	918	680000	68001	1	52	1.00	1.00	2014-05-10	0
12	12	1099369036  	DIANA CAROLINA DIAZ ESPARZA             	39	3	1992-09-19	1	CALLE 19H No 19-14 PORTAL CAMPESTRE NORT	3184800176	68001	1	5	0	2	1321	8 	2013-07-27	919	680000	68001	0	52	1.00	1.00	2014-05-10	0
8 	8 	43277946    	MARIA JAKELINE VIVEROS ORTIZ            	17	3	1981-03-08	1	CALLE 6 nO 4-200MZ 11	6894391	68001	1	1	0	2	3212	8 	2013-07-27	920	680000	68001	1	52	1.00	1.00	2014-05-10	0
1 	1 	1096201993  	JOHANNA PAOLA BARRERA RODRIGUEZ         	17	3	1989-10-22	1	CRA 34B nO 58-76	3138714269	68001	1	5	0	2	52	32	2013-07-27	921	680000	68001	1	52	1.00	1.00	2014-05-10	0
1 	1 	1096221354  	CARLOS ERNESTO VIDES PINTO              	15	3	1993-05-10	2	CALLE 26 No 61-41	3202801842	68001	1	7	0	2	21312	8 	2013-07-27	922	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	63563365    	YADIRA PEÑA RODRIGUEZ                   	17	3	1985-09-04	1	YADIRA PEÑA RODRIGUEZ	6408675	68001	2	1	0	5	14123	1 	2013-08-01	923	680000	68081	0	52	1.00	1.00	2014-05-10	0
9 	9 	1100890599  	MARTHA LILIANA GONZALEZ GOMEZ           	20	3	1988-11-29	1	CALLE 23 nO 28-45	6780481	68001	2	1	0	5	14545	8 	2013-08-12	924	1700000	68001	0	52	0.00	1.00	2014-05-10	0
0 	0 	91540567    	OSCAR JAVIER CELIS ASCENCIO             	29	3	1985-06-29	1	CRA 29 NO 93-31	6313840	68001	2	1	0	5	1441323	8 	2013-08-08	925	2500000	68001	0	52	0.00	1.00	2014-05-10	0
2 	2 	1102360588  	NAYIBE GOMEZ CALA                       	17	3	1989-05-27	1	CARRERA 18 No 61-09 LA TRINIDAD	3005496423	68001	2	1	0	5	213	8 	2013-08-06	926	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1097610012  	JENNY CAMACHO HERNANDEZ                 	17	3	1991-02-07	1	1	3132433125	68081	2	1	0	5	2132	8 	2013-08-02	927	680000	68081	1	52	1.00	1.00	2014-05-10	0
10	10	1102373326  	DANIA GRACIELA HERNANDEZ MELON          	40	3	1994-02-17	1	CALLE 6 nO 14-28 SAN RAFAEL	3153275817	68001	2	1	0	5	21323	8 	2013-08-13	928	680000	68001	0	52	1.00	1.00	2014-05-10	0
3 	3 	1085227259  	DALGY MARGARITA SIERRA MARQUEZ          	17	3	1990-03-06	1	CALLE 19 No 24-55 SAN FRANCISCO	3167121045	68001	2	1	0	5	11335	8 	2015-01-03	929	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	63552118    	PRISCILLA GUARIN                        	17	3	1984-06-16	1	CARRERA 34 No 34-41	3004730438	68001	2	1	0	5	1231	8 	2013-08-24	930	680000	68001	0	52	1.00	1.00	2014-05-10	0
4 	4 	1098654489  	FABIAN ANDRES GARCIA VERGARA            	15	3	1988-03-23	2	CARRERA 36 E No 58-43 BARRIO ALCAZAR	3106975971	68001	1	1	0	2	1311	8 	2014-07-02	931	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1095931690  	SERGIO NICOLAS GOMEZ GARCIA             	15	3	1993-02-16	2	CARRERA 22 NO 19-68 PORTAL CAMPESTRE	6805955	68001	2	1	0	2	65436	8 	2013-08-16	932	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096185968  	GABRIELA OVIEDO GONZALEZ                	17	3	1986-06-04	1	DIAGONAL 63 No 46-15 EL 20 DE AGOSTO	6219357	68001	2	1	0	2	13123	8 	2013-08-22	933	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	63551057    	JUDITH GOMEZ SANDOVAL                   	17	3	1984-06-12	1	calle 76 nO 20-08	3183416299	68001	1	1	0	2	12312	25	2013-08-22	934	680000	68001	0	52	1.00	1.00	2014-05-10	0
1 	1 	1096202002  	JORGE LEONARDO PRADA VERGARA            	15	3	1989-10-14	1	CALLE 52  no 34C-139 CHAPINERO	6025631	68001	2	1	0	2	2123	8 	2013-08-23	935	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1098698123  	SILVIA PATRICIA DUARTE DUARTE           	17	3	1990-11-12	1	CALLE 57A No 43w-52 LOS ESTORAQUES	3212226555	68001	3	1	0	2	1312	8 	2013-09-01	936	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1095822646  	JHON FREDY BENAVIDES TORRES             	15	3	1995-01-16	2	URBANIZACION PLAZA SAN MARCOS - RM	3174676859	68001	1	1	0	2	589500	40	2013-09-01	937	680000	68001	1	52	1.00	1.00	2014-05-10	0
3 	3 	1100502400  	DORIS EDILIA RUIZ CHIA                  	17	3	1989-02-26	1	CALLE 14 NO 21-31 SAN FRANCISCO	6710083	68001	2	1	0	1	231232	8 	2013-09-08	938	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1095818554  	PAOLA ANDREA DAVILA URIBE               	17	3	1994-01-03	1	CALLE 123 No 47-28 ZAPAMANGA	6493610	68001	2	1	0	2	45213	8 	2013-09-08	939	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	37862124    	EDUVIGES LINETT VESGA GALEANO           	18	3	1991-06-27	1	CALLE 2B NO 16A-38	3163069445	68001	1	1	0	4	13123	26	2013-09-26	950	1200000	68001	0	52	1.00	1.00	2014-05-10	0
7 	7 	1098732853  	DENIA CENITH ALVAREZ RIVERA             	17	3	1993-01-04	1	CALLE 68 No 6-66 BUCARAMANGA	318872270	68001	1	1	0	2	123	40	2013-10-19	953	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	1095806029  	YANIT LIZET VEGA PATIÑO                 	17	3	1990-07-08	1	MESA DE RUITOQUE VEREDA LA ESPERANZA	6786219	68001	2	1	0	2	2232	8 	2013-10-21	954	680000	68001	1	52	1.00	1.00	2014-05-10	0
0 	0 	1095807359  	PAOLA JIMENA SANCHEZ TOBON              	29	1	1990-12-07	1	BLOQUE 10-9 APTO 302 BUCARICA	6045854	68001	1	7	0	3	13232	8 	2013-10-15	955	1100000	68001	0	51	1.00	1.00	2014-05-10	0
12	12	1098649030  	CARLOS ANDRES AYALA DELGADO             	15	3	1988-01-26	2	CALLE 28 No 28-20 LA SALLE	6576640	68001	1	7	0	2	321221321	8 	2013-10-25	957	680000	68001	1	52	1.00	1.00	2014-05-10	0
0 	0 	37751149    	MARIA JULIANA MOYA GIRALDO              	29	1	2013-10-23	1	ALTOS DEL JARDIN CS 37	6439823	68001	1	7	0	4	11321	8 	2015-01-03	956	2300000	68001	0	51	0.00	1.00	2014-05-10	0
2 	2 	1095818629  	JOHAN JARWIN JARAMILLO JIMENEZ          	15	3	1994-03-06	2	FCSDGH	544635	68001	1	7	0	2	41362	8 	2013-10-29	959	680000	68001	0	52	1.00	1.00	2014-05-10	0
13	13	1102376637  	JHON FREDY VELOZA VILLAMIZAR            	15	3	1995-03-20	2	hyrtfhty	5223	68001	2	1	0	5	321	32	2013-11-08	960	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1095818357  	ASTRID KARYNA MARTINEZ SANCHEZ          	17	3	1993-11-19	1	CALLE 200A N° 19-17	3186354845	68001	1	5	2	2	252526	8 	2012-06-13	744	680000	68001	1	52	1.00	1.00	2013-06-12	0
10	10	1102375812  	JULIETH VANESSAN CABRERA JAIMES         	17	3	1994-12-27	1	CALLE 2 CW91	6546217	68547	1	5	0	2	3566	8 	2013-01-25	848	680000	68547	1	52	1.00	1.00	2014-01-24	0
10	10	1102374213  	WENDY MELISSA LOPEZ MANRIQUE            	17	3	1994-05-25	1	CALLE 11 10-74	3157714890	68547	1	5	0	2	252525	8 	2013-01-25	849	680000	68001	1	52	1.00	1.00	2014-01-24	0
7 	7 	1098671577  	YULI MARCELA PINZON                     	17	3	1989-05-17	1	CLL 21 No 28-50 apto 502	3163096986	68001	2	1	0	5	2556	23	2013-06-26	907	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1095920418  	FREDY SOCHA OVIEDO                      	15	3	1990-01-17	1	calle 104 No 40a-58 san bernardo	6773755	68001	2	1	0	5	132132	8 	2013-06-26	908	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	13872902    	SERGIO LEONARDO PORRAS CALDERON         	33	3	1981-06-06	1	SECTOR D TORRE 6 APTO 503	6389080	68001	2	1	0	5	1321	8 	2013-06-25	909	840000	68001	0	52	1.00	1.00	2014-05-10	0
13	13	1102348211  	DIEGO ARMANGO BASTO NAVAS               	15	3	1985-11-16	2	,g,g}rtyu	2263	68001	2	1	0	5	12	25	2013-11-08	961	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	13720403    	GABRIEL CAMELO MANCERA                  	15	3	1979-06-24	2	rfewter	513	68001	2	1	0	1	232	8 	2015-02-19	962	680000	68001	0	52	1.00	1.00	2014-05-10	0
10	10	63475898    	MONICA TORRES RINCON                    	17	3	1973-08-27	1	csdf.sdkfe	11414	68001	2	1	0	1	5413	8 	2015-02-19	963	680000	68001	0	52	1.00	1.00	2014-05-10	0
10	10	13927357    	CIRO ANTONIO PINTO MORENO               	33	3	1974-09-14	2	<z	6584	68001	2	1	0	2	531	8 	2015-02-19	964	770000	68001	0	52	1.00	1.00	2014-05-10	0
0 	0 	63316458    	LUZ ESTHER CAMARGO AVELLANEDA           	29	1	1965-06-17	1	mxcvxcv	68521	68001	2	1	0	2	2222	5 	2013-11-08	965	1500000	68001	0	51	0.00	1.00	2014-05-10	0
10	10	1100889901  	YURBY OCHOA GONGALEZ                    	39	3	1988-07-03	1	vdfdghd	493	68001	2	1	0	2	13213	40	2013-11-08	966	680000	68001	0	52	1.00	1.00	2014-05-10	0
13	13	1102371340  	JESSICA PAOLA FLOREZ OVIEDO             	17	3	1993-06-17	1	dvgdfgh	6555	68001	2	1	0	2	2333	8 	2013-11-08	967	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	1102368768  	YESSICA PAOLA CAMACHO DURAN             	17	3	1992-03-15	1	dfddfgg	5558936	68001	2	2	0	2	1213	8 	2013-11-14	968	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098724661  	JERSON LEANDRO VILLAMIZAR MALDONADO     	15	3	1992-08-01	2	fgdh	47257	68001	2	1	0	2	21632	8 	2013-11-14	969	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	1098762448  	SANDRID LORENA PEINDO QUESADA           	17	3	1994-11-10	1	132	35555	68001	2	1	0	2	52555	8 	2013-11-14	970	680000	68001	0	52	1.00	1.00	2014-05-10	0
3 	3 	91530564    	OSCAR MAURICIO DIAZ GUZMAN              	34	3	1984-07-17	2	xcvcx	6544	68001	2	1	0	2	25558	8 	2013-11-13	971	1250000	68001	1	52	0.00	1.00	2014-05-10	0
10	10	1098408176  	FRANCY MARCELA PRADA MARTINEZ           	17	3	1991-10-29	1	fsdd	5587	68001	1	1	0	2	1322	8 	2013-11-16	972	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1098716563  	YEISON ALFONSO HERNANDEZ CARVAJAL       	15	3	1992-01-02	2	asdad	425254	68001	2	1	0	2	55848	8 	2013-11-15	973	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1039685508  	AURA MARCELA MARIN LOPERA               	17	3	1988-07-03	1	CARREA 15B No 53-33	3136038575	68001	2	1	0	2	6346	8 	2013-11-16	978	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098643251  	MARIA FERNANDA GAMBOA CAICEDO           	16	3	1987-06-22	1	bngfh	53265	68001	2	1	0	2	52163	8 	2013-11-10	974	840000	68001	0	52	1.00	1.00	2014-05-10	0
2 	2 	63454411    	LEIDY JOHANNA HERNANDEZ PIÑA            	17	3	1985-11-15	1	ghfjh	55558	68001	2	1	0	4	52653	8 	2013-11-06	975	680000	68001	0	52	1.00	1.00	2014-05-10	0
8 	8 	1102360084  	JUAN JOSE LEON ROA                      	15	3	1989-02-26	2	hfghg	55478	68001	2	1	0	5	2558	8 	2013-11-06	976	680000	68001	1	52	1.00	1.00	2014-05-01	0
12	12	1095938432  	LAURA LIZZETH MERLO PEDROZA             	17	3	1994-10-12	2	dfsgdfg	54136	68001	2	1	0	5	558	8 	2014-07-16	977	680000	68001	0	52	1.00	1.00	2014-05-10	0
12	12	1098677029  	CARLOS MAURICIO DIAZ MEJIA              	20	3	1989-10-03	2	CALLE 10B-26-16 ARENALES II ETAPA	3164065183	68001	2	1	0	2	220	40	2013-11-18	979	1700000	68001	0	52	0.00	1.00	2014-05-10	0
4 	4 	1098692147  	VIVIANA VILLAMIZAR MEJIA                	17	3	1990-07-19	1	1	1	68001	2	1	0	2	236310	8 	2013-11-16	980	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1085167421  	JOSE MANUEL CASTRO LENGUA               	15	3	1988-05-16	2	1	1	68081	2	1	0	2	2323	25	2014-07-02	981	680000	68081	1	52	1.00	1.00	2014-05-10	0
1 	1 	1096199666  	EUGENIO POLO JIMENEZ                    	15	3	1988-12-15	2	1	1	68081	2	1	0	2	32223	40	2013-11-20	982	680000	68081	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096216835  	ANGELA VILORIA OTERO                    	39	3	1992-07-19	1	1	1	68081	2	1	2	2	14523	8 	2013-11-16	983	680000	68081	0	52	1.00	1.00	2014-05-10	0
0 	0 	37658407    	RUBIELA GOMEZ BELTRAN                   	29	3	1972-03-04	1	1	1	68001	2	1	0	5	2156	32	2013-11-19	984	2500000	68001	0	52	0.00	1.00	2014-05-10	0
7 	7 	1098647665  	LUZ DARY HERNANDEZ CHAPARRO             	17	3	1988-01-01	1	1	1	68001	2	1	0	2	5213	8 	2013-11-26	990	680000	68001	0	52	1.00	1.00	2014-05-10	0
12	12	1095812599  	JESUS ALBERTO PARRA LANDAZABAL          	14	3	1992-06-27	2	1	1	68081	1	2	0	2	55854	8 	2013-11-21	985	680000	68001	0	52	1.00	1.00	2014-05-10	0
2 	2 	37949489    	LILIAM ROCIO VARGAS BAREÑO              	17	3	1984-08-22	1	1	1	68001	2	1	0	5	223223	8 	2013-11-21	986	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1095924172  	JENNIFER ANDREA PINTO JEREZ             	16	3	1989-08-31	1	1	1	68001	2	1	0	5	1135	8 	2014-07-04	987	840000	68001	0	52	1.00	1.00	2014-05-10	0
4 	4 	1096201088  	LEIDY JOHANNA CAMARGO CASTRILLON        	17	3	1989-08-21	1	1	1	68001	1	1	0	2	456	8 	2014-01-03	988	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098717087  	DAYANA CAROLINA CHARRY AGUANCHA         	11	3	1992-01-19	1	1	1	68001	2	1	0	2	56556	8 	2014-12-17	989	680000	68001	0	52	1.00	1.00	2014-05-10	0
7 	7 	1098765450  	JUAN SEBASTIAN LEGUIZAMO CRISTANCHO     	15	3	1995-01-25	2	1	1	68001	2	1	0	2	66655	8 	2013-11-26	991	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098685078  	LISSETH DANIELA CUBIDES ARENAS          	17	3	1990-04-07	1	1	1	68001	2	1	0	5	1678841	8 	2013-11-26	992	680000	68001	1	52	1.00	1.00	2014-05-10	0
0 	0 	1095930318  	GLORIA ANGELICA HERNANDEZ GUARIN        	29	1	1992-10-05	1	CARRERA 21B No 22-82	6822891	68001	1	1	0	3	212332	8 	2014-07-03	958	1100000	68001	0	51	1.00	1.00	2014-05-10	0
12	12	63553581    	SANDRA MILENA CRISTANCHO BARRERA        	17	3	1984-08-06	1	CALLE 11No 10A -13 TORRE 16 APTO 201	6408871	68001	2	1	2	2	2312341	8 	2013-12-01	993	680000	68001	1	52	1.00	1.00	2014-05-10	0
12	12	63557673    	MAYERLI JOHANA JIMENEZ                  	17	3	1984-09-14	1	carrer a22 No 10b -19	3174851260	68001	2	1	0	2	2112	5 	2013-12-01	994	680000	68001	0	52	1.00	1.00	2014-05-10	0
4 	4 	1096197032  	YENERITZA ARIAS                         	17	3	1988-06-15	1	CASA 47  COLINAS DEL SEMINARIO	3208454158	68081	1	1	0	2	2525	8 	2013-01-02	740	680000	68081	1	52	1.00	1.00	2013-05-27	0
4 	4 	1096200811  	KARINA FRUTO ANGULO                     	17	3	1989-01-30	1	LOTE 52 MZ 08	3144515381	68081	1	1	0	2	212321	8 	2011-11-01	856	680000	68081	1	52	1.00	1.00	2014-02-01	0
4 	4 	1095804073  	SILVIA CONSUELO COMBITA ARDILA          	17	3	1990-01-23	1	CRA. 15 N° 47-65	6020241	68001	1	4	0	2	252525	8 	2013-02-03	761	680000	68001	1	52	1.00	1.00	2013-08-08	0
9 	9 	63531250    	ANDREA JULIANA GONZALEZ                 	17	3	1992-07-25	1	CALLE 57 No 3W-77 PISO 3	6441794	68001	3	1	0	2	25233	8 	2013-12-01	995	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1098660929  	HEIDY CAMILA BALAGUERA GUERRERO         	17	3	1988-09-18	1	CALLE 57 No 15-135	6491780	68001	2	1	0	2	21223	8 	2013-12-04	996	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098760297  	YERLY KATHERINE LEAL FLOREZ             	17	3	1994-09-11	1	CALLE 104 No 7A -06	6958844	68001	2	1	0	2	2323	8 	2013-12-01	997	680000	68001	1	52	1.00	1.00	2014-05-10	0
3 	3 	91519963    	CHARLY GARCIA ALVARADO                  	15	3	1981-12-06	2	CALLE 19 No 19-56	3152057893	68001	2	1	0	5	12362	8 	2013-12-01	998	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1095804932  	DIEGO DUEÑAS PINZON                     	15	3	1990-05-07	2	CALLE 14 B No 15-50	3134889937	68001	2	1	0	2	1341	8 	2014-01-19	999	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1096183191  	RONALD DELGADO SILVA                    	15	3	1986-05-02	2	CARRERA 18 No 30A -08 MAZ C CASA 7	6991380	68001	2	1	0	5	2323636	8 	2013-12-06	1000	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1098649907  	OSCAR HERNANDO BARAJAS SANCHEZ          	15	3	1987-03-02	2	CARRERA 8 No 10-37	3154048423	68001	1	1	0	2	132	5 	2014-02-02	1001	680000	68001	1	52	1.00	1.00	2014-05-10	0
3 	3 	1098741908  	OSCAR FERNANDO ORTIZ PRADA              	15	3	1993-08-09	2	DIAGO 14 No 56-22 TORR 1 APTO 703	6040617	68001	1	1	0	2	5213	8 	2013-12-10	1002	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098769257  	JOAN SEBASTIAN ORTIZ PRADA              	14	3	1995-05-18	2	diagonal 14 nO 56-22	6040617	68001	2	1	0	4	1121	26	2014-07-02	1003	740000	68001	0	52	1.00	1.00	2014-05-10	0
12	12	1098714136  	ERIKA TATIANA RAMIREZ COBOS             	17	3	1991-11-27	1	calle 103g nO 10-67	6372573	68001	1	1	0	2	1312	8 	2013-12-01	1004	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	1098697761  	GINA LUZ CERVANTES BRIEVA               	17	3	1990-11-25	1	CALLE 148 No 44-04	3177413624	68001	2	1	0	2	132	8 	2013-12-04	1005	680000	68001	1	52	1.00	1.00	2014-05-10	0
1 	1 	1096199456  	JOHANY BELLO PLATA                      	15	3	1988-12-14	2	CALLE 60 No 37-05	6024241	68081	2	1	0	5	52413	8 	2013-12-17	1009	680000	68081	1	52	1.00	1.00	2014-05-10	0
12	12	1098750568  	CRISTIAN GABRIEL ANAYA LEON             	15	3	1994-02-09	2	1	1	68001	2	1	0	5	3223	8 	2013-12-17	1010	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1098650812  	GENNY JOHANA ABRIL TORRES               	17	3	1988-03-19	1	1	1	68001	2	1	0	5	32	40	2013-12-27	1011	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	63530401    	DIANA MILENA DUARTE PEREZ               	17	3	1982-04-25	1	1	1	68001	2	1	0	5	213	8 	2013-12-27	1012	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1098701815  	JOHN FREDDY BLANCO RUIZ                 	15	3	1991-03-14	2	1	1	68001	2	1	0	5	32123	26	2013-12-28	1013	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	1098713151  	YULY ANDREA QUINTERO TORO               	17	3	1991-11-05	1	1	1	68001	2	1	0	5	213	5 	2014-10-04	1014	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	1102362034  	FREDY ALEXANDER PALOMINO MORENO         	15	3	1989-09-17	2	1	4	68001	2	1	0	5	213	8 	2013-12-29	1015	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1098762341  	ANA PATRICIA CANTOR MOSQUERA            	17	3	1994-08-15	1	CALLE 18 No 19-49 SAN FRANCISCO	3114440056	68001	2	1	0	2	24132	8 	2014-01-03	1016	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1094248773  	NELCY ALEXANDRA CARRILLO DUARTE         	17	3	1989-11-05	1	CALLE 20 no 31-51 PISO 2 SAN ALONSO	6451251	68001	1	7	0	2	132123	8 	2014-01-05	1017	680000	68001	0	52	1.00	1.00	2014-05-10	0
9 	9 	63561024    	ZAIRA HERNANDEZ MARTINEZ                	17	3	1985-06-03	1	1	1	68001	2	1	0	5	123112	8 	2014-01-15	1022	680000	68001	1	52	1.00	1.00	2014-05-10	0
12	12	1092645351  	JOSE BERNARDO GELVEZ CONTRERAS          	15	3	2014-02-01	2	CARRERA 11 No 29-13 LA CUMBRE	6581377	68001	2	1	0	5	4312	8 	2014-02-01	1040	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	1098615476  	JULIAN YESID MORENO GONZALEZ            	15	3	1986-05-18	2	CARRERA 6A No 58-80 PISO 5	6798223	68001	2	1	0	2	1322	8 	2014-03-05	1055	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	1095806790  	HAIVER YESID JAIMES SILVA               	15	3	1990-10-28	1	1	1	68001	2	1	0	2	131321	8 	2004-05-10	1041	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	1102363073  	LEYDI ANDREA BARRERA TOLOZA             	17	3	1990-03-16	1	1	1	68001	2	1	0	5	13232	8 	2014-10-18	1042	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096224511  	HAROLD ANDRES ROJAS ALVAREZ             	15	3	1993-10-23	2	TRANSV 45 No 60-54	3123514590	68001	2	1	0	5	14323	26	2014-02-02	1043	680000	68081	1	52	1.00	1.00	2014-05-10	0
1 	1 	1096210682  	MARIA TERESA CAMPO GOMEZ                	17	3	1989-10-01	1	1	1	68001	2	1	0	5	4545	8 	2014-02-08	1044	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098720528  	JONATAN DAVID BALLESTEROS SANCHEZ       	15	3	1991-10-21	1	1	6410345	68001	2	1	0	5	13223	8 	2014-02-12	1045	680000	68001	1	52	1.00	1.00	2014-05-10	0
1 	1 	1096219153  	JOHANA PAOLA AGUIRRE                    	17	3	1992-11-22	1	1	1	68001	2	1	0	2	12323	8 	2014-02-01	1046	680000	68001	1	52	1.00	1.00	2004-05-10	0
7 	7 	1096948786  	FREDY ORLANDO VEGA BARRIOS              	15	3	1988-03-06	2	1	1	68001	2	1	0	5	23123	26	2014-02-05	1047	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	13871033    	JHON FREDY SOTO VELANDIA                	15	3	2014-02-06	2	1	1	68001	2	1	0	5	2232	8 	2014-02-06	1048	680000	68001	0	52	1.00	1.00	2014-05-10	0
8 	8 	1098687608  	GLORIA YAMILE CONTRERAS ESTEBAN         	17	3	1990-05-20	1	1	6421915	68001	2	1	0	2	41333333323	8 	2014-03-02	1056	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096215964  	YULIS MARCELA GIL MARTINEZ              	17	3	1992-04-30	1	FD,FMDG,	31275115511	68001	2	1	0	2	121214	8 	2014-03-06	1057	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096224365  	WENDY YULIZA ZABALA VASQUEZ             	17	3	1993-09-30	1	MANZABNA 49 LOTE 2	3138647983	68001	2	1	0	4	14653522	8 	2014-03-04	1058	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	1095816074  	DIANA LIZETH AYALA ARCE                 	16	3	1993-06-25	1	CALLE 5A N° 14-88	3168906290	68001	1	6	0	2	2525	8 	2012-10-12	782	770000	68001	0	52	1.00	1.00	2013-10-11	0
8 	8 	1102353333  	FABIAN MARTINEZ JURADO                  	15	3	1987-07-23	2	1	1	68001	2	1	0	5	1323	8 	2014-01-14	1018	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	1095935948  	KAREN JULIETH SUAREZ RUEDA              	17	3	1994-03-15	1	1	1	68001	2	1	0	5	21132	8 	2014-01-14	1019	680000	68001	1	52	1.00	1.00	2014-05-10	0
12	12	63507899    	MARIA YANETH MURILLO GALEON             	40	3	1975-11-20	1	1	1	68001	2	1	0	2	513	8 	2014-01-14	1020	680000	68001	0	52	1.00	1.00	2014-05-10	0
12	12	63545374    	LUZ KARIME CANCINO GAMBOA               	17	3	1983-10-06	1	1	1	68001	2	1	0	5	131	8 	2014-01-14	1021	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	1098357518  	JESUS APARICIO MUÑOZ                    	15	3	1991-04-01	2	CALLE 110 nO 34A-05	6366065	68001	2	1	0	5	1322	8 	2013-06-25	910	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1005386431  	DIANA MARCELA HERRERA GAMBOA            	17	3	1995-07-14	1	1	6770215	68001	2	1	0	5	13213	8 	2014-07-04	1060	680000	68001	0	52	1.00	1.00	2014-05-10	0
0 	0 	37398527    	LEYDIS ANDREA LEAL JOVES                	29	3	1985-02-22	1	1	3204742853	68001	2	1	0	2	21256	8 	2014-03-17	1061	770000	68001	0	51	1.00	1.00	2014-05-10	0
1 	1 	1096213794  	SINDY VANESSA MARQUEZ MARTINEZ          	17	3	2014-03-19	1	1	3106697819	68001	1	1	0	2	132121	8 	2014-03-20	1062	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1098756892  	LEIDY TATIANA TRUJILLO ZARATE           	17	3	1994-06-10	1	1	6946562	68001	1	1	0	5	21232	8 	2014-10-22	1063	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	1102361083  	MARISOL MENDOZA MENESES                 	17	3	1988-05-09	1	1	3182772355	68001	2	1	0	1	524132	8 	2014-03-23	1064	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	63539553    	MARIA DEL PILAR ESTEBAN MONSALVE        	17	3	1983-04-15	1	1	1	68081	2	1	0	2	123121	8 	2014-10-17	1065	680000	68081	0	52	1.00	1.00	2014-05-10	0
12	12	1095932919  	JHON JAIRO DIAZ CALDERON                	107	3	2014-03-27	2	1	1	68001	2	1	0	2	423121	26	2014-03-27	1066	680000	68001	0	52	1.00	1.00	2014-05-10	0
10	10	1098623448  	ELKIN HORACIO CELIS JAIMES              	15	3	1986-09-15	2	1	1	68001	2	1	0	2	4123	8 	2014-03-27	1067	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1095815822  	JHONATAN DELGADO QUINTERO               	15	3	1993-05-01	1	CALLE 6 No 4-87 SANTA ANA	6394336	68001	2	1	0	2	532132	8 	2014-04-03	1069	680000	68001	0	52	1.00	1.00	2014-05-10	0
3 	3 	1095931344  	DAVIDSON DIAZ CORZO                     	15	3	1993-01-19	2	1	6531551	68001	2	1	0	5	2312321	26	2014-03-11	1059	680000	68001	1	52	1.00	1.00	2014-05-10	0
1 	1 	74371951    	JOSE FERNANDO SANCHEZ HUESA             	12	3	1977-04-12	2	CARRERA 2A No 55A-14	3168266275	68001	1	5	0	2	1321213	8 	2014-04-09	1070	2300000	68001	1	52	0.00	1.00	2014-05-10	0
2 	2 	91495908    	CESAR AUGUSTO SILVA MONSALVE            	14	3	1976-12-13	2	CRA. 6C N° 1NE -53 CASA 435 MZ W	6550881	68001	1	5	2	3	25250	8 	2012-07-11	749	800000	68001	1	52	1.00	1.00	2013-07-10	0
9 	9 	1095922040  	DIEGO ALEXANDER PIMIENTO ORREGO         	15	3	1990-06-18	2	DIAGONAL 8B No 20A-19	6591297	68001	2	1	0	2	1221321	8 	2014-07-02	1075	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	1098752326  	MARLON HUMBERTI NAVARRO SACHICA         	15	3	1994-03-12	2	CALLE 1C No 7-08 VILLA NUEVA DEL CAMPO	6563160	68001	2	1	0	2	21214413	8 	2014-04-17	1076	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	1098754886  	ORLANDO JOSE MARTINEZ AVILA             	15	3	1993-12-09	2	MANZANA K CASA 10	3138731203	68001	1	1	0	2	131	8 	2014-04-17	1077	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	91467406    	HECTOR FABIO CAMACHO                    	34	3	1989-10-03	2	CARRERA 8W No 61-18	3164754747	68001	2	1	0	5	13212	8 	2014-04-04	1071	1700000	68001	0	52	0.00	1.00	2014-05-10	0
7 	7 	1096219699  	CLAUDIA PATRICIA HERRERA MARTINEZ       	39	3	1992-12-06	1	CARRERA 23 No 5N-08	6736025	68001	2	1	0	1	215565	8 	2014-04-17	1078	680000	68001	0	52	1.00	1.00	2014-05-10	0
10	10	37549654    	PATRICIA SARMIENTO SILVA                	17	3	1978-01-22	1	CALLE 107 No 50-13	6770977	68001	2	1	0	2	13	8 	2014-10-04	1079	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1098729088  	PAULA ANDREA ACUÑA BELLO                	17	3	1992-10-14	1	CARRERA 18 No 10-50	3156504385	68001	2	1	0	2	45421214	8 	2014-04-24	1080	680000	68001	0	52	1.00	1.00	2014-05-10	0
7 	7 	1098733322  	JORGE IVAN OTERO HERNANDEZ              	15	3	1993-01-01	2	CALLE 16 NO 25-75	3172689030	68001	2	1	0	2	13230	8 	2014-04-17	1081	680000	68001	0	52	1.00	1.00	2014-05-10	0
0 	0 	1098655932  	MARLY JASMIN CORZO RODRIGUEZ            	29	3	1988-03-28	1	MDCDG	6908163	68001	1	1	0	5	432223	8 	2014-07-03	1082	2500000	68001	0	52	0.00	1.00	2004-05-10	0
1 	1 	1096199916  	EDWIN ALEXANDER CUEVAS GUERRERO         	15	3	1989-02-23	2	fdfdfyhytf	2112	68001	2	1	0	5	132123	8 	2014-05-05	1085	680000	68001	0	52	1.00	1.00	2004-05-10	0
1 	1 	1050552676  	YULIS ESTHER ULLOA MACHADO              	17	3	1994-10-10	1	dcffcg	132	68001	1	1	0	2	12136	5 	2014-10-04	1086	680000	68001	1	52	1.00	1.00	2004-05-10	0
1 	1 	1096195910  	GLORIA STELLA HERRERA GONZALEZ          	17	3	1988-08-05	1	,clsdfnsd	6224514	68001	2	1	0	2	21	23	2014-05-07	1087	680000	68001	1	52	1.00	1.00	2004-05-10	0
1 	1 	1096206189  	NELLY JHIVED JARAMILLO LEAL             	17	3	1990-06-22	1	gfghjkhlk	6800	68001	1	1	0	2	541263	8 	2014-05-09	1088	680000	68001	1	52	1.00	1.00	2004-05-10	0
8 	8 	1102368490  	MAGALY CARRILLO RICO                    	17	3	1992-03-14	1	dfyui	68001	68001	1	1	0	2	13122	8 	2014-05-09	1089	680000	68001	1	52	1.00	1.00	2004-05-10	0
0 	0 	91527677    	GEOVANNY GOMEZ OLIVEROS                 	29	1	1984-01-16	2	1	1	68001	2	1	0	5	212323	8 	2014-02-24	1049	1100000	68001	1	51	1.00	1.00	2014-05-10	0
0 	0 	1098651321  	WILMER JOSE CARRILLO PEDRAZA            	29	3	1988-04-19	2	1	1	68001	2	1	0	5	212132	8 	2014-02-20	1050	1300000	68001	0	51	0.00	1.00	2004-05-10	0
7 	7 	1095907871  	MONICA VESGA RUEDA                      	17	3	1986-05-04	1	1	1	68001	1	1	0	2	13212	8 	2014-02-25	1051	680000	68001	1	52	1.00	1.00	2014-05-10	0
0 	0 	63359190    	SANDRA ROCIO CARDOZO GUERRERO           	29	3	1970-07-03	1	1	1	68001	2	1	0	4	1312	2 	2014-02-21	1052	2500000	68001	1	52	0.00	1.00	2014-05-10	0
1 	1 	52979066    	MILEIVY MORENO RODRIGUEZ                	17	3	1984-04-15	1	1	1	68081	1	1	0	2	13123	8 	2014-02-16	1053	680000	68081	1	52	1.00	1.00	2014-05-10	0
0 	0 	72194525    	EDUARDO GARCIA ARANDA VERGARA           	29	3	1973-07-13	2	1	1	68001	2	1	0	5	1132	8 	2013-06-13	1054	15400000	68001	0	51	0.00	1.00	2014-05-10	0
4 	4 	1067913709  	KEYDY LINET BELLO ZABALA                	17	3	1992-06-29	1	M I 174	6108185	68081	1	5	0	2	252525	8 	2012-10-26	786	680000	23001	1	52	1.00	1.00	2013-10-25	0
7 	7 	1095825015  	LUIS FERNANDO PARRA SUAREZ              	107	3	1995-07-21	2	1	1	68001	2	1	0	5	22136	8 	2013-12-13	1006	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098717809  	JOHN JAIRO MOTTA DELGADO                	15	3	1992-02-12	2	1	1	68001	2	1	0	5	1232	8 	2013-12-13	1007	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1098697621  	NELCY MORENO ESTEBAN                    	17	3	1990-12-26	1	1	1	68001	2	1	0	5	21321	8 	2013-12-12	1008	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096218827  	JAIR ALFONSO QUINTERO ROMERO            	15	3	1990-05-27	2	CARRERA 52 No 28-09 EL CASTILLO	3204037764	68081	2	1	0	2	21321	8 	2013-04-07	877	680000	68081	1	52	1.00	1.00	2014-03-01	0
10	10	1102370923  	JERSON GOMEZ DUARTE                     	15	3	1993-04-22	2	MANZANA C CASA 9 CERROS DEL MEDITERRANEO	6552427	68001	1	1	0	2	21312	8 	2013-04-05	878	680000	68001	1	52	1.00	1.00	2014-03-01	0
12	12	1098692271  	LIZETH CRISTINA GONZALEZ VELAZCO        	17	3	1990-08-19	1	MCDFNFGMR	6370099	68001	2	1	0	2	1321321	8 	2014-05-14	1090	680000	68001	0	52	1.00	1.00	2004-05-10	0
3 	3 	1098650454  	KARINA SILVA MADARIAGA                  	17	3	1987-11-14	1	MXASK	6320505	68001	2	1	0	2	31213	5 	2014-05-14	1091	680000	68001	0	52	1.00	1.00	2014-05-10	0
3 	3 	1098286594  	ALEXANDER RODRIGUEZ CAÑAS               	15	3	1995-01-03	2	CEFDSGDÑLKS	6320505	68001	2	1	0	2	62121	8 	2014-05-01	1092	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	5552477     	ADOLFO DUARTE GUERRERO                  	23	1	1941-04-24	2	KNBK,	6370099	68001	2	1	0	5	21313	8 	2014-05-20	1093	680000	68001	0	51	1.00	1.00	2004-05-10	0
0 	0 	1098736229  	YULY XIOMARA MORENO FLOREZ              	29	1	1993-03-17	1	,M .,,-UUUIUU	6370099	68001	2	1	0	2	21321	8 	2014-05-19	1094	700000	68001	1	51	1.00	1.00	2004-05-10	0
7 	7 	1095916972  	SANDRA MARCELA DURAN RUA                	17	3	1988-10-20	1	CARRERA 9 No 109-07	3188361062	68001	2	1	0	2	32355	10	2014-06-01	1099	680000	68001	0	52	1.00	1.00	2004-05-10	0
8 	8 	1098750197  	SANDRA MILENA IBAÑEZ MARTINEZ           	17	3	1992-09-17	1	RTLGY	68001	68001	2	1	0	2	13121	8 	2014-06-01	1100	680000	68001	1	52	1.00	1.00	2004-05-10	0
2 	2 	1066173237  	MARTHA LILIANA SARMIENTO ALVAREZ        	17	3	1986-08-18	1	 C  V,.XMBVX	68001	68001	2	1	0	2	13121	8 	2014-06-06	1101	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	37617153    	OMAIRA RAMIREZ PRADA                    	17	3	1982-01-16	1	V.V,XC	68001	68001	2	1	0	2	1212	8 	2014-06-07	1102	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	1098684888  	LIBER FRANK URIBE VARGAS                	15	3	1990-02-10	1	DVDVMDS	3155223519	68001	2	1	0	4	1312	8 	2014-06-01	1103	680000	68001	0	52	1.00	1.00	2004-05-10	0
1 	1 	1116778777  	ALIX MIREYA ACOSTA RODRIGUEZ            	17	3	1987-06-04	1	MNNKN	6224515	68081	2	1	0	5	21323	8 	2014-07-04	1104	680000	68081	0	52	1.00	1.00	2004-05-10	0
9 	9 	1000185113  	JONATHAN DAVID MONTERO CUDRIS           	15	3	1994-12-18	2	MNDKJ	622355	68001	2	1	0	2	1312	8 	2014-06-06	1105	680000	68001	1	52	1.00	1.00	2004-05-10	0
4 	4 	1100392903  	LEIDY MARGARITA SALAS QUIROZ            	17	3	1986-08-31	1	DFSMF,SD	6203547	68001	1	1	0	1	11323	8 	2014-06-01	1106	680000	68081	0	52	1.00	1.00	2004-05-10	0
7 	7 	1065578120  	ALVARO IVAN CAMARGO CARRILLO            	44	3	1987-01-01	2	BL.Ñ{Ñ]}	6370099	68001	1	1	0	5	2132	23	2014-06-16	1107	800000	68001	1	52	1.00	1.00	2004-05-10	0
10	10	1102371686  	MARLEY VERA TOBON                       	17	3	1993-07-16	1	SF,VDSF,	6370099	68001	2	1	0	2	213223	23	2014-07-06	1109	680000	68001	1	52	1.00	1.00	2014-05-10	0
4 	4 	1096221650  	JOSE VICENTE VASQUEZ FIALLO             	15	3	1993-05-29	1	 MML,Ñ	6370099	68001	1	1	0	2	132	23	2014-06-26	1110	680000	68001	0	52	1.00	1.00	2004-05-10	0
0 	0 	66839628    	PATRICIA FERNANDEZ CRUZ                 	29	1	1972-07-23	1	CRA 37 112-52 ZAPAMANGA 2 ETAPA	6312587	68001	3	5	2	2	2122112	23	2014-07-04	1111	680000	68001	0	51	1.00	1.00	2014-05-10	0
10	10	1102378050  	YURLEIDY CECILIA BECERRA NOVA           	17	3	1995-07-20	1	CLL 24A 1-37 LOS CISNES	6541606	68001	1	5	0	2	236578	23	2014-07-04	1112	680000	68001	0	52	1.00	1.00	2014-05-10	0
4 	4 	1102718807  	ALVARO JAVIER GUALDRON DIAZ             	15	3	1990-01-11	1	CRA 15B 55D-37 PUEBLO NUEVO	3212484203	68001	1	5	0	2	236578	23	2014-07-08	1113	680000	68001	1	52	1.00	1.00	2014-05-10	0
0 	0 	63307246    	GLORIA STELLA VARGAS                    	29	3	1963-09-21	1	XCMKMSFG	6370099	68001	1	1	0	5	2213	8 	2014-05-05	1083	680000	68001	1	51	1.00	1.00	2004-05-10	0
8 	8 	1102371425  	DAVID LEONARDO PEDRAZA BARRAGAN         	15	3	1993-07-02	2	MKFKSDMFÑS	556456	68001	2	1	0	1	13232	8 	2014-05-09	1084	680000	68001	1	52	1.00	1.00	2004-05-10	0
0 	0 	1098691794  	YUDY MARCELA DIAZ DOMINGUEZ             	29	1	1990-08-12	1	CRA 22 A 109 40	6515794	68001	1	1	0	3	252525	8 	2013-01-11	830	1100000	68001	0	51	1.00	1.00	2014-01-10	0
12	12	91186267    	GUSTAVO ADOLFO GUTIERREZ OVIEDO         	15	3	1985-01-05	2	1	6468818	68001	2	1	0	2	1321	40	2014-03-28	1068	680000	68001	0	52	1.00	1.00	2014-05-10	0
7 	7 	1098728351  	CINDY PAOLA VILLAMIZAR MEJIA            	17	3	1992-10-03	1	MCLK,CZ	314363226	68001	1	1	0	2	15151	8 	2014-05-23	1095	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1098766947  	YURLEIS LILIANA PARDO AVELLANEDA        	17	3	1995-03-19	1	XKNASCSAMC	6381801	68001	2	1	0	5	2312	40	2014-05-23	1096	680000	68001	0	52	1.00	1.00	2004-05-10	0
12	12	1098782507  	JENNY YUBELI CARRILLO PORTILLA          	39	3	1996-01-23	1	c,safsdgmdf	6370099	68001	2	1	0	2	3212313	8 	2015-01-02	1097	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	13724459    	OMAR RODRIGO BECERRA DUEÑAS             	10	3	1979-08-29	2	1	1	68001	2	1	0	5	13213	8 	2014-04-13	1074	740000	68001	0	52	1.00	1.00	2016-05-10	0
10	10	1102360030  	JENNY VALERO DURTE                      	17	3	1989-05-19	1	CALLE 4A No 6-32 CENTRO	3175476176	68001	1	1	0	2	13223	8 	2013-09-24	941	680000	68001	1	52	1.00	1.00	2014-05-10	0
10	10	1095805863  	DANIEL EDUARDO CALA SOLER               	15	3	1990-07-03	1	CALLE 1D BIS MANZ H CASA 38	6550853	68001	1	1	0	2	43123	51	2013-09-18	942	680000	68001	1	52	1.00	1.00	2014-05-10	0
0 	0 	63531798    	CAROLINA GOMEZ CAMACHO                  	29	3	1982-08-12	1	CARRERA 3A No 16-29 SANTA ANA	6797908	68001	2	1	0	5	132	25	2013-09-16	943	1000000	68001	1	51	1.00	1.00	2014-05-10	0
1 	1 	1096207802  	BRILLY MARLESBY BAUTISTA TORRES         	17	3	1990-09-18	1	CALLE 47 LOTE 29 DORADO	3003736816	68001	2	1	0	2	4132	8 	2013-09-19	944	680000	68001	1	52	1.00	1.00	2014-05-10	0
1 	1 	1096221967  	BRAYAN MANUEL SILVA SIMANCA             	10	3	1993-05-16	1	CARRERA 21 NO 38-20	3203239043	68081	1	1	0	2	131226	8 	2015-02-19	945	740000	68081	0	52	1.00	1.00	2014-05-10	0
1 	1 	1096206271  	NAFFY YESENIA BASTOS SUAREZ             	17	3	1990-04-19	1	CALLE 47 LOTE 48	6220811	68081	3	1	0	2	1323	8 	2013-09-19	946	680000	68081	1	52	1.00	1.00	2014-05-10	0
10	10	1098630315  	YULIETH MONTOYA RODRIGUEZ               	20	3	1987-01-22	1	CARRERA 13W No 60BIS 71 APTO 201	6417886	68001	1	1	0	4	213213	8 	2013-09-23	947	1700000	68001	0	52	0.00	1.00	2014-05-10	0
1 	1 	1096231067  	JENNY PAOLA HERNANDEZ HURTADO           	17	3	1994-12-26	1	CASA 15 BOSQUES DE LA CIRA	6021386	68081	3	1	0	2	2132	8 	2013-09-19	948	680000	68081	1	52	1.00	1.00	2014-05-10	0
10	10	91352253    	YEISON ARMANDO VIOLA GAVIRIA            	15	3	1980-07-23	2	1	6314	68001	1	1	0	2	32323	8 	2014-07-03	1072	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	1098757527  	JUAN CAMILO TARAZONA MONTESINO          	10	3	1994-06-18	1	1	1	68001	2	1	0	2	354254	8 	2014-04-01	1073	740000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1102371769  	EDUARD DAVID DIAZ BENAVIDES             	15	3	1993-08-13	2	1	1	68001	2	1	0	5	1362	8 	2013-09-26	949	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1098702438  	ESTEFANY JIVETH GUARNIZO ORTIZ          	17	3	1991-04-02	1	1	1	68001	2	1	0	2	132	8 	2014-07-12	1114	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1096956132  	LINA KATHERINE PADILLA NIÑO             	17	3	1995-06-23	1	1	1	68001	2	1	0	2	1230	23	2014-07-12	1115	680000	68001	1	52	1.00	1.00	2004-05-10	0
12	12	1095921497  	LUIS ELIAS HERNANDEZ FLOREZ             	15	3	1990-04-06	1	1	1	68001	2	1	0	5	23	23	2014-07-02	1116	680000	68001	0	52	1.00	1.00	2004-05-10	0
0 	0 	1102362089  	SANDRA PAOLA JAIMES JAIMES              	29	1	1989-10-29	1	1	1	68001	2	1	0	3	1312	8 	2014-07-07	1117	1100000	68001	0	51	1.00	1.00	2004-05-10	0
7 	7 	1098637627  	OSCAR MAURICIO PENAGOS BOLIVAR          	10	3	1987-06-13	1	1	1	68001	1	1	0	2	1322	23	2014-07-10	1118	700000	68001	1	52	1.00	1.00	2004-05-10	0
9 	9 	1098652345  	ZULEYMA ORTEGA BLANCO                   	17	3	1987-04-02	1	1	1	68001	2	1	0	5	213	23	2014-07-08	1119	680000	68001	1	52	1.00	1.00	2004-05-10	0
8 	8 	1098742610  	CLARISA ALEJANDRA GAMBOA CAICEDO        	17	3	1991-12-01	1	1	1	68001	2	1	0	2	213	23	2014-07-06	1120	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	1095801991  	MARGARET ROXANA TORRES TRUJILLO         	17	3	1988-02-17	2	CALLE 54 No 13-02 EL REPOSO	6492190	68001	2	1	0	5	13121	23	2014-07-29	1123	680000	68001	0	52	1.00	1.00	2004-05-10	0
0 	0 	1095923792  	JERLY MILENA GOMEZ HUERFANO             	29	1	1990-11-12	1	1	1	68001	2	1	0	5	2132	23	2014-07-28	1124	1100000	68001	0	51	1.00	1.00	2004-05-10	0
7 	7 	1098759570  	EIMAR FERNANDO CEPEDA HERNANDEZ         	15	3	1994-09-05	1	1	1	68001	1	1	0	2	33	23	2014-07-18	1125	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098756435  	DEYBI ALEXANDER MEDINA REATIGUI         	37	3	1994-06-14	1	CALLE 61 AN No 2W-13 APTO 401	1	68001	2	1	0	5	13	23	2014-07-26	1126	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	37617103    	DEISY MIREYA OVALLE BLANCO              	17	3	1982-01-31	1	1	1	68001	2	1	2	5	12123221	23	2014-07-26	1127	680000	68001	0	52	1.00	1.00	2004-05-10	0
0 	0 	96122703743 	JORGE DAVID DELGADO CRUZ                	29	3	1996-12-27	1	1	1	68001	2	1	0	5	21352	8 	2014-07-18	1128	1800000	68001	0	51	0.00	1.00	2004-05-10	0
7 	7 	1098735403  	GELVER ALONSO ARENIS QUIROGA            	15	3	1993-03-20	2	1	23121	68001	1	1	0	2	123132	8 	2014-07-19	1129	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	1102548938  	KATHERINE LISSETH APARICIO CARREÑO      	17	3	1990-06-22	1	1	1	68001	2	1	0	1	2123	23	2014-07-22	1130	680000	68001	1	52	1.00	1.00	2004-05-10	0
9 	9 	1095822576  	LUISANGELA CARDENAS HERNANDEZ           	17	3	1994-12-24	1	1	1	68001	2	1	0	2	21321	23	2014-07-22	1134	680000	68001	1	52	1.00	1.00	2004-05-10	0
4 	4 	1098633280  	SONIA LUCIA MURILLO RUEDA               	17	3	1987-01-29	1	1	1	68001	2	1	0	2	1231	23	2014-07-28	1135	680000	68001	0	52	1.00	1.00	2004-05-10	0
12	12	1098677855  	LADIS TATIANA MENESES                   	17	3	1989-10-16	1	1	1	68001	2	1	2	2	321212	23	2014-07-23	1136	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1102362494  	LUDWING YESID BARRERA RAMIREZ           	43	3	1990-01-04	2	1	1	68001	2	1	0	2	121322	23	2014-07-13	1121	680000	68001	0	52	1.00	1.00	2014-05-10	0
9 	9 	1090368177  	FREDDY ALONSO DELGADO OMAÑA             	15	3	1986-05-03	1	1	1	68001	2	1	0	5	2132	8 	2014-07-13	1122	680000	68001	1	52	1.00	1.00	2004-05-10	0
12	12	1095793808  	FABIAN LANDINEZ GARCIA                  	15	3	1987-05-22	1	1	1	68001	1	1	0	2	123	23	2014-07-29	1137	680000	68001	1	52	1.00	1.00	2004-05-10	0
2 	2 	1100893742  	LISETH KATHERINE ROJAS GONZALEZ         	39	3	1993-02-05	1	1	1	68001	2	1	0	2	31	23	2014-07-29	1138	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	1096952857  	MAYRA ALEJANDRA FERNANDEZ LOPEZ         	17	3	1991-12-07	1	BLOQUE 9 TORRE 12-1 APTO 401	3212183429	68276	1	2	0	3	1234	23	2014-08-07	1139	680000	68001	1	52	1.00	1.00	2004-05-10	0
7 	7 	1098741898  	LEIDY JOHANNA RAMIREZ QUINTERO          	17	3	1993-05-25	1	CALLE 27N No 9A-39	6732989	68001	1	5	0	2	123456	23	2014-08-07	1140	680000	68001	0	52	1.00	1.00	2004-05-10	0
12	12	1095926994  	LAURA MARCELA MARIÑO AVILA              	17	3	1991-09-01	1	DIAGONAL 8B No 21-30	6594944	68307	3	1	1	2	456789	23	2014-08-04	1141	680000	68307	0	52	1.00	1.00	2004-05-10	0
0 	0 	1098693309  	MARIA MERCEDES ACEVEDO ARIZA            	29	1	1990-09-23	1	CRA 39 No 46-132	6575047	68001	1	2	0	4	57896	23	2014-08-01	1142	1800000	68001	0	51	0.00	1.00	2004-05-10	0
4 	4 	1096202991  	ESPERANZA ZUÑIGA SILVA                  	17	3	1990-01-09	1	CARRERA 59 No 25-57	3173898774	68081	1	5	0	2	45678	23	2014-08-14	1143	680000	68081	1	52	1.00	1.00	2004-05-10	0
8 	8 	39581604    	ANGELICA PATRICIA SANCHEZ SANJUAN       	17	3	1982-12-16	1	CALLE 103 No 51-45 ARRAYANES 1A ETAPA	6819587	68276	2	5	0	2	12458	23	2014-08-15	1144	680000	20228	1	52	1.00	1.00	2004-05-10	0
4 	4 	1098699030  	YENNY CATALINA SALAZAR SOLANO           	17	3	1990-12-23	1	CARRERA 36F No 49-59 MIRAFLORES	3123258999	68081	3	5	0	2	789456	23	2014-08-16	1145	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1098655276  	DIANA PAOLA LIZCANO PORTILLA            	17	3	1988-07-13	1	CALLE 1E No 4B-3 CAMPO VERDE	6652554	68547	2	5	2	2	78946	23	2014-09-07	1147	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	37707967    	SANDRA MILENA MARTINEZ SANTOS           	17	3	1983-02-05	1	CALLE 22 No 22-64 ALARCON	6918448	68001	1	5	2	2	328965	23	2014-09-06	1148	680000	68167	1	52	1.00	1.00	2004-05-10	0
10	10	1102376597  	ANDERSON LEONARDO PRADA BARRERA         	15	3	1995-03-18	2	CARRERA 4 No 7N-34 DIVINO NIÑO	6891810	68547	1	5	0	2	45389	23	2014-09-02	1149	680000	68682	1	52	1.00	1.00	2004-05-10	0
9 	9 	63558542    	DIANA CAROLINA BENITEZ MORA             	17	3	1984-11-08	1	CALLE 28A No 29-28	3188681087	68307	2	1	2	2	456892	23	2014-09-11	1150	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	24716630    	DIANA YISET TRIANA CASTRO               	17	3	1982-09-14	1	CALLE 16 No 23-23	3212936826	68001	2	6	0	2	357896	23	2014-09-11	1151	680000	17380	1	52	1.00	1.00	2004-05-10	0
10	10	91354492    	OSCAR FERNANDO JAIMES BADILLO           	15	3	1983-01-02	2	OSCAR FERNANDO JAIMES BADILLO	3183480313	68547	1	2	0	2	345697	23	2014-09-12	1154	680000	68755	0	52	1.00	1.00	2004-05-10	0
1 	1 	37580319    	SANDRA LILIANA ACUÑA QUIÑONEZ           	17	3	1984-09-11	1	TRANSVERSAL 42A No 56A-10	3214867004	68081	1	5	0	2	345698	23	2014-09-12	1155	680000	68081	0	52	1.00	1.00	2004-05-10	0
3 	3 	91515672    	LEONARDO FABIO SARMIENTO BLANCO         	20	3	1983-01-19	1	CALLE 31 No 11W-53 SANTANDER	6523785	68001	2	1	0	1	5323	8 	2014-09-23	1156	1300000	68001	1	51	0.00	1.00	2004-05-10	0
4 	4 	1096231350  	LINEY PARADA MEJIA                      	17	3	1994-12-23	1	LINEY PRADA MEJIA	6022250	68001	2	1	0	2	13123	8 	2014-09-24	1157	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1095935152  	GINNA ALEXANDRA RENGIFO RUEDA           	17	3	1994-01-20	1	1	3115150160	68001	2	1	0	5	11321	8 	2014-01-27	1023	680000	68001	1	52	1.00	1.00	2014-05-10	0
7 	7 	1098742616  	GUILLERMO RINCON FORERO                 	15	3	1993-04-22	1	1	6575347	68001	2	1	0	5	12312	8 	2014-01-21	1024	680000	68001	1	52	1.00	1.00	2014-05-10	0
12	12	63534274    	DIANA CAROLINA BLANCO MANCILLA          	17	3	2014-01-22	1	1	6461642	68001	2	1	0	5	212312	31	2014-07-03	1025	680000	68001	1	52	1.00	1.00	2014-05-10	0
2 	2 	1005451599  	TATIANA LOZANO GUALDRON                 	17	3	1994-12-02	1	1	64167676	68001	2	1	0	5	1231321	8 	2014-01-25	1026	680000	68001	0	52	1.00	1.00	2014-05-10	0
4 	4 	1098758756  	KAREN VIVIANA BETTIN SERRANO            	17	3	1994-08-16	1	CARRERA 35D No 74-69	3165356418	68081	1	1	0	2	1312	8 	2014-09-24	1158	680000	68081	1	52	1.00	1.00	2004-05-10	0
1 	1 	1096215637  	JEIMMY CAICEDO ACEVEDO                  	17	3	1991-12-07	1	CALLE 19 No 77-16 CAMPO HERMOSO	3108021986	68001	1	4	0	2	23323	8 	2014-09-26	1159	680000	68001	1	52	1.00	1.00	2004-05-10	0
9 	9 	63548494    	DEASSY YISEDTH TARAZONA SUAREZ          	42	3	1984-04-13	1	CRA 25 # 4 - 17 INDEPENDENCIA	3168452978	68001	2	5	0	2	234508	23	2014-10-01	1160	680000	68001	1	72	1.00	1.00	2004-05-10	0
9 	9 	1010080104  	CRISTIAN DAVID ROLON RODRIGUEZ          	15	3	1990-11-11	2	TORRE 3 INT 1 APTO 501 METROPOLIS	3106658343	68001	1	1	0	2	281520	23	2014-10-04	1161	680000	68001	0	52	1.00	1.00	2004-05-10	0
0 	0 	1096228316  	SILVIA MARIA GOMEZ BECERRA              	29	1	1994-05-19	1	CLL 26 # 51 - 15	3008168358	68081	1	5	0	3	285023	23	2014-10-07	1162	900000	68081	0	51	1.00	1.00	2004-05-10	0
3 	3 	28359769    	MILENA JANETH VILLABONA RIOS            	17	3	1982-06-02	1	CLL 21 # 21 - 75 APTO 201 SAN FRANCISCO	3153474758	68001	1	1	0	2	152018	23	2014-10-01	1163	680000	5647 	0	52	1.00	1.00	2004-05-10	0
0 	0 	37557488    	ADRIANA MILENA DURAN DURAN              	29	1	1978-04-27	1	CLL 55 # 1 - 94 TORRE 1 APTO 301	6414666	68001	2	1	0	4	1245017	23	2014-09-29	1164	1000000	68276	0	51	1.00	1.00	2004-05-10	0
2 	2 	1095822022  	* LEIDY KATERIN DAZA ARENAS             	17	3	1994-12-01	1	CRA 6 # 9 - 31 PRIMAVERA I	6485157	68001	2	5	0	2	1502581	23	2014-10-16	1166	680000	68276	0	52	1.00	1.00	2004-05-10	0
7 	7 	1098735441  	MARTIN ARLEY DOMINGUEZ VARGAS           	15	3	1993-02-14	2	CRA 6 # 28 - 48 TORRE 4 APTO 702 GIRARDO	3004294012	68001	1	1	0	2	15028411	23	2014-10-17	1167	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1005336114  	DIANA MARCELA LIZCANO CASTELLANOS       	17	3	1995-03-27	1	CRA 2 MZ D CASA 3	3153896945	68001	1	5	0	2	210514561	23	2014-10-16	1168	680000	68001	0	52	1.00	1.00	2004-05-10	0
3 	3 	1098707364  	MARLON FABRICIO PALMA SERRANO           	15	3	1991-06-20	2	CRA 40 # 10 - 08 BARRIO EL DIVISO	3173202451	68001	1	5	0	2	254813681	23	2014-10-16	1169	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1095936908  	JHONNATAN JAVIER AHUMADA CARDENAS       	15	3	1994-06-19	2	CRA 19A No 19A-08 CASTILLA REAL 1	3155384520	68307	1	5	0	2	789435	23	2014-08-27	1146	680000	68307	0	52	1.00	1.00	2004-05-10	0
1 	1 	1096207526  	YISBED DUARTE DURAN                     	17	3	1990-07-07	1	CALLE 48 No 9-19 CARDALES	3146131005	68081	1	1	0	2	6532	8 	2013-07-04	874	680000	68081	1	52	1.00	1.00	2014-03-01	0
9 	9 	1098770276  	JOHAN SEBASTIAN RUEDA GALVIS            	15	3	1995-05-16	2	CLL 64 3 4W - 39 BARRIO LOS HEROES	3173141573	68001	1	5	0	2	1546181681	23	2014-10-16	1170	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	1098762972  	* GEIMY CATERINE PAREDES FLOREZ         	17	3	1994-11-29	1	CRA 7 # 6 - 44 BARRIO SANTANA	3186970830	68276	1	5	0	2	851916181	23	2014-10-16	1171	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	37841383    	* RUTH ALEXANDRA DIAZ ESPINOSA          	17	3	1980-10-30	1	CRA 29 # 22 - 15 BARRIO GALLINERAL	3158672942	68307	1	5	0	2	1281392	23	2014-10-16	1172	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1102355922  	YEISON ANDRES VELASQUEZ                 	15	3	1988-05-04	2	CRA 19 # 7 - 44 BARRIO LA COLINA	6558360	68547	4	5	0	2	2561814	23	2014-10-16	1173	680000	68001	0	52	1.00	1.00	2004-05-10	0
1 	1 	1007439278  	YUNEIDIS ALZATE DUARTE                  	17	3	1995-07-22	1	CRA 45B # 59A - 55 APTO 201 BARRIO 9 ABR	3187863957	68081	1	5	0	2	129429716	23	2014-10-18	1174	680000	13670	0	52	1.00	1.00	2004-05-10	0
1 	1 	1096198771  	MARIA ALEJANDRA PLATA MACIAS            	17	3	1988-01-19	1	CALL 40 # 48 - 20 MINAS DEL PARAISO	3162714104	68081	1	1	0	2	11982932941	23	2014-10-25	1175	680000	68081	0	52	1.00	1.00	2004-05-10	0
2 	2 	1098610150  	OMAR JAVIER SARMIENTO RINCON            	12	3	1985-09-10	2	CALLE 106 34-33	3178862825	68001	3	5	0	2	252525	8 	2013-09-04	805	2000000	68001	1	52	0.00	1.00	2013-11-25	0
7 	7 	1098748771  	MARIA FERNANDA SUAREZ HERNANDEZ         	17	3	2014-12-29	1	CALLE 18N # 8-29 TEJAR 1	6406522	68001	1	2	0	2	1181294	23	2014-10-27	1176	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	91527748    	MOISES ESPINOSA CARDENAS                	15	3	1984-04-06	2	CALLE 8 No 29-84 PUERTO RICO	3173041236	68001	2	2	2	2	258964	23	2014-10-11	1165	680000	68255	1	52	1.00	1.00	2004-05-10	0
0 	0 	1095921258  	LEIDY CAROLINA PEÑATE SERRANO           	29	1	1990-03-24	1	CRA 19B # 10B - 31 VILLAS DE SAN JUAN	3143713621	68307	1	5	0	2	156813941	23	2014-10-27	1177	1100000	8001 	0	51	1.00	1.00	2004-05-10	0
0 	0 	74184465    	ROBINSON RUEDA VARGAS                   	29	1	1978-08-06	1	CLL 20 # 65 - 53 BUENAVISTA	3014005356	68001	1	5	0	2	16781671	23	2014-10-27	1178	1500000	68689	0	51	0.00	1.00	2004-05-10	0
7 	7 	1095805466  	CRISTIAN CAMILO LOPEZ GIL               	15	3	1990-06-20	2	CALLE 27A # 4E - 14 LA CUMBRE	3165519910	68276	1	2	0	2	19428427	23	2014-10-28	1179	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098780011  	BRYGITH DANIELA ALVAREZ JAIMES          	17	3	1996-01-23	1	CALLE 21N No 20 - 41 MZ 40 CASA 3 VILLA	3174451976	68001	1	1	0	2	184394681	23	2014-11-02	1180	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098715719  	MARYURI LIZETH MANTILLA VERGEL          	17	3	1991-07-30	1	AV LOS BUCAROS 3-05 SAMANES VI REAL DE M	6417401	68001	1	2	0	2	181456181	23	2014-11-05	1181	680000	68001	1	52	1.00	1.00	2004-05-10	0
1 	1 	1062401374  	LEINY JOHANA CALDERON LEON              	17	3	1994-05-30	1	CARRERA 35 No 37A - 46 SANTA BARBARA	6105636	68081	1	1	0	2	1845942	23	2014-11-01	1182	680000	20750	1	52	1.00	1.00	2004-05-10	0
7 	7 	1100894116  	ROSA MARIA MUÑOZ CAÑO                   	17	3	1993-10-05	1	CARRERA 26 No 17-33 SAN FRANCISCO	3176947678	68001	1	1	0	2	198194294	23	2014-11-01	1183	680000	68615	0	52	1.00	1.00	2004-05-10	0
9 	9 	1095911398  	DIANA PATRICIA BECERRA SUAREZ           	17	3	1987-09-02	1	CALLE 42 No 16-18 RINCON DE GIRON	3155413794	68307	1	5	0	2	18145684	23	2014-11-01	1184	680000	68307	0	52	1.00	1.00	2004-05-10	0
0 	0 	63354097    	ELISA PINZON ESTUPIÑAN                  	29	1	1969-12-09	1	CALLE 88 No 24-49 DIAMANTE II	6360450	68001	2	7	0	4	1984529841	23	2014-11-04	1185	3700000	54223	0	51	0.00	1.00	2004-05-10	0
1 	1 	1076382654  	CARLOS ANDRES ABADIA ARRIAGA            	15	3	1989-05-16	2	CARRERA 57 No 18 - 25 BUENA VISTA	3144023663	68081	1	2	0	2	19161914	23	2014-11-16	1187	680000	27787	0	52	1.00	1.00	2004-05-10	0
4 	4 	37843738    	KELTY YULEISSY TORRES                   	17	3	1980-11-26	1	CARRERA 32 No 32 - 16 TRES UNIDOS	3175856418	68081	1	5	0	2	191964812	23	2014-11-16	1188	680000	68689	0	52	1.00	1.00	2004-05-10	0
2 	2 	1098613812  	MANUEL ARMANDO SANDOVAL MARTINEZ        	15	3	1986-05-09	2	CARRERA 7A No 8-15	6480969	68001	1	5	0	2	6458963	23	2014-09-12	1152	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1098768110  	WILLIAM JAVIER FRANCO LOPEZ             	15	3	1995-04-12	2	CARRERA 6A MZA T CASA 376	6563853	68547	3	1	1	2	325864	23	2014-09-12	1153	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098658155  	GUSTAVO ADOLFO TARAZONA PARRA           	11	3	1988-09-07	2	CALLE 27 CN No 11A-28 ALTOS DEL KENNEDY	3176934097	68001	2	1	0	5	413626	8 	2013-09-12	940	680000	68001	0	52	1.00	1.00	2014-05-10	0
10	10	1102370665  	DIANA LIZETH DELGADO CIFUENTES          	17	3	1993-02-02	1	CALLE 21A No 1 - 19 LOS CISNES	3184934551	68547	1	1	0	2	298139411	23	2014-11-20	1189	680000	68547	0	52	1.00	1.00	2004-05-10	0
8 	8 	91505913    	JAIME ALEJANDRO SANCHEZ ALMEYDA         	15	3	1981-04-05	2	CALLE 2A No 11 - 49 VILLANUEVA	3175222633	68001	1	1	0	2	13139164	23	2014-11-16	1190	680000	68001	0	52	1.00	1.00	2004-05-10	0
4 	4 	1095828384  	YULIETH STEFANNY PEREZ RIVERA           	17	3	1996-04-04	1	CARRERA 53 NO 03-53	3123945325	68081	1	6	0	2	56879313	23	2014-12-01	1195	680000	68001	1	52	1.00	1.00	2004-05-10	0
1 	1 	1096208064  	MARION ROMERO MENDOZA                   	17	3	1990-11-11	1	CARRERA 47 No 37-08	3165241884	68081	1	1	0	2	456781313	23	2014-12-01	1196	680000	68081	0	52	1.00	1.00	2004-05-10	0
2 	2 	1095794214  	NESTOR DANIEL JAIMES CALA               	15	3	1987-11-30	2	CALLE 9 No 4-58	3172784703	68001	1	1	0	2	3456892	23	2014-12-01	1197	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1102352055  	DAMARIS PINTO PALACIOS                  	17	3	1987-03-02	1	CALLE 10 No 3-06	3118918119	68547	1	5	0	2	567894	23	2014-12-01	1198	680000	68547	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098762396  	YESICA KATERINE FERNANDEZ MUÑOZ         	17	3	1994-11-09	1	CALLE 104 E No 13-49	3184324499	68001	1	2	0	2	453558432	23	2014-12-01	1199	680000	68001	0	52	1.00	1.00	2004-05-10	0
8 	8 	1095827704  	* KAREN BIBIANA MEDINA MENDOZA          	17	3	1996-02-13	1	CARRERA 5 No 15-36 APTO 302	3172147079	68276	1	1	0	2	326487984	23	2014-12-01	1200	680000	68001	1	52	1.00	1.00	2004-05-10	0
2 	2 	1098628732  	JUAN LUIS AYALA VANEGAS                 	15	3	1987-01-08	2	CALLE 30A No 23-10	3173092112	68276	1	5	0	2	45369875	23	2014-12-02	1201	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1102361338  	YILBER ALEXIS MORENO VALERO             	15	3	1989-09-19	2	CARRERA 9 No 6-26	3208076385	68547	1	1	0	2	453584453	23	2014-12-02	1202	680000	68547	0	52	1.00	1.00	2004-05-10	0
8 	8 	1092358235  	ANDREA LISETH PALOMINO URIBE            	17	3	1995-03-17	1	ESTADERO REAL CAMPO ALEGRE,VEREDA	3162772439	68547	1	5	0	2	453967984	23	2014-12-03	1203	680000	68001	1	52	1.00	1.00	2004-05-10	0
4 	4 	1096201972  	VIVIANA MARCELA LANDAZABAL JAIMES       	17	3	1989-01-13	1	CALLE 34 No 27 - 09 CINCUENTENARIO	3208944331	68081	1	1	0	2	194139429	23	2014-11-27	1194	680000	68081	0	52	1.00	1.00	2004-05-10	0
7 	7 	1118557484  	NASLY CAROLINA GONZALEZ CUERVO          	17	3	1994-04-15	1	CARRERA 19 No 45-39	3108841500	68001	1	5	0	2	4561432156	23	2014-12-03	1204	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	63529645    	* LEIDY BIBIANA WALTEROS ASCANIO        	17	3	1982-02-20	1	CALLE 14 No 12-39 PISO 2	3204718104	68307	1	1	0	2	456431321	23	2014-12-05	1205	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1098682273  	* JANNNETH JOHANNA CRISTANCHO MORENO    	17	3	1989-10-27	1	CALLE 14A No 5-58	3165140535	68547	1	5	0	2	45434683	23	2014-12-07	1206	680000	68001	0	52	1.00	1.00	2004-05-10	0
8 	8 	37551007    	KAREN BIBIANA ZARATE PATIÑO             	17	3	1984-02-16	1	AVENIDA CANEYES,CASA 93	6590504	68307	1	5	0	2	41231564	23	2014-12-07	1207	680000	68895	0	52	1.00	1.00	2004-05-10	0
7 	7 	1098723732  	ERIKA JAZMIN DIAZ MEJIA                 	17	3	1991-06-27	1	CARRERA 17B NO 1C-04	3174863961	68001	1	5	0	2	11961616	23	2014-12-11	1208	680000	68001	0	52	1.00	1.00	2004-05-10	0
3 	3 	1098696249  	YURY ANDREA ARCINIEGAS ACUÑA            	17	3	1990-08-03	1	CALLE 1B No 17H - 11 TRANSICION II	6404667	68001	1	7	0	2	1919186191	23	2014-12-16	1209	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	1101208530  	SEBASTIAN PEREZ ARDILA                  	15	3	1996-02-17	2	CARRERA 24 No 8AN - 38 ESPERANZA I	3184645033	68001	1	6	0	2	191918156	23	2014-12-16	1210	680000	68406	0	52	1.00	1.00	2004-05-10	0
1 	1 	1096216761  	FABIAN ANDRES JARAMILLO GALE            	15	3	1992-07-23	2	CARRERA 31A No 29 - 75 CINCUENTENARIO	3143897541	68081	1	5	0	3	191619181	23	2014-12-15	1211	680000	68081	0	52	1.00	1.00	2004-05-10	0
8 	8 	1098686279  	LUIS CARLOS RINCON VALERO               	15	3	1990-03-18	2	CARRERA 12 No 49 - 12 VILLALUZ	3016547110	68276	3	5	0	2	191391618	23	2014-12-23	1212	680000	68001	1	52	1.00	1.00	2004-05-10	0
1 	1 	37577216    	MARIA ERIKA SUAREZ ACUÑA                	17	3	1983-09-24	1	CALLE 76B No 24a - 13 20 DE ENERO III ET	3004200055	68081	1	1	0	2	1919191	23	2015-01-10	1213	680000	68081	1	52	1.00	1.00	2004-05-10	0
8 	8 	63529511    	* CAROLINA RODRIGUEZ GONZALEZ           	17	3	1982-05-13	1	CALLE 1B BIS No 18-40 SAN FCO DE LA CUES	3158750324	68547	1	2	0	2	19161912	23	2014-12-23	1214	680000	68001	0	52	1.00	1.00	2004-05-10	0
8 	8 	1098712113  	YUDY BEATRIZ ORTIZ ROMERO               	17	3	1991-10-21	1	DIAGONAL 59 No 134-79 EL CARMEN	3187694273	68276	1	1	0	2	191369185	23	2015-01-10	1217	680000	68276	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098751732  	* LAURA LIZETH FONSECA ESPARZA          	17	3	1993-12-09	1	CALLE 13A No 15-12 VILLAMPIS	6598523	68307	1	5	0	2	19196181	23	2014-12-27	1216	680000	68001	0	52	1.00	1.00	2004-05-10	0
8 	8 	63560005    	NATALY JOHANA CAMARGO BENAVIDES         	17	3	1985-03-22	1	CRA 8B No 109-19 LA ESPAÑA	3182218891	68001	1	1	0	2	191681671	23	2015-01-10	1218	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	1005563154  	LILIANA PLATA SILVA                     	17	3	1992-06-18	1	CALLE 8A No 4 - 21 CARACOLI	6480969	68276	1	3	0	2	191671681	23	2015-01-16	1222	680000	68689	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098715309  	KAREN ALEXANDRA BERNAL CHANAGA          	17	3	1991-12-27	1	1	31639994428	68001	2	1	0	2	1313	8 	2014-01-29	1027	680000	68001	1	52	1.00	1.00	2014-05-10	0
8 	8 	63528255    	SINDY BIBIANA SARMIENTO CELIS           	20	3	1982-04-26	1	1	6918142	68001	2	1	0	5	1312	8 	2014-01-29	1028	1500000	68001	0	52	0.00	1.00	2014-05-10	0
8 	8 	63513837    	CLAUDIA YANETH PEREZ JAIMES             	17	3	1976-07-03	1	1	6902483	68001	2	1	0	2	23221	8 	2014-01-18	1029	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098765807  	LORENA ANDREA ESTUPIÑAN                 	39	3	1995-01-23	1	1	3182610666	68001	2	1	0	5	2323	8 	2014-01-23	1030	680000	68001	0	52	1.00	1.00	2014-05-10	0
4 	4 	1094247105  	EDINSON ALBERTO OTERO AVILA             	15	3	1989-02-02	1	1	6105364	68081	2	1	0	5	12123	8 	2014-07-08	1031	680000	68081	1	52	1.00	1.00	2014-05-10	0
9 	9 	1098765290  	NEYLYN ASHELEY CELIS ORTEGA             	17	3	1995-02-06	1	1	6731607	68001	2	1	0	5	123123	8 	2014-01-22	1032	680000	68001	0	52	1.00	1.00	2014-05-10	0
1 	1 	1096212562  	HUGO ALBERTO CASTRO CADENA              	15	3	1991-07-23	1	1	1	68001	1	1	0	2	131	23	2014-07-16	1131	680000	68001	0	52	1.00	1.00	2004-05-10	0
3 	3 	1098654220  	YENNY SOFIA URIBE VARGAS                	17	3	1987-12-03	1	1	1	68001	2	1	0	5	12312	23	2014-07-23	1132	680000	68001	1	52	1.00	1.00	2004-05-10	0
1 	1 	1096224314  	YORLEN MARITZA VILLA MATUTE             	17	3	1993-10-30	1	1	1	68001	2	1	0	2	21	23	2014-09-03	1133	680000	68001	1	52	1.00	1.00	2004-05-10	0
8 	8 	1098724962  	JAVIER GONZALO RODRIGUEZ RODRIGUEZ      	15	3	1992-08-05	2	CALLE 2B No 10-17 PRADOS DE VILLANUEVA	6999856	68547	1	5	0	2	191391961	23	2015-01-06	1219	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1095937096  	* WENDY DANAYA PICO AVELLANEDA          	17	3	1994-07-17	1	CALLE 19 No 18-04 GUYACANES	3106661230	68307	1	5	0	2	1916819	23	2015-01-03	1220	680000	68276	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098782898  	* JANETH SUSANA ARDILA GALVIS           	17	3	1996-04-14	1	CALLE 54 No 1W - 47 BALCON REAL	3152430076	68001	1	6	0	2	19191915	23	2015-01-03	1221	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	1098740154  	* ANGELA MILENA ROJAS FLOREZ            	17	3	1993-07-07	1	CALLE 8 No 40-33 EL DIVISO	6359719	68001	1	5	0	2	181381	23	2015-01-25	1223	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1095821619  	* KAROL DAYANA GOMEZ REY                	17	3	1994-11-20	1	SECTOR 5 MANZANA F CASA 85 CRISTAL BAJO	6362441	68001	1	5	0	2	196196158	23	2015-02-20	1237	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1098707742  	JENIFFER TATIANA ROMERO LEON            	39	3	1991-05-08	1	CARRERA 18A No 5-57 LA TRINIDAD	6186422	68276	3	5	0	2	19164152	23	2015-02-20	1238	680000	68001	0	52	1.00	1.00	2004-05-10	0
8 	8 	37551245    	LUZ DARY PRADA                          	17	3	1984-05-15	1	CALLE 35 No 16A- 36 RINCON DE GIRON	31356699811	68307	3	4	0	2	19816181	23	2015-02-19	1239	680000	68307	0	52	1.00	1.00	2004-05-10	0
10	10	1098658994  	YEIMI CATERINE CAMACHO GIRMALDOS        	17	1	1988-08-01	1	CRA 16 No 14-65 CASA 787 MZ W MOLINO DEL	3174578505	68547	3	2	0	2	191911	23	2015-02-18	1240	680000	68001	0	52	1.00	1.00	2004-05-10	0
12	12	1098785286  	* ESTEFANY CARDENAS COTE                	17	3	1996-05-05	1	DIAGONAL 11 No 15-99 VILLAMPIS	3152714479	68307	1	5	0	2	181381	23	2015-02-17	1241	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	1098649093  	YENNY ANDREA CAPACHO LONDOÑO            	17	3	1986-08-16	1	CARRERA 17 No 6-42 TORRE 1 APTO 405 VILL	6893446	68001	1	1	0	2	1813981	23	2015-02-16	1242	680000	68001	0	52	1.00	1.00	2004-05-10	0
7 	7 	1098719313  	* JESSICA CAROLINA ORTIZ PEÑALOZA       	17	3	1992-03-17	1	CARRERA 23 No 35-35 APTO 202 ANTONIA SAN	3124274288	68001	3	5	0	2	198181	23	2015-02-23	1243	680000	54223	0	52	1.00	1.00	2004-05-10	0
0 	0 	37512990    	MIREYA CALDERON RIOS                    	29	1	1977-04-10	1	CALLE 60 No 8W CONJ RESID FUNDADRES III	3184872567	68001	3	5	0	3	191678194	23	2015-02-12	1224	2100000	68001	0	51	0.00	1.00	2004-05-10	0
0 	0 	1098689892  	KAROL JULIETH SUAREZ FLETCHER           	29	1	1990-07-05	1	CARRERA 18 CASA 77 CIUDAD BOLIVAR	3002170243	68001	1	7	0	4	19619198	23	2015-02-12	1225	1300000	68001	0	51	0.00	1.00	2004-05-10	0
1 	1 	1096233506  	HEYDI JHOANA AYALA MORENO               	17	3	1995-06-02	1	VEREDA EL PROGRESO - CENTRO ECOPETROL	3163137665	68081	1	1	0	2	1916781	23	2015-02-11	1226	680000	68081	0	52	1.00	1.00	2004-05-10	0
12	12	1095815384  	RUBEN DARIO CASTAÑEDA MENDOZA           	15	3	1993-03-27	2	CALLE 58A NO 12-31 ALARES	3016807506	68276	1	6	0	2	1919618	23	2015-02-07	1227	680000	68001	0	52	1.00	1.00	2004-05-10	0
4 	4 	1096229211  	MARIANA SEPULVEDA MARIN                 	17	3	1994-08-15	1	DIAGONAL 63 No 49-85 BOSTON	3203868867	68081	1	1	0	2	1819174	23	2015-02-06	1228	680000	68081	0	52	1.00	1.00	2004-05-10	0
12	12	1095931300  	* LUSNEIDA QUINTERO ROSO                	17	3	1993-01-07	1	CALLE 42 No 14-10 RINCON DE GIRON	6462416	68307	3	5	0	2	18165441	23	2015-02-04	1229	680000	68307	0	52	1.00	1.00	2004-05-10	0
1 	1 	1096232982  	LINA PATRICIA BOHORQUEZ MENDOZA         	17	3	1995-05-04	1	VEREDA PENJA	3123467674	68081	1	1	0	2	198181	23	2015-02-21	1244	680000	68081	0	52	1.00	1.00	2004-05-10	0
1 	1 	1096209030  	LEYDIS CAROLINA ALCOCER NARVAEZ         	17	3	1990-12-15	1	CALLE 45 CARRERA 21 CASA 14 BUENOS AIRES	3105735381	68081	1	5	0	2	181381	23	2015-02-03	1230	680000	68575	0	52	1.00	1.00	2004-05-10	0
12	12	63523951    	* LUZ ADRIANA GONZALEZ BARRERA          	17	3	1981-06-09	1	CARRERA 24 No 19-21 PORTAL CAMPESTRE	6590058	68307	1	7	0	2	181681	23	2015-02-03	1231	680000	68001	0	52	1.00	1.00	2004-05-10	0
8 	8 	1095803385  	LUIS ALFREDO CARDENAS MONTAGUT          	15	3	1989-12-06	2	MANZANA F CASA 9 CHACARITA II	3163209583	68547	1	5	0	2	198164	23	2015-02-03	1232	680000	68001	0	52	1.00	1.00	2004-05-10	0
4 	4 	52865724    	* MARYURY DEL CARMEN SALDAÑA VIRGUEZ    	17	3	1981-10-12	1	CALLE 52 No 18-71 URIBE URIBE	3114927729	68081	2	5	0	2	5498164	23	2015-02-01	1233	680000	20011	0	52	1.00	1.00	2004-05-10	0
4 	4 	1098663449  	* SILVIA MARCELA GONZALEZ FORERO        	17	3	1988-12-21	2	CALLE 33A No 43-38 LA PLANADA DEL CERRO	3183567482	68081	3	5	0	2	2581681	23	2015-02-01	1234	680000	68276	0	52	1.00	1.00	2004-05-10	0
3 	3 	1095916236  	DIANA PATRICIA LEON BARBA               	17	3	1988-09-09	1	CALLE 104G No 7-18 PISO 3 PORVENIR	3045978545	68001	1	5	0	2	181681	23	2015-02-01	1235	680000	68001	0	52	1.00	1.00	2004-05-10	0
4 	4 	1096220477  	CARLOS MANUEL ACERO ARCINIEGAS          	15	3	1992-12-25	2	CALLE 34A No 27-14 CINCUENTENARIO	3138104680	68081	1	1	0	2	18191	23	2015-02-01	1236	680000	68081	0	52	1.00	1.00	2004-05-10	0
0 	0 	13513863    	RICARDO RUEDA TOBO                      	29	1	1977-11-18	2	CALLE 21 No 2-61 PASEO REAL	6389559	68547	3	5	0	2	1491681	23	2015-02-25	1245	1300000	68001	0	51	0.00	1.00	2004-05-10	0
12	12	1098730003  	NELSON DAVID MEZA MASQUEZ               	15	1	1992-11-15	2	CALLE 63 No 1-76 PARQUE REAL T 3 APT 233	3158354111	68001	1	1	0	2	1816181	23	2015-02-25	1246	680000	68001	0	52	1.00	1.00	2004-05-10	0
8 	8 	60397919    	* ANGELA MARIA VEGA CONTRERAS           	17	3	1979-08-14	1	CARRERA 0W No 6BN - 66 PARAISO II	6491402	68547	1	5	0	2	19619191	23	2014-12-19	1215	680000	54223	0	52	1.00	1.00	2004-05-10	0
1 	1 	1096216294  	YOJAY YALITZA GOMEZ RODRIGUEZ           	17	3	1990-05-23	1	MANZ 35 CASA 463 SAN SILVESTRE	3107513983	68081	2	1	0	5	231321	8 	2013-04-09	875	680000	68081	1	52	1.00	1.00	2014-03-01	0
2 	2 	1095807277  	IVON TATIANA ROJAS VILLAMIZAR           	39	4	1990-10-07	1	CONJUNTO RESIDENCIAL SECTOR 19 BUCARICA	6487947	68001	1	1	0	2	13210	8 	2014-07-04	876	680000	68001	0	52	1.00	1.00	2014-04-01	0
9 	9 	1098781291  	YENNY CAROLINA SOLANO MARQUEZ           	17	3	1996-02-06	1	WDFEGRT	682545	68001	1	1	0	2	1121	23	2014-06-19	1108	680000	68001	0	52	1.00	1.00	2004-05-10	0
10	10	1016043121  	MONICA HERREÑO LANDINEZ                 	43	3	1992-11-02	1	CRA 13 No 8-43 SAN RAFAEL-PTA	3202963423	68001	2	1	0	2	223	3 	2013-04-11	879	680000	68001	1	52	1.00	1.00	2014-03-01	0
9 	9 	1095943269  	* KAREN DAYANA RUBIANO RANGEL           	17	3	1996-02-18	1	CARRERA 18 No 1n - 46 SAN CARLOS	3123280811	68547	1	5	0	2	1913913	23	2014-11-26	1191	680000	68001	0	52	1.00	1.00	2004-05-10	0
2 	2 	1095824256  	* SAIDA LILIANA ACERO VILLAMIZAR        	17	3	1995-05-12	1	CALLE 15 No 11 - 06 LOS ROSALES	6398215	68276	1	5	0	2	191684296	23	2014-11-26	1192	680000	68001	0	52	1.00	1.00	2004-05-10	0
9 	9 	1056776933  	* MAIRA ALEJANDRA PINEDA SOLER          	17	3	1991-10-25	1	CARRERA 2da AW No 62 - 09 MUTIS	6835636	68001	1	6	0	2	19832926	23	2014-11-26	1193	680000	15572	0	52	1.00	1.00	2004-05-10	0
0 	0 	63369216    	LIBIA STELLA SARMIENTO VESGA            	29	1	1972-05-08	1	CALLE 106 No 23a - 44 PROVENZA	6364196	68001	1	1	0	4	1615813685	23	2014-11-14	1186	5500000	68679	0	51	0.00	1.00	2004-05-10	0
4 	4 	1096227917  	LISETH ALEJANDRA GUTIERREZ FRIAS        	17	3	1994-06-16	1	CRA 54 147 ALTOS DEL CAMPESTRE	3125734982	68575	1	5	0	2	252525	8 	2013-01-10	831	680000	68081	1	52	1.00	1.00	2014-01-09	0
7 	7 	1098701764  	NYDIA JULIETH MORENO PARRA              	17	3	1990-08-26	1	CARRERA 28 CALLE 49 No 27-35	3158085507	68001	1	1	0	2	213	5 	2015-02-19	951	680000	68001	0	52	1.00	1.00	2014-05-10	0
8 	8 	1095809190  	YASMIN GISELA RUIZ LUCUARA              	17	3	1991-03-09	1	FINCA PALMIRA	6773355	68001	1	5	0	2	12321	8 	2013-10-10	952	680000	68001	1	52	1.00	1.00	2014-05-10	0
1 	1 	1065587174  	RAFAEL JOSE REYES CHINCHILLA            	15	3	1987-01-29	2	1	1	68081	2	1	0	2	13212	8 	2014-01-25	1033	680000	68081	1	52	1.00	1.00	2014-05-10	0
1 	1 	1096191596  	ANDRES GIL ROJAS FERNANDEZ              	15	3	1987-08-08	2	1	1	68001	3	1	0	4	213132	8 	2014-01-26	1034	680000	68001	0	52	1.00	1.00	2014-05-10	0
2 	2 	13865465    	CARLOS ALBERTO RUEDA RUEDA              	15	3	1979-08-17	2	Ñ,FG,DFLGMD,	3168944178	68001	2	1	0	1	322313	8 	2014-05-27	1098	680000	68001	1	52	1.00	1.00	2004-05-10	0
7 	7 	28138719    	LORENA LISBEY CAMPOS HIGUERA            	40	3	1982-05-17	1	1	3213859934	68001	2	1	0	2	3212	8 	2014-01-27	1035	680000	68001	0	52	1.00	1.00	2014-05-10	0
10	10	1098674994  	CRHISTIAN FABIAN CALDERON NAVARRO       	10	3	1989-08-29	1	1	1	68001	2	1	0	2	12121	8 	2014-01-29	1036	740000	68001	0	52	1.00	1.00	2014-05-10	0
2 	2 	1095800963  	HASBLEIDY PAOLA LOZADA JAIMES           	17	3	1989-06-04	1	1	6483790	68001	2	1	0	2	14545	8 	2014-07-04	1037	680000	68001	1	52	1.00	1.00	2014-05-10	0
12	12	96011023590 	JENNY YUBELI CARRILLO PORTILLA          	39	3	2004-05-10	1	1	3178219820	68001	2	1	0	5	232	8 	2014-04-02	1038	680000	68001	1	52	1.00	1.00	2014-05-10	0
9 	9 	28155761    	ANGIE VANESSA REINA CALDERON            	17	3	1982-06-25	1	1	1	68001	2	1	0	2	132323	8 	2014-01-21	1039	680000	68001	1	52	1.00	1.00	2014-05-10	0
\.


--
-- Data for Name: configurarinv; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY configurarinv (id, usuario, cara, gondola, tipoinv) FROM stdin;
1	mauricio            	44	33	2
\.


--
-- Name: configurarinv_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('configurarinv_id_seq', 1, true);


--
-- Data for Name: empleados_maes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY empleados_maes (id, tipodoc_id, numero_doc, nombre1, nombre2, apellido1, apellido2, contrato, estado, id_almacen, c_costo, nit_empleado, nombre, id_cargo, tipo_empleado, fecha_nacimiento, sexo, direccion, telefono, ciudad_reside, estado_civil, grupo_sanguineo, personas_a_cargo, id_nivel, id_cuenta, id_banco, fecha_ingreso, id_contrato, sueldo_basico, ciudad_nacimiento, id_estado, tipo_contable, factor_transporte, factor_sueldo, terminacion_contrato, emp_img) FROM stdin;
2	1	63334739	MARTHA MALDONADO GUA	\N	null                	\N	\N	\N	0 	0 	63334739    	MARTHA MALDONADO GUARIN                 	29	1	1967-04-23	1	Car.  8 No. 61-137  BGA	6410422	68001	1	1	0	2	0	60	1995-10-02	2	3100000	68780	1	51	0.00	1.00	2006-10-05	0
4	1	63367439	EDITA MALAVER DURAN 	\N	null                	\N	\N	\N	0 	0 	63367439    	EDITA MALAVER DURAN                     	29	1	1971-02-14	1	DIG 10 No 20A-13 GIRON  BGA	6591254	68307	1	1	0	2	0	60	1998-08-20	4	700000	68001	1	51	0.00	1.00	2005-12-30	0
1	1	37580301	CINDY MILENA ROA CAM	\N	\N	\N	\N	\N	1 	1 	37580301    	CINDY MILENA ROA CAMPO                  	17	3	1985-04-24	1	ADJPAKDJAJDKJL	64370000	68001	2	1	0	5	45	8 	2007-10-03	253	461500	68001	1	52	0.00	1.00	2008-10-30	0
3	1	91427130	WILSON RIOS RINCON  	\N	\N	\N	\N	\N	1 	1 	91427130    	WILSON RIOS RINCON                      	102	1	1965-11-27	2	DIG 54B No 22B - 50  SFCO	6463224	68307	1	1	0	2	0	60	1988-05-21	5	1700000	68081	0	52	0.00	1.00	2005-12-30	0
5	1	37935323	PORFIRIA C BARROSO B	\N	\N	\N	\N	\N	0 	0 	37935323    	PORFIRIA C BARROSO BERASTEGUI           	29	3	1966-03-02	1	CLL 60A  No 37-14  BARRANCA	6221732	68081	1	1	0	2	0	60	1992-03-02	7	2700000	68081	0	52	0.00	1.00	2005-12-30	0
6	1	28285070	NIDIA ALEXANDRA PATI	\N	\N	\N	\N	\N	0 	0 	28285070    	NIDIA ALEXANDRA PATIÑO                  	29	1	1979-11-15	1	BUCARICA BLQ 18-2 APT 502  BGA	6484552	68276	1	1	0	2	0	60	2004-08-30	8	650000	68533	1	51	0.00	1.00	2006-12-30	0
7	1	37930277	ADELA LOPEZ NOVA    	\N	\N	\N	\N	\N	1 	1 	37930277    	ADELA LOPEZ NOVA                        	17	1	1961-08-15	1	CRA 38 No 36C-83 CALIDAD	6106790	68081	1	1	0	2	0	60	2004-05-10	13	461500	68081	1	52	0.00	1.00	2005-12-30	0
8	1	91446775	LUIS CARLOS PASSO RO	\N	\N	\N	\N	\N	4 	4 	91446775    	LUIS CARLOS PASSO ROJASA                	15	3	1976-01-26	2	CRA 8 No 47-51 BARRANCA	6206305	68081	1	1	0	2	0	60	2003-04-21	14	461500	68081	1	52	0.00	1.00	2005-12-30	0
9	1	91422999	EMEL MORALES GIL    	\N	\N	\N	\N	\N	1 	1 	91422999    	EMEL MORALES GIL                        	15	1	1974-12-16	2	CRA 52 No. 26-57  CALIDAD	6105665	68081	1	1	0	2	0	60	2004-06-01	15	550000	13300	1	52	0.00	1.00	2005-12-30	0
10	1	37864635	SILVIA JULIANA PRIET	\N	\N	\N	\N	\N	0 	0 	37864635    	SILVIA JULIANA PRIETO LUNA              	29	1	1981-07-18	1	masxmenos	6447300	68001	1	1	0	4	107-158555	5 	2004-12-15	98	800000	68001	1	51	0.00	1.00	2005-12-15	0
11	1	36505582	HEIDY DE J QUEVEDO A	\N	\N	\N	\N	\N	4 	4 	36505582    	HEIDY DE J QUEVEDO ACUÑA                	16	1	1975-07-27	1	PTN 6 No 36E-22  BARRANCA	6219190	68081	1	1	0	2	0	60	2004-07-16	17	496900	47707	1	52	0.00	1.00	2004-12-30	0
12	1	37933870	MARIA EUGENIA BLANCO	\N	\N	\N	\N	\N	4 	4 	37933870    	MARIA EUGENIA BLANCO MANCIPE            	12	1	1966-03-30	1	CLL 51 No 15-27 CALIDAD	6226709	68081	1	1	0	2	0	5 	2004-06-22	18	1000000	68615	1	52	0.00	1.00	2005-06-27	0
13	1	109579258	EDUARDO JOSE MERLANO	\N	\N	\N	\N	\N	1 	1 	1095792580  	EDUARDO JOSE MERLANO CELIS              	17	3	1987-04-09	2	JAJDLJAD	6447300	68001	2	1	0	5	5465456456	8 	2007-05-24	239	433700	68001	1	52	0.00	1.00	2008-05-24	0
14	1	63463261	ROSA MARIA ULLOA POL	\N	\N	\N	\N	\N	4 	4 	63463261    	ROSA MARIA ULLOA POLANCO                	17	1	1973-12-22	1	CLL 52B No 34C 05  BARRANCA	6219134	68081	1	1	0	2	0	60	2004-06-15	20	535600	68081	1	52	0.00	1.00	2006-12-30	0
15	1	13854428	DONALDI MONTES BAEZ 	\N	\N	\N	\N	\N	1 	1 	13854428    	DONALDI MONTES BAEZ                     	15	1	1982-01-18	2	CLL56 NO 34D - 20  CALIDAD	6101234	68081	1	1	0	2	0	60	2004-07-01	21	433700	68081	1	52	0.00	1.00	2005-07-01	0
16	1	37513420	MARGARITA MARIA BAUT	\N	\N	\N	\N	\N	0 	0 	37513420    	MARGARITA MARIA BAUTISTA LOPEZ          	29	1	1978-01-01	1	mas por menos	6447300	68001	2	5	1	4	0	5 	2004-02-23	99	800000	68001	1	51	0.00	1.00	2005-02-23	0
17	1	37842598	CAROLINA SIERRA VALE	\N	\N	\N	\N	\N	0 	0 	37842598    	CAROLINA SIERRA VALERO                  	29	1	1981-02-23	1	C. RES FATIMA CS 11H  BGA	6313624	68001	1	1	0	2	0	60	2004-08-09	23	850000	68001	1	51	0.00	1.00	2005-08-09	0
18	1	91445943	EDWIN URIBE TARAZONA	\N	\N	\N	\N	\N	1 	1 	91445943    	EDWIN URIBE TARAZONA                    	14	1	1976-09-07	2	CLL 42 No 42-08 BARRANCA	6205109	68081	1	1	0	2	0	60	2010-08-04	24	750000	68081	1	52	0.00	1.00	2006-12-30	0
19	1	91505559	ALBEIRO BAUTISTA FLO	\N	\N	\N	\N	\N	6 	6 	91505559    	ALBEIRO BAUTISTA FLOREZ                 	15	3	1980-05-14	2	HASHDUIASYDSAHDJO	6486189	68276	1	5	0	2	525252	8 	2005-11-10	102	433700	68276	1	52	0.00	1.00	2006-11-09	0
20	1	63513094	ZOILA ISABEL JIMENEZ	\N	\N	\N	\N	\N	5 	5 	63513094    	ZOILA ISABEL JIMENEZ S                  	12	1	1976-06-24	1	CRA 21  No 35-10  PROVENZA	6300062	68001	1	1	0	2	0	60	2004-08-30	26	1000000	68001	1	52	0.00	1.00	2005-08-30	0
21	1	88237934	RAFAEL ARRIETA BALDO	\N	\N	\N	\N	\N	4 	4 	88237934    	RAFAEL ARRIETA BALDOVINO                	15	3	1980-01-01	2	BARRANCA	6224514	68081	1	5	0	2	0	5 	2006-06-01	100	433700	68081	1	52	0.00	1.00	2006-12-30	0
22	1	91440135	EDWARD JAVIER GONZAL	\N	\N	\N	\N	\N	1 	1 	91440135    	EDWARD JAVIER GONZALEZ                  	20	1	1972-03-17	2	 DIG 57 No 43-145  CALIDAD	6216668	68081	1	1	0	2	0	60	2013-07-10	28	1550000	68081	1	52	0.00	1.00	2005-08-30	0
23	1	63539643	YENY YOMARA DELGADO 	\N	\N	\N	\N	\N	2 	2 	63539643    	YENY YOMARA DELGADO RUIZ                	14	1	1983-06-17	1	CALLE 51 N§ 15-25  BUCARICA	6815550	68001	1	1	0	2	0	60	2004-09-01	29	500000	68001	1	52	0.00	1.00	2005-12-30	0
24	1	63468882	DANEXI DITA TAPIAS  	\N	\N	\N	\N	\N	1 	1 	63468882    	DANEXI DITA TAPIAS                      	17	1	1975-10-28	1	CRA 36I No 50-45  BARRANCA	6217771	68081	1	1	0	2	0	60	2004-09-06	30	433700	68081	1	52	0.00	1.00	2005-09-06	0
25	1	91487783	EDDINSON FDO. BARON 	\N	\N	\N	\N	\N	0 	0 	91487783    	EDDINSON FDO. BARON PEDRAZA             	29	1	1976-04-16	2	BLOQUE 17-1 APTO 201  BGA	6481389	68276	1	1	0	2	0	60	2007-02-05	31	1200000	68001	1	51	0.00	1.00	2005-09-13	0
26	1	37511819	YASMIN BARRERA RINCO	\N	\N	\N	\N	\N	0 	0 	37511819    	YASMIN BARRERA RINCON                   	29	1	1976-04-26	1	CLL 19 No 26-78  SFCO	6594043	68001	1	1	0	2	0	60	2004-09-16	32	2200000	68081	0	51	0.00	1.00	2005-09-30	0
27	1	37713601	SHIRLEY ARIZA       	\N	\N	\N	\N	\N	0 	0 	37713601    	SHIRLEY ARIZA                           	29	1	1960-07-10	1	BGA	000-00000	68001	1	1	0	2	0	60	2004-08-30	33	800000	68001	1	51	0.00	1.00	2006-08-28	0
28	1	28483971	CLAUDIA MILENA CASTI	\N	\N	\N	\N	\N	1 	1 	28483971    	CLAUDIA MILENA CASTILLO ZARATE          	17	3	1979-08-04	1	BARRANCA	6224514	68081	1	5	0	2	0	8 	2005-12-19	101	433700	68081	1	52	0.00	1.00	2005-10-22	0
29	1	13715183	JHON JAIME BAREÑO   	\N	\N	\N	\N	\N	3 	3 	13715183    	JHON JAIME BAREÑO                       	19	1	1978-08-28	2	CARRERA 14 Nø 50-04 FLORIDA	6814185	68276	1	1	0	2	0	60	2008-07-04	35	950000	68001	1	52	0.00	1.00	2005-10-01	0
30	1	60397853	ANGELA MARIA MENESES	\N	\N	\N	\N	\N	1 	1 	60397853    	ANGELA MARIA MENESES RUEDA              	17	1	1979-11-16	1	CALLE 52 No 34F-16  BARRANCA	6216916	68081	1	1	0	2	0	60	2004-09-27	37	433700	54001	1	52	0.00	1.00	2005-09-30	0
31	1	37901101	BLANCA LEON GOMEZ   	\N	\N	\N	\N	\N	2 	2 	37901101    	BLANCA LEON GOMEZ                       	17	3	1984-06-12	1	NBJHGJHJGHJ	6486189	68276	1	5	0	2	456456465	8 	2004-06-23	103	461500	68276	1	52	0.00	1.00	2005-06-23	0
32	1	91498826	DANIEL ENRIQUE REMOL	\N	\N	\N	\N	\N	2 	2 	91498826    	DANIEL ENRIQUE REMOLINA                 	15	3	1976-05-17	1	mas por menos	6486189	76275	1	5	0	2	545645465	8 	2004-08-30	104	461500	76275	1	52	0.00	1.00	2005-08-30	0
33	1	91492813	JAIRO ALONSO MORENO 	\N	\N	\N	\N	\N	2 	2 	91492813    	JAIRO ALONSO MORENO JARAMILLO           	15	3	1976-10-26	2	njkhjihjih	6486189	68001	1	5	0	2	156465456465	8 	2004-10-14	105	433700	68001	1	52	0.00	1.00	2005-10-14	0
34	1	91254980	WILLIAM RAMIREZ QUIN	\N	\N	\N	\N	\N	2 	2 	91254980    	WILLIAM RAMIREZ QUINTERO                	12	1	1960-07-16	2	CRA 4 No 1A-08 C. VERDE  BGA	6541612	68547	1	1	0	2	0	60	2010-02-01	40	3000000	68001	0	52	0.00	1.00	2005-10-01	0
35	1	91516573	JOSE DEL CARMEN BARR	\N	\N	\N	\N	\N	7 	7 	91516573    	JOSE DEL CARMEN BARRERA DUARTE          	31	3	1982-12-03	2	FLORIDA	6486189	68001	1	1	0	2	45445	8 	2006-08-01	130	1040000	68001	1	52	0.00	1.00	2006-03-06	0
36	1	91539339	VICTOR  ALFONSO SOLA	\N	\N	\N	\N	\N	6 	6 	91539339    	VICTOR  ALFONSO SOLANO GOMEZ            	15	3	1985-05-17	2	SAN FRANCISCO	6320505	68001	1	5	0	2	4542645664	8 	2005-12-06	106	433700	68001	1	52	0.00	1.00	2005-11-08	0
37	1	63449128	GLORIA ADIVI RODRIGU	\N	\N	\N	\N	\N	6 	6 	63449128    	GLORIA ADIVI RODRIGUEZ JAIMES           	17	1	1975-03-29	1	BLQ 22-20 APTO 422 SC 19 BUCAR	6483892	68276	1	1	0	2	0	60	2003-10-27	43	433700	68001	1	52	0.00	1.00	2005-12-30	0
38	1	13748029	EDUARD DANILO CAMACH	\N	\N	\N	\N	\N	9 	9 	13748029    	EDUARD DANILO CAMACHO                   	12	3	1981-01-26	2	DIAG. 105 N¦ 104E -196 PROVENZ	6377507	68001	1	1	0	2	0	60	2004-11-16	44	3000000	15693	0	52	0.00	1.00	2008-06-28	0
39	1	91291777	CRISTIAN ALEXANDER C	\N	\N	\N	\N	\N	0 	0 	91291777    	CRISTIAN ALEXANDER CELY INFANTE         	29	1	1973-06-13	2	MAS X MENOS SFCO	63250505	68001	2	5	0	4	26465456465456	8 	2004-09-13	107	2000000	68001	1	51	0.00	1.00	2005-09-13	\N
40	1	91285660	JORGE LUIS LIZARAZO 	\N	\N	\N	\N	\N	3 	3 	91285660    	JORGE LUIS LIZARAZO                     	15	3	1972-05-22	2	MAS X MENOS	6320505	68001	2	5	0	2	64545645456	8 	2004-06-11	108	433700	68001	1	52	0.00	1.00	2005-06-11	0
41	1	91298308	OMAR VILLAMIZAR ANAY	\N	\N	\N	\N	\N	0 	0 	91298308    	OMAR VILLAMIZAR ANAYA                   	29	1	1974-06-17	2	CLL 15 No 10-50 GAITAN  BGA	6719522	68001	1	1	0	2	0	60	2003-11-24	48	770000	68001	1	51	0.00	1.00	2005-12-24	0
42	1	37860600	MARTHA YOLANDA BARRI	\N	\N	\N	\N	\N	7 	7 	37860600    	MARTHA YOLANDA BARRIOS TORRES           	16	3	1981-05-05	1	FLORIDA	6486189	68001	2	1	0	2	545456456	8 	2005-03-01	131	461500	68001	1	52	0.00	1.00	2006-03-01	0
43	1	63537287	LUZ ARGEIDYZ LOPEZ R	\N	\N	\N	\N	\N	4 	4 	63537287    	LUZ ARGEIDYZ LOPEZ ROJAS                	17	3	1983-03-17	1	BARRANCA	6206547	68081	2	1	0	2	4654564564	8 	2004-09-10	110	433700	68081	1	52	0.00	1.00	2005-09-10	0
44	1	91156190	FREDY ANTONIO GALEAN	\N	\N	\N	\N	\N	6 	6 	91156190    	FREDY ANTONIO GALEANO PENA              	15	1	1973-07-27	2	CARRERA 16A - 1B -31 BUCARICA	6555354	68001	1	1	0	2	0	60	2003-12-01	49	433700	68001	1	52	0.00	1.00	2005-12-30	0
45	1	63555055	MARCELA PINEDA  GUTI	\N	\N	\N	\N	\N	1 	1 	63555055    	MARCELA PINEDA  GUTIERREZ               	17	3	1984-07-03	2	BARRANCA	6203747	68081	1	5	0	2	151564	8 	2004-11-02	111	461500	68081	1	52	0.00	1.00	2005-11-02	0
46	1	5135444	MANUEL BARRETO RICO 	\N	\N	\N	\N	\N	5 	5 	5135444     	MANUEL BARRETO RICO                     	15	3	1980-08-27	1	PROVENZA	6312116	68001	1	5	0	2	454545456	8 	2005-11-10	112	496900	68001	1	52	0.00	1.00	2006-11-09	0
47	1	19083037	ORLANDO MEJIA LEON  	\N	\N	\N	\N	\N	3 	3 	19083037    	ORLANDO MEJIA LEON                      	30	3	2005-02-16	1	SAN FRANCISCO	6320505	68001	2	1	0	2	107-	8 	2005-02-16	129	433700	68001	1	52	0.00	1.00	2005-12-30	0
48	1	91496381	EDWIN CIFUENTES YEPE	\N	\N	\N	\N	\N	4 	4 	91496381    	EDWIN CIFUENTES YEPES                   	15	3	1980-01-01	2	MASXMENOS	6447300	68081	1	5	0	4	107-	25	2005-01-01	125	433700	68081	1	52	0.00	1.00	2005-12-30	0
49	1	19401655	JESUS CRUZ NAVAS    	\N	\N	\N	\N	\N	0 	0 	19401655    	JESUS CRUZ NAVAS                        	29	1	1960-07-10	2	MASXMENOS	6447300	68001	2	5	2	4	107-	5 	1998-04-27	126	3700000	68001	0	51	0.00	1.00	2005-12-31	0
50	1	37860637	DEICY DURAN GONZALEZ	\N	\N	\N	\N	\N	7 	7 	37860637    	DEICY DURAN GONZALEZ                    	17	1	1981-03-20	1	SFCO	000-00000	68001	1	1	0	2	0	60	2005-06-16	54	433700	68001	1	52	0.00	1.00	2005-12-30	0
51	1	91268515	ROBERT NIÑO RAMIREZ 	\N	\N	\N	\N	\N	0 	0 	91268515    	ROBERT NIÑO RAMIREZ                     	29	1	1960-08-13	2	CRA 12 No 20-06 KENEDY  BGA	6400424	68001	1	1	0	2	0	60	2006-01-10	57	1300000	68001	0	51	0.00	1.00	2010-06-15	0
52	1	7175155	OSCAR JAVIER CORTES 	\N	\N	\N	\N	\N	5 	5 	7175155     	OSCAR JAVIER CORTES MARTINEZ            	15	4	1976-11-25	1	PROVENZA	6312116	68001	1	5	0	2	5454456	8 	2004-11-02	113	433700	68001	1	52	0.00	1.00	2005-11-02	0
53	1	63356869	OLGA LEONOR PEREZ RO	\N	\N	\N	\N	\N	8 	8 	63356869    	OLGA LEONOR PEREZ ROSAS                 	12	3	1970-09-26	1	SECT 1 BLOQ 1-3 APTO 501 PROVE	6498846	68276	1	1	0	2	0	60	2010-03-15	59	1800000	68001	1	52	0.00	1.00	2008-06-28	0
54	1	63558874	DAYANA MILENA MARIN 	\N	\N	\N	\N	\N	7 	7 	63558874    	DAYANA MILENA MARIN                     	17	3	1985-04-09	1	PROVENZA	6312116	68001	1	5	0	2	572752572	25	2006-05-15	114	433700	68001	1	52	0.00	1.00	2007-05-14	0
55	1	37724151	LIBIA  GONZALEZ RODR	\N	\N	\N	\N	\N	5 	5 	37724151    	LIBIA  GONZALEZ RODRIGUEZ               	17	3	1978-11-12	1	PROVENZA	6312116	68081	1	5	0	2	4645456	54	2004-08-05	115	433700	68081	1	52	0.00	1.00	2005-08-05	0
56	1	63453420	DIANA CECILIA DAVILA	\N	\N	\N	\N	\N	5 	5 	63453420    	DIANA CECILIA DAVILA                    	17	1	1983-08-30	1	BLQ 10-10 APTO 502  FLORIDA	6482117	68276	1	1	0	2	0	60	2004-01-22	61	433700	68276	1	52	0.00	1.00	2004-12-31	0
57	1	63515530	BEATRIZ CIFUENTES CA	\N	\N	\N	\N	\N	0 	0 	63515530    	BEATRIZ CIFUENTES CARDONA               	29	1	1976-11-07	1	CRA 10AN No 27N-13  SFCO	6409084	68001	1	1	0	2	0	60	2004-01-22	62	700000	5001 	1	51	0.00	1.00	2004-12-20	0
58	1	37842126	SANDY KARINA CARDENA	\N	\N	\N	\N	\N	2 	2 	37842126    	SANDY KARINA CARDENAS MOLINA            	17	1	1980-10-14	1	CLL 28 No 7-28  FLORIDA	6383251	68001	1	1	0	2	0	60	2005-01-01	64	433700	68276	1	52	0.00	1.00	2005-01-15	0
59	1	28488479	DEISY JOHANNA FLOREZ	\N	\N	\N	\N	\N	4 	4 	28488479    	DEISY JOHANNA FLOREZ GRATERON           	33	1	1981-12-01	1	CALIDAD	000-00000	68081	1	1	0	2	0	60	2005-08-22	67	461500	68081	1	52	0.00	1.00	2004-12-31	0
60	1	63537035	PILAR CRISTINA GALVI	\N	\N	\N	\N	\N	1 	1 	63537035    	PILAR CRISTINA GALVIS JIMENEZ           	17	1	1983-03-10	1	CALIDAD	000-00000	68081	1	1	0	2	0	60	2004-02-01	66	433700	68081	1	52	0.00	1.00	2005-01-30	0
61	1	91448836	JUVENAL GONZALEZ RIC	\N	\N	\N	\N	\N	7 	7 	91448836    	JUVENAL GONZALEZ RICO                   	15	1	1977-11-21	2	CALIDAD	000-00000	68081	1	1	0	2	0	60	2009-05-01	65	535600	68081	1	52	0.00	1.00	2007-02-21	0
62	1	63500025	YOLANDA VERGARA RIVE	\N	\N	\N	\N	\N	10	10	63500025    	YOLANDA VERGARA RIVERA                  	18	3	1974-12-21	1	PROVENZA	6312116	68001	1	5	0	2	46545456	8 	2009-07-16	116	1400000	68001	0	52	0.00	1.00	2007-05-21	0
63	1	63490704	CLAUDIA PATRICIA TRU	\N	\N	\N	\N	\N	3 	3 	63490704    	CLAUDIA PATRICIA TRUJILLO BRICEÑO       	17	3	1973-10-13	1	PROVENZA	6312116	68001	3	5	0	2	465546546	54	2005-01-11	117	433700	68001	1	52	0.00	1.00	2005-12-11	0
64	1	37512985	CARMEN YOLANDA DELGA	\N	\N	\N	\N	\N	0 	0 	37512985    	CARMEN YOLANDA DELGADO AYALA            	29	1	1977-06-06	1	BGA	000-00000	68001	0	1	0	2	0	60	2004-02-02	69	2500000	68001	1	51	0.00	1.00	2004-08-30	0
65	1	13748669	PABLO JOSE SANCHEZ S	\N	\N	\N	\N	\N	6 	6 	13748669    	PABLO JOSE SANCHEZ SANCHEZ              	15	1	1980-04-20	2	PROVENZA	000-00000	68001	1	1	0	2	0	60	2005-02-01	71	433700	68001	1	52	0.00	1.00	2005-12-30	0
66	1	5478370	ALEXANDER PARADA RIV	\N	\N	\N	\N	\N	5 	5 	5478370     	ALEXANDER PARADA RIVERA                 	15	3	1979-07-08	2	PROVENZA	6312116	68001	1	5	0	2	588585	8 	2005-01-14	118	433700	68001	1	52	0.00	1.00	2006-01-14	0
67	1	37706049	LUZ STELLA CRUZ NAVA	\N	\N	\N	\N	\N	0 	0 	37706049    	LUZ STELLA CRUZ NAVAS                   	29	1	1968-04-29	1	masxmenos	6447300	68001	2	5	0	4	0	5 	2015-02-03	119	6600000	68001	0	51	0.00	1.00	2005-12-30	0
68	1	91490791	JONH EDUARDO QUINTER	\N	\N	\N	\N	\N	0 	0 	91490791    	JONH EDUARDO QUINTERO SANTOS            	29	1	1960-07-10	2	BGA	000-00000	68001	1	1	0	2	0	60	2004-02-11	74	800000	68001	1	51	0.00	1.00	2005-02-11	0
69	1	63352218	SMITH PATRICIA CARRE	\N	\N	\N	\N	\N	0 	0 	63352218    	SMITH PATRICIA CARREÑO                  	29	1	1969-03-23	1	BGA	000-00000	68001	1	1	0	2	0	60	2004-02-16	75	1100000	68001	1	51	0.00	1.00	2006-12-30	0
70	1	63453396	CLAUDIA PATRICIA RIN	\N	\N	\N	\N	\N	2 	2 	63453396    	CLAUDIA PATRICIA RINCON PE¥A            	17	1	1983-11-11	1	CRA 13 No 7-38  SFCO	6485310	68276	1	1	0	2	0	60	2004-02-23	76	433700	68276	1	52	0.00	1.00	2004-12-31	0
71	1	63528743	LISBETH GONZALEZ LOP	\N	\N	\N	\N	\N	2 	2 	63528743    	LISBETH GONZALEZ LOPEZ                  	17	1	1982-05-20	1	CRA 28B No 95-31  FLORIDA	6496028	68276	1	1	0	2	0	60	2004-02-24	78	433700	68081	1	52	0.00	1.00	2005-02-24	0
72	1	63450554	OMAIRA REY ROJAS    	\N	\N	\N	\N	\N	6 	6 	63450554    	OMAIRA REY ROJAS                        	17	3	1979-10-29	1	SAN FRANCISCO	6320505	68001	2	1	0	2	0	8 	2005-02-02	122	433700	68001	1	52	0.00	1.00	2005-12-30	0
73	1	91275118	CARLOS MANUEL TORRES	\N	\N	\N	\N	\N	5 	5 	91275118    	CARLOS MANUEL TORRES PICO               	19	1	1970-12-02	2	CLL 4 No 12-16 NUEV VILLAB FLO	6380618 -	68001	1	1	0	2	0	60	2006-01-23	80	1100000	68679	1	52	0.00	1.00	2007-01-22	0
74	1	63557885	LADY PAOLA URIBE ROD	\N	\N	\N	\N	\N	5 	5 	63557885    	LADY PAOLA URIBE RODRIGUEZ              	17	3	1985-01-28	1	asdmkadklkadlk	6447300	68001	2	1	0	5	456456465	8 	2007-05-23	240	461500	68001	1	52	0.00	1.00	2008-05-23	0
75	1	63536351	LUDY DUARTE GUERRERO	\N	\N	\N	\N	\N	2 	2 	63536351    	LUDY DUARTE GUERRERO                    	17	1	1982-11-13	1	CLL 8 No 8-32  FLORIDA	6826803	68276	1	1	0	2	0	60	2004-03-23	81	433700	68276	1	52	0.00	1.00	2005-03-15	0
76	1	28070443	MIRLEY BAHAMON MEDEL	\N	\N	\N	\N	\N	1 	1 	28070443    	MIRLEY BAHAMON MEDEL                    	17	3	1980-05-25	1	COLOMBIA	6203547	68001	2	1	0	2	125456	8 	2005-02-01	123	433700	68001	1	52	0.00	1.00	2005-12-30	0
77	1	28061158	DORIS YADIRA MAYORAL	\N	\N	\N	\N	\N	1 	1 	28061158    	DORIS YADIRA MAYORAL ALVAREZ            	17	3	1981-02-09	1	BARRANCA	6224514	68001	1	1	0	2	0	8 	2006-03-27	124	433700	68001	1	52	0.00	1.00	2007-03-26	0
78	1	60370364	BLANCA ISABEL SANABR	\N	\N	\N	\N	\N	2 	2 	60370364    	BLANCA ISABEL SANABRIA                  	17	1	1975-11-21	1	BUCARICA	000-00000	68276	1	1	0	2	0	60	2004-03-31	85	433700	68001	1	52	0.00	1.00	2006-05-15	0
79	1	5654487	RAUL ANDRES GARCES P	\N	\N	\N	\N	\N	2 	2 	5654487     	RAUL ANDRES GARCES PAEZ                 	15	1	1983-12-17	2	PROVENZA	000-00000	68001	1	1	0	2	0	60	2004-04-01	86	433700	68001	1	52	0.00	1.00	2005-04-01	0
80	1	37547571	ADRIANA CHAPARRO AZA	\N	\N	\N	\N	\N	6 	6 	37547571    	ADRIANA CHAPARRO AZA                    	17	3	1980-01-01	1	MASXMENOS	6447300	68001	1	5	0	2	107-	5 	2005-01-17	127	433700	68001	1	52	0.00	1.00	2005-12-01	0
81	1	63367541	EDDY ROSMARY REATIGA	\N	\N	\N	\N	\N	0 	0 	63367541    	EDDY ROSMARY REATIGA RIVERA             	29	1	1980-01-01	1	MASXMENOS	6447300	68001	1	5	0	4	107-	5 	2004-09-28	128	680000	68001	1	51	0.00	1.00	2005-12-31	0
82	1	13747758	WILLIAM GIOVANNY VIL	\N	\N	\N	\N	\N	2 	2 	13747758    	WILLIAM GIOVANNY VILLAMIZAR             	15	3	1980-12-28	2	MXM	6447300	68001	2	5	0	2	107-	5 	2006-06-21	121	433700	68001	1	52	0.00	1.00	2006-12-20	0
83	1	91439589	JOSE EVELIO DIAZ GUE	\N	\N	\N	\N	\N	4 	4 	91439589    	JOSE EVELIO DIAZ GUEVARA                	15	1	1971-12-16	2	CLL52 No 36B-101   BARRANCA	6219016	68081	1	1	0	2	0	60	2004-02-24	91	433700	68081	1	52	0.00	1.00	2005-04-30	0
84	1	28054669	LEIDY MARIANA BLANCO	\N	\N	\N	\N	\N	6 	6 	28054669    	LEIDY MARIANA BLANCO                    	17	3	1980-05-26	1	PROVENZA	6312116	68001	1	1	0	2	46548545645	8 	2005-03-23	132	433700	68001	1	52	0.00	1.00	2005-03-23	0
85	1	13511029	ANTONIO ROBLES HERNA	\N	\N	\N	\N	\N	2 	2 	13511029    	ANTONIO ROBLES HERNANDEZ                	15	1	1977-11-20	2	FLORIDA	000-00000	68276	1	1	0	2	0	60	2004-04-26	92	433700	68001	1	52	0.00	1.00	2004-12-30	0
86	1	93377960	MIGUEL ANTONIO RAMOS	\N	\N	\N	\N	\N	12	12	93377960    	MIGUEL ANTONIO RAMOS SIERRA             	12	1	1969-12-11	2	BLOQUE 5 -3 APTO 201  FLORIDA	6483054	68276	1	1	0	2	0	60	2014-01-13	93	2600000	73001	0	52	0.00	1.00	2005-04-30	0
87	1	91181376	ELKIN HELI CHARRIS D	\N	\N	\N	\N	\N	5 	5 	91181376    	ELKIN HELI CHARRIS DAVILIA              	31	1	1978-09-07	2	CRA 22 No 103-17  PROVENZA	6466148	68001	1	1	0	2	0	60	2004-05-10	94	550000	68001	1	52	0.00	1.00	2005-05-15	0
88	1	37844980	MARITZA LUCIA HERAZO	\N	\N	\N	\N	\N	1 	1 	37844980    	MARITZA LUCIA HERAZO AMARIS             	20	1	1981-05-31	1	BARRANCA	000-00000	68081	1	1	0	2	0	60	2004-05-13	95	680000	68001	1	52	0.00	1.00	2005-03-30	0
89	1	37620613	YENY CARELY RUEDA   	\N	\N	\N	\N	\N	2 	2 	37620613    	YENY CARELY RUEDA                       	17	3	1985-09-26	1	FLORIDA	6486189	68001	1	1	0	2	454564654	8 	2005-04-02	133	433700	68001	1	52	0.00	1.00	2005-12-30	0
90	1	91351364	LUIS ERNESTO RAMIREZ	\N	\N	\N	\N	\N	3 	3 	91351364    	LUIS ERNESTO RAMIREZ ARANDA             	15	3	1979-05-20	1	SAN FRANCISCO	6320505	68001	2	1	0	5	5454546	8 	2005-04-18	135	433700	68001	1	52	0.00	1.00	2005-12-30	0
91	1	63450613	MARTHA MEJIA MANTILL	\N	\N	\N	\N	\N	5 	5 	63450613    	MARTHA MEJIA MANTILLA                   	16	1	1979-11-13	1	CRA.42 Nø 88-63  FLORIDA	6487328	68276	1	1	0	2	0	60	2004-05-17	97	433700	68001	1	52	0.00	1.00	2005-04-01	0
92	1	109578927	JHON JAIRO BUITRAGO 	\N	\N	\N	\N	\N	2 	2 	1095789279  	JHON JAIRO BUITRAGO GARCIA              	15	3	1986-09-26	2	FLORIDA	6320505	68001	1	1	0	5	4545465	8 	2006-09-18	136	433700	68001	1	52	0.00	1.00	2005-12-30	0
93	1	91507076	LUIS FERNANDO VELEZ 	\N	\N	\N	\N	\N	6 	6 	91507076    	LUIS FERNANDO VELEZ MEZA                	15	3	1981-12-25	2	BUCARICA	6496724	68001	2	1	0	5	454554	8 	2005-04-06	134	433700	68001	1	52	0.00	1.00	2005-12-30	0
94	1	91538911	RODRIGUEZ MORENO EDI	\N	\N	\N	\N	\N	4 	4 	91538911    	RODRIGUEZ MORENO EDINSSON MAURICIO      	32	3	1981-05-10	2	BARRANCA	6203547	68001	2	1	0	2	5828757857	8 	2004-01-02	137	650000	68001	1	52	0.00	1.00	2005-12-08	0
95	1	63529727	MARIA DEL CARMEN SAN	\N	\N	\N	\N	\N	2 	2 	63529727    	MARIA DEL CARMEN SANDOVAL               	17	3	1982-03-04	1	FLORIDA	6486189	68001	2	1	0	2	454845465	8 	2005-05-16	138	433700	68001	1	52	0.00	1.00	2005-06-15	0
96	1	91506135	EDWIN GONZALO URIBE 	\N	\N	\N	\N	\N	3 	3 	91506135    	EDWIN GONZALO URIBE ORTIZ               	15	3	1981-12-17	2	PROVENZA	6312116	68001	2	1	0	2	45456456465	8 	2005-05-16	139	433700	68001	1	52	0.00	1.00	2005-12-30	0
97	1	32930622	MARIA ALEJANDRA ACOS	\N	\N	\N	\N	\N	6 	6 	32930622    	MARIA ALEJANDRA ACOSTA CAMPO            	17	3	1982-12-13	1	FLORIDABLANCA	6486189	68001	2	1	0	2	46546546	40	2005-06-24	144	461500	68001	1	52	0.00	1.00	2006-06-24	0
98	1	13716095	JOAN MARCELLO MENESE	\N	\N	\N	\N	\N	5 	5 	13716095    	JOAN MARCELLO MENESES GOMEZ             	15	3	1978-12-28	2	FLORIDA	6486189	68001	1	1	0	2	1552454	8 	2005-07-21	146	461500	68001	1	52	0.00	1.00	2005-12-31	0
99	1	37861455	SILVIA JULIANA CORRE	\N	\N	\N	\N	\N	5 	5 	37861455    	SILVIA JULIANA CORREDOR RODRIGUEZ       	17	3	1980-05-28	1	PROVENZA	6312116	68001	2	1	0	2	1524646462	8 	2005-08-11	148	433700	68001	1	52	0.00	1.00	2005-12-31	0
100	1	91530620	EDDINSON  EDUARDO VI	\N	\N	\N	\N	\N	5 	5 	91530620    	EDDINSON  EDUARDO VILLAMIZAR FLOREZ     	15	3	1983-10-16	1	CLLE 70  N 44W-156	6447300	68001	1	1	0	2	15622445	8 	2005-08-25	149	433700	68001	1	52	0.00	1.00	2005-11-30	0
101	1	63492700	SANDRA PATRICIA  AMA	\N	\N	\N	\N	\N	4 	4 	63492700    	SANDRA PATRICIA  AMAYA RAMIREZ          	12	1	1973-12-20	2	clle 70 n. 44w-156 km 04	6447300	68001	1	1	0	2	1544446	8 	2005-08-16	150	1200000	68001	1	52	0.00	1.00	2005-12-31	0
102	1	63543718	YENNY RAMIREZ       	\N	\N	\N	\N	\N	3 	3 	63543718    	YENNY RAMIREZ                           	17	3	1983-10-16	1	clle 70 n. 44ww-156	6447300	68001	1	1	0	2	15822532	25	2005-08-25	151	461500	68001	1	52	0.00	1.00	2005-12-31	0
103	1	13569008	DANIEL BARBA DIAZ   	\N	\N	\N	\N	\N	4 	4 	13569008    	DANIEL BARBA DIAZ                       	22	3	1984-06-07	2	BARRBCA	6203547	68081	1	1	0	2	4545454	8 	2005-06-07	140	461500	68001	1	52	0.00	1.00	2005-12-30	0
104	1	91159649	FERNANDO RAMIREZ TOR	\N	\N	\N	\N	\N	6 	6 	91159649    	FERNANDO RAMIREZ TORRES                 	15	3	1981-03-30	2	PROVENZA	6447300	68001	2	1	0	5	45454	8 	2005-09-12	153	461500	68001	1	52	0.00	1.00	2005-12-31	0
105	1	37754614	KELLY JOHANNA DURAN 	\N	\N	\N	\N	\N	4 	4 	37754614    	KELLY JOHANNA DURAN LOPEZ               	17	3	1980-10-25	1	BARRANCA	6203547	68081	1	1	0	2	578578787	40	2005-10-19	154	461500	68081	1	52	0.00	1.00	2006-02-18	0
106	1	91529373	FERNEY DAVIAN SANTIE	\N	\N	\N	\N	\N	6 	6 	91529373    	FERNEY DAVIAN SANTIESTEBAN JIMENEZ      	34	3	1984-04-11	2	MAS X MENOS SFCO	6320505	68001	1	1	0	2	2212333	40	2005-10-26	155	680000	68001	1	52	0.00	1.00	2006-02-25	0
107	1	101840745	GREIS CAROLINA SABIO	\N	\N	\N	\N	\N	7 	7 	1018407453  	GREIS CAROLINA SABIO BARRERA            	14	3	1986-12-07	1	PROVENZA	6312116	68001	1	1	0	2	545754567	8 	2007-04-16	145	650000	68001	1	52	0.00	1.00	2006-12-31	0
108	1	28152971	ZAIDA JOHANNA ARCINI	\N	\N	\N	\N	\N	0 	0 	28152971    	ZAIDA JOHANNA ARCINIEGAS BUSTOS         	29	1	1980-11-06	1	cr 40no.107-17  B. SANTA FE	6492892	68276	1	1	0	3	7878787	40	2005-10-27	156	500000	68276	1	51	0.00	1.00	2006-02-26	0
109	1	28469373	DORA NATHALIA BUENAH	\N	\N	\N	\N	\N	2 	2 	28469373    	DORA NATHALIA BUENAHORA HERNANDEZ       	18	3	1972-11-12	1	PROVENZA	6312116	68001	2	1	0	5	45465654	5 	2010-03-30	160	1400000	68001	0	52	0.00	1.00	2006-12-30	0
110	1	63530843	YUDDY ARLET RODRIGUE	\N	\N	\N	\N	\N	2 	2 	63530843    	YUDDY ARLET RODRIGUEZ  HERNANDEZ        	17	3	1982-08-09	1	PROVENZA	6312116	68001	2	1	0	2	465756454654	8 	2005-08-11	147	433700	68001	1	52	0.00	1.00	2005-12-31	0
111	1	63469377	MARIA EUGENIA BURITI	\N	\N	\N	\N	\N	1 	1 	63469377    	MARIA EUGENIA BURITICA RODRIGUEZ        	17	3	1980-07-18	1	DIA 58A NO 50-57	6103599	68081	2	1	0	4	13809601	5 	2005-12-20	161	461500	50110	1	52	0.00	1.00	2006-04-19	0
112	1	109862833	ANGIE CATHERYN CADEN	\N	\N	\N	\N	\N	6 	6 	1098628333  	ANGIE CATHERYN CADENA RANGEL            	17	3	1986-10-25	1	calle 39 N. 6 - 1E	6848916	68276	1	1	0	2	5555	40	2006-01-17	163	433700	68276	1	52	0.00	1.00	2006-05-16	0
905	1	109864766	LUZ DARY HERNANDEZ C	\N	\N	\N	\N	\N	7 	7 	1098647665  	LUZ DARY HERNANDEZ CHAPARRO             	17	3	1988-01-01	1	1	1	68001	2	1	0	2	5213	8 	2013-11-26	990	680000	68001	0	52	1.00	1.00	2014-05-10	0
113	1	63555693	DIANA CAROLINA LLANE	\N	\N	\N	\N	\N	4 	4 	63555693    	DIANA CAROLINA LLANES MIRA              	17	3	2004-11-23	1	TRANSV21NO. 62-24 B.BUENAVISTA	6204403	68081	0	1	0	3	123133	5 	2006-09-11	164	515000	68081	1	52	0.00	1.00	2006-07-17	0
114	1	63469467	OLINDA ALVAREZ QUINT	\N	\N	\N	\N	\N	1 	1 	63469467    	OLINDA ALVAREZ QUINTERO                 	17	3	2004-01-27	1	TRANSV46NO. 49-48 B.LAS GRANJAS	6023173	68081	1	1	0	2	31313	5 	2006-02-01	165	461500	68081	1	52	0.00	1.00	2007-01-30	0
115	1	72186842	7                   	\N	\N	\N	\N	\N	0 	0 	72186842    	7                                       	29	1	2004-02-22	2	CLL 41 NO. 38-65 APT 1203 CABECERA	6345736	68001	4	1	0	6	2121	5 	2006-02-01	166	433700	68001	1	51	0.00	1.00	2007-05-10	0
116	1	37619853	LEIDY CAROLINA HERNA	\N	\N	\N	\N	\N	3 	3 	37619853    	LEIDY CAROLINA HERNANDEZ FLOREZ         	17	3	2004-09-30	1	KRA 7 NO.12-75 CANDELARIA/PIEDECUESTA	6541306	68547	1	1	0	3	1223	5 	2006-02-10	167	461500	68001	1	52	0.00	1.00	2007-02-09	0
117	1	60392434	LIZETH BIBIANA AMAYA	\N	\N	\N	\N	\N	2 	2 	60392434    	LIZETH BIBIANA AMAYA SILVA              	17	3	2006-02-01	1	CRA9ANO. 8-60 CASA 201 Urbn COVI FLORIDA	6496798	68276	2	1	0	2	15454	5 	2006-02-01	168	433700	68547	1	52	0.00	1.00	2007-01-31	0
118	1	28229154	YOLANDA MILENA LOZAN	\N	\N	\N	\N	\N	6 	6 	28229154    	YOLANDA MILENA LOZANO SIERRA            	16	3	1981-04-03	1	CRA15NO.1N-31 SAN CARLOS * PIEDECUESTA	6564632	68547	1	1	0	2	5454	5 	2007-06-25	169	461500	68425	1	52	0.00	1.00	2007-07-02	0
119	1	91510591	DIDIER FERNANDO DUAR	\N	\N	\N	\N	\N	2 	2 	91510591    	DIDIER FERNANDO DUARTE MORERA           	15	3	1982-06-26	2	PROVENZA	63121116	68001	2	1	0	5	144454	8 	2005-09-01	152	433700	68001	1	52	0.00	1.00	2005-12-31	0
120	1	13510263	LINARCO OCHOA JAIMES	\N	\N	\N	\N	\N	6 	6 	13510263    	LINARCO OCHOA JAIMES                    	34	4	1977-03-28	2	KRA18NO.57-47 EL PALENQUE	6464779	68307	1	1	0	2	2121	8 	2006-02-01	170	433700	68547	1	52	0.00	1.00	2007-01-31	0
121	1	63548230	YESENIA GALEANO MONT	\N	\N	\N	\N	\N	2 	2 	63548230    	YESENIA GALEANO MONTERO                 	17	3	1984-03-20	1	FLORIDA	6486189	68001	2	1	1	2	1325413	8 	2006-03-13	178	433700	68001	1	52	0.00	1.00	2007-03-12	0
122	1	109869849	ANGIE LIZETH DURAN C	\N	\N	\N	\N	\N	9 	9 	1098698490  	ANGIE LIZETH DURAN CARDONA              	17	3	1990-12-20	1	CALLE 60 N° 8w-160	6440515	68001	2	5	1	2	252525	8 	2012-02-14	701	566700	68081	1	52	1.00	1.00	2013-02-13	0
123	1	109862791	FRANCY HELENA SEPULV	\N	\N	\N	\N	\N	0 	0 	1098627914  	FRANCY HELENA SEPULVEDA NAVAS           	29	1	1985-12-05	1	CLL 14B N.19A-57 CONSUELO - GIRON	6999863	68307	1	1	1	3	2	95	2013-01-16	159	1200000	68001	0	51	1.00	1.00	2006-01-31	0
124	1	91255369	ALBERTO BERNARDO ROS	\N	\N	\N	\N	\N	0 	0 	91255369    	ALBERTO BERNARDO ROSAS TIBANA           	29	1	2004-05-10	2	FKSFLKSFJ	6312548	68001	2	1	0	5	414545	8 	2006-01-05	162	700000	68001	1	51	0.00	1.00	2006-12-31	0
125	1	49670761	BEYXI CAROLINA VALER	\N	\N	\N	\N	\N	6 	6 	49670761    	BEYXI CAROLINA VALERO MANTILLA          	17	3	1983-02-07	1	CRA 40 NO. 107-15 B.SANTA FE	6492892	68001	1	1	0	3	212211	8 	2006-02-16	173	433700	20011	1	52	0.00	1.00	2006-06-15	0
126	1	91443589	LUIS CARLOS ACUÑA CA	\N	\N	\N	\N	\N	1 	1 	91443589    	LUIS CARLOS ACUÑA CANTILLO              	15	3	1974-05-02	2	BARRANCA	6224514	68001	1	5	0	2	4545464	25	2005-06-17	141	433700	68001	1	52	0.00	1.00	2006-06-17	0
127	1	109618809	MONICA PLATA LOPEZ  	\N	\N	\N	\N	\N	1 	1 	1096188092  	MONICA PLATA LOPEZ                      	17	3	1987-03-28	1	BARRANCA	6224514	68001	1	1	0	2	44456	8 	2005-06-17	142	433700	68001	1	52	0.00	1.00	2006-06-17	0
128	1	63508772	ROCIO DEL PILAR ACEV	\N	\N	\N	\N	\N	5 	5 	63508772    	ROCIO DEL PILAR ACEVEDO RAMIREZ         	17	3	1976-01-19	1	BUCARAMANGA	6312116	68001	1	1	0	2	445456465	5 	2005-06-22	143	433700	68001	1	52	0.00	1.00	2006-06-22	0
129	1	37862621	JOHANA LOPEZ LIEVANO	\N	\N	\N	\N	\N	7 	7 	37862621    	JOHANA LOPEZ LIEVANO                    	17	3	1980-11-14	1	CLL 106 N. 50-33 B.SANTA HELENA	6771390	68001	3	1	1	2	1	95	2005-12-03	157	461500	68655	1	52	0.00	1.00	2006-12-02	\N
130	1	13723560	EDUARDO NOVOA CORDOB	\N	\N	\N	\N	\N	0 	0 	13723560    	EDUARDO NOVOA CORDOBA                   	29	1	1979-11-29	2	CALLE 14B No 19 A 57	6475890	68001	1	1	0	6	4545617	8 	2006-03-27	179	1100000	68001	1	51	0.00	1.00	2007-03-26	0
131	1	37545990	JANNETH BALAGUERA ME	\N	\N	\N	\N	\N	0 	0 	37545990    	JANNETH BALAGUERA MELENDEZ              	29	1	1977-07-14	1	CRA 20 NO 50-16	6590899	68001	1	2	0	5	124546	8 	2007-10-01	180	3700000	68001	0	51	0.00	1.00	2007-03-15	0
132	1	109862415	JESUS FERNANDO MARTI	\N	\N	\N	\N	\N	3 	3 	1098624150  	JESUS FERNANDO MARTINEZ SERRANO         	15	1	1986-06-25	2	CLL 44 NO 31-125	6328526	68001	1	1	0	4	6523	8 	2006-06-01	183	461500	68001	1	52	0.00	1.00	2007-11-05	0
133	1	13513313	FAVIO RENE RODRIGUEZ	\N	\N	\N	\N	\N	6 	6 	13513313    	FAVIO RENE RODRIGUEZ ARDILA             	15	1	1977-07-25	2	CRA 40 N0 32-165	6532841	68001	1	1	0	1	4546565	40	2006-06-01	184	433700	68001	1	51	0.00	1.00	2007-05-31	0
134	1	13568755	JULIAN ANDRES BOLIVA	\N	\N	\N	\N	\N	4 	4 	13568755    	JULIAN ANDRES BOLIVAR VELASQUEZ         	15	1	1984-08-08	2	CALLE 14 B NO 13-52	6200527	68081	1	1	0	2	12161032	8 	2006-07-27	186	433700	68081	1	52	0.00	1.00	2008-12-06	0
135	1	63539644	NANCY JANETH GOMEZ C	\N	\N	\N	\N	\N	5 	5 	63539644    	NANCY JANETH GOMEZ CARREÑO              	17	3	1983-06-19	1	CARRERA 2E No 29b-4  APTO 102	3156207806	68001	1	1	0	2	54131541	8 	2006-08-01	187	461500	68001	1	52	0.00	1.00	2007-07-31	0
136	1	13870136	ELIAN DARIO QUINTERO	\N	\N	\N	\N	\N	2 	2 	13870136    	ELIAN DARIO QUINTERO VARGAS             	14	1	1981-03-30	2	CLL 70 No 44W-156 KM 4 VIA GIRON	6447330	68001	1	1	0	4	4454151	8 	2006-08-26	188	550000	68001	1	52	0.00	1.00	2007-08-25	0
137	1	13923777	MIGUEL ANGEL LOZANO 	\N	\N	\N	\N	\N	0 	0 	13923777    	MIGUEL ANGEL LOZANO CASTELLANOS         	29	1	1966-04-17	2	CRA 23 No 11-50 MGKFG	441254	68001	2	1	0	5	321123	8 	2012-02-24	189	2000000	68001	1	51	0.00	1.00	2007-08-13	0
138	1	91521135	NELSON IVAN AYALA BE	\N	\N	\N	\N	\N	0 	0 	91521135    	NELSON IVAN AYALA BERNAL                	29	1	1983-07-11	2	FNSDFN.FDÇS	2	323  	1	1	0	4	1415616	8 	2007-01-04	190	433700	68001	1	51	0.00	1.00	2007-08-17	0
139	1	85166757	ALVARO SAUCEDO CADEN	\N	\N	\N	\N	\N	4 	4 	85166757    	ALVARO SAUCEDO CADENA                   	20	1	1978-09-29	2	MSADFKBVFDG	545522	68001	1	1	0	2	415413	8 	2011-01-04	191	1250000	68001	1	52	0.00	1.00	2007-08-14	0
140	1	13851597	JUAN  DE JESUS URREA	\N	\N	\N	\N	\N	4 	4 	13851597    	JUAN  DE JESUS URREA FERREIRA           	15	3	1980-06-03	2	VEREDA CAMPO 6 POZO No 432	6222362	68081	2	1	1	2	4313244	8 	2006-04-26	181	461500	68081	1	52	0.00	1.00	2007-04-25	0
141	1	13746377	JAIME JULIAN CARREÑO	\N	\N	\N	\N	\N	2 	2 	13746377    	JAIME JULIAN CARREÑO GOMEZ              	15	1	1980-12-02	2	CLL 15 No 13-56	63256587	68001	1	1	0	4	4545644546	5 	2006-09-07	192	433700	68001	1	52	0.00	1.00	2007-09-06	0
142	1	63552136	CLAUDIA PATRICIA DUA	\N	\N	\N	\N	\N	7 	7 	63552136    	CLAUDIA PATRICIA DUARTE VARGAS          	17	1	1984-03-20	1	CLEE JFKSDFLFKSFSAÑ	6738930	68001	1	1	0	2	54541564151	8 	2007-01-04	198	433700	68001	1	52	0.00	1.00	2007-10-20	0
143	1	91507249	OSCAR MAURICIO PANQU	\N	\N	\N	\N	\N	6 	6 	91507249    	OSCAR MAURICIO PANQUEVA ANGEL           	15	1	1982-01-14	2	CDSJKFNJSFL	6811735	68001	3	1	0	2	11221326	8 	2006-11-17	199	461500	68001	1	52	0.00	1.00	2007-11-16	0
144	1	37747992	YESENIA PARDO HERNAN	\N	\N	\N	\N	\N	3 	3 	37747992    	YESENIA PARDO HERNANDEZ                 	17	1	1980-01-28	1	Adbshfksdb6511	44655	68001	1	1	0	2	456156	8 	2006-12-22	203	433700	68001	1	52	0.00	1.00	2007-12-21	0
892	1	109840817	FRANCY MARCELA PRADA	\N	\N	\N	\N	\N	10	10	1098408176  	FRANCY MARCELA PRADA MARTINEZ           	17	3	1991-10-29	1	fsdd	5587	68001	1	1	0	2	1322	8 	2013-11-16	972	680000	68001	1	52	1.00	1.00	2014-05-10	0
145	1	13720321	WILLIAM RODOLFO MEND	\N	\N	\N	\N	\N	5 	5 	13720321    	WILLIAM RODOLFO MENDOZA QUIÑONEZ        	15	3	1979-04-05	2	SDAKF SDFWGFPA8+55267	565634345	68001	1	1	0	2	465213254	8 	2007-01-03	204	433700	68001	1	52	0.00	1.00	2007-12-02	0
146	1	63558879	YURANY  MUÑOZ DUARTE	\N	\N	\N	\N	\N	6 	6 	63558879    	YURANY  MUÑOZ DUARTE                    	17	1	1985-02-15	1	CLL 70 NO 44W 165	6447535	68001	1	1	0	2	416532	8 	2006-06-16	185	433700	68001	1	52	0.00	1.00	2007-06-15	0
147	1	109866376	YURI KARINA BUENO RO	\N	\N	\N	\N	\N	7 	7 	1098663763  	YURI KARINA BUENO RONDON                	16	3	1988-12-30	1	gjhjkhhjk	6496724	68001	2	1	0	5	45454	8 	2007-01-04	206	496900	68001	1	52	0.00	1.00	2008-01-03	0
148	1	55231658	DAYANA PATRICIA MIRA	\N	\N	\N	\N	\N	2 	2 	55231658    	DAYANA PATRICIA MIRANDA OTERO           	17	3	1985-12-05	1	CKDSHKFDKSP´GHLFGHBÉ	524165565	68001	2	1	0	5	4455465	8 	2007-02-10	212	461500	68001	1	52	0.00	1.00	2007-12-30	0
149	1	109863883	LESLIE JULIET NAVARR	\N	\N	\N	\N	\N	2 	2 	1098638837  	LESLIE JULIET NAVARRO RODRIGUEZ         	17	3	1987-07-14	1	CALLE 19 No 11B -57 ROSALES	6799477	68001	1	1	0	2	4565332	8 	2007-02-21	214	433700	68001	1	52	0.00	1.00	2007-12-30	0
150	1	37559749	CONSUELO ARIAS GONZA	\N	\N	\N	\N	\N	2 	2 	37559749    	CONSUELO ARIAS GONZALEZ                 	17	3	1978-08-02	1	CL 204DnO. BI40-42 LOS ANDRES	6827135	68276	1	1	0	2	545454	8 	2006-02-16	171	433700	68001	1	52	0.00	1.00	2006-06-15	0
151	1	52999599	ERIKA YADIRA DELGADO	\N	\N	\N	\N	\N	2 	2 	52999599    	ERIKA YADIRA DELGADO PINTO              	17	3	1984-12-28	1	FLORIDABLANCA	6447300	68276	1	1	0	4	212121	8 	2006-02-01	172	515000	1001 	1	51	0.00	1.00	2006-12-31	0
152	1	63547471	DIANA PATRICIA VARON	\N	\N	\N	\N	\N	0 	0 	63547471    	DIANA PATRICIA VARON PINZON             	29	1	1984-02-23	1	CALLE 104C No 12º - 09 MANUELA BELTRAN	6376261	68001	1	1	0	4	4154531	8 	2007-02-23	215	680000	68001	1	51	0.00	1.00	2007-12-30	0
153	1	63345846	SONIA MEZA DUARTE   	\N	\N	\N	\N	\N	0 	0 	63345846    	SONIA MEZA DUARTE                       	29	1	1998-02-13	1	JDKAJDJAD	6447300	68001	2	1	0	5	444465465	8 	2007-03-12	218	1000000	5002 	1	51	0.00	1.00	2008-03-11	0
154	1	91296346	JAVIER HUMBERTO VIVI	\N	\N	\N	\N	\N	2 	2 	91296346    	JAVIER HUMBERTO VIVIESCAS ALMEIDA       	33	3	1973-05-18	2	JDKLAJDKLJALKD	64545445	76100	2	1	0	5	546565	8 	2009-07-04	219	515000	5002 	1	52	0.00	1.00	2008-03-10	0
155	1	13716907	JAIME ALEXANDER SILV	\N	\N	\N	\N	\N	6 	6 	13716907    	JAIME ALEXANDER SILVA RAMIREZ           	15	3	1979-02-12	2	KALFKAKF	6447300	68001	2	1	0	5	454654	8 	2007-03-08	220	433700	68001	1	52	0.00	1.00	2008-03-08	0
156	1	109578979	MILENA ROCIO RINCON 	\N	\N	\N	\N	\N	2 	2 	1095789794  	MILENA ROCIO RINCON GONZALEZ            	17	1	1986-02-24	1	CARRERA 15 No 15-35	5415612	68001	2	1	0	5	4511156	8 	2006-09-20	194	433700	68001	1	52	0.00	1.00	2007-09-19	0
157	1	28061454	BRINY LUCIA DONADO A	\N	\N	\N	\N	\N	1 	1 	28061454    	BRINY LUCIA DONADO ARIZA                	17	1	1981-11-15	1	VDHJFFKFSJDF,A	4453225	68081	2	1	0	5	2311210231	8 	2006-09-27	195	433700	68081	1	52	0.00	1.00	2007-09-26	0
158	1	91178722	JUAN PABLO VILLAMIZA	\N	\N	\N	\N	\N	0 	0 	91178722    	JUAN PABLO VILLAMIZAR                   	29	1	1972-01-25	1	sec 17 bloq 3-8 apt 101 ALTO BELLAVISTA	6371571	68001	2	1	0	3	221212	8 	2006-02-16	174	1300000	68307	1	51	0.00	1.00	2007-02-15	0
159	1	63551140	ELIZABETH DAVILA CAS	\N	\N	\N	\N	\N	2 	2 	63551140    	ELIZABETH DAVILA CASTAÑO                	17	3	1983-10-04	1	APT 402 SECTOR 9 TORRE13-11 BUCARICA	6497866	68001	1	1	0	2	32323	8 	2006-02-13	175	433700	5411 	1	52	0.00	1.00	2006-06-12	0
160	1	63463080	ERNESTINA SERRANO MA	\N	\N	\N	\N	\N	4 	4 	63463080    	ERNESTINA SERRANO MARTINEZ              	17	3	1974-01-15	1	CRA 42 NO. 29-30 EL CERRO	6107637	68081	3	1	0	2	322311	8 	2010-09-23	176	515000	68081	1	52	0.00	1.00	2006-06-16	0
161	1	37576793	LELYS TATIANA ORTIZ 	\N	\N	\N	\N	\N	4 	4 	37576793    	LELYS TATIANA ORTIZ                     	17	3	1983-07-05	1	CLL 56 NO. 32-06	6112444	68081	1	1	0	2	123	8 	2006-02-17	177	433700	68081	1	52	0.00	1.00	2006-06-16	0
162	1	63468914	YOLIMA QUINTERO BOHO	\N	\N	\N	\N	\N	1 	1 	63468914    	YOLIMA QUINTERO BOHORQUEZ               	17	1	1976-08-01	1	DFJWHSAHFA	6105221	68081	2	1	0	2	2355232	5 	2006-12-11	200	496900	68081	1	52	0.00	1.00	2007-12-10	0
163	1	91521051	JHONATAN ADOLFO RAMI	\N	\N	\N	\N	\N	6 	6 	91521051    	JHONATAN ADOLFO RAMIREZ PATIÑO          	15	1	1983-07-25	2	JFGGJSD112	654113	68001	3	1	0	2	54135645	8 	2006-12-02	201	433700	68001	1	52	0.00	1.00	2007-12-01	0
164	1	91539129	MIGUEL OSWALDO  PALO	\N	\N	\N	\N	\N	8 	8 	91539129    	MIGUEL OSWALDO  PALOMINO RIVERA         	13	3	1985-03-16	2	hfashfjah	6486189	68001	2	1	0	5	45465465	8 	2007-01-13	205	650000	76111	1	52	0.00	1.00	2008-01-12	0
165	1	109618858	VLADIMIR ROJAS CONTR	\N	\N	\N	\N	\N	1 	1 	1096188581  	VLADIMIR ROJAS CONTRERAS                	15	3	1987-01-19	2	R EWKRWEHPTFG4WSºº	56464	68081	2	1	0	2	234114	8 	2007-02-05	213	461500	68001	1	52	0.00	1.00	2007-12-31	0
166	1	109619152	ANGIE MARIA ARDILA D	\N	\N	\N	\N	\N	4 	4 	1096191526  	ANGIE MARIA ARDILA DE LA ROCA           	17	1	1987-05-25	1	CRA 34 No 027 LA TORA	602249	68001	2	1	0	1	145645	8 	2007-02-17	217	433700	68001	1	52	0.00	1.00	2007-12-31	0
167	1	63549716	MARIA JASZMIN ARIAS 	\N	\N	\N	\N	\N	7 	7 	63549716    	MARIA JASZMIN ARIAS JAIMES              	17	1	1984-04-21	1	FKEAGMDN21541	5232532	68001	1	1	0	2	45653	8 	2006-12-02	202	461500	68001	1	52	0.00	1.00	2007-12-01	0
168	1	13721261	WALTER ALIRIO MEZA S	\N	\N	\N	\N	\N	5 	5 	13721261    	WALTER ALIRIO MEZA SUAREZ               	15	1	1978-10-13	2	SDFGDGBDFGFS	6447300	68001	2	1	2	4	42122	32	2006-09-13	193	433700	68001	1	52	0.00	1.00	2007-09-06	0
169	1	13852434	RAMIRO VARGAS MEJIA 	\N	\N	\N	\N	\N	1 	1 	13852434    	RAMIRO VARGAS MEJIA                     	15	3	2004-08-16	2	ADJADKLJA	6447300	68001	2	1	0	5	4564654	8 	2007-03-05	221	433700	68001	1	52	0.00	1.00	2008-03-08	0
170	1	49673581	ROSSANA NORIEGA RINC	\N	\N	\N	\N	\N	7 	7 	49673581    	ROSSANA NORIEGA RINCON                  	39	3	2004-05-10	1	aiojsIOJDOIjdo	6447300	68001	2	1	0	5	5465464	8 	2008-01-15	222	496900	68001	1	52	0.00	1.00	2008-03-04	0
171	1	63467719	FLOR ALBA GOMEZ     	\N	\N	\N	\N	\N	4 	4 	63467719    	FLOR ALBA GOMEZ                         	12	1	1975-11-03	1	CRA 11A No. 50-19 BUCARICA	6492726	68276	1	1	0	2	0	60	2004-03-23	82	3000000	68001	0	52	0.00	1.00	2005-03-15	0
172	1	109861962	GERSON ALBERTO SANCH	\N	\N	\N	\N	\N	6 	6 	1098619620  	GERSON ALBERTO SANCHEZ ROJAS            	15	3	1986-08-04	2	FLORIDA	6486189	68001	2	1	0	5	4564564	8 	2007-04-12	230	433700	68001	1	52	0.00	1.00	2008-04-11	0
173	1	63348401	ELVA  CARRILLO CARRI	\N	\N	\N	\N	\N	0 	0 	63348401    	ELVA  CARRILLO CARRILLO                 	29	1	1966-09-24	1	DKALDKALK	6447300	68001	2	1	0	5	5454	8 	2015-01-30	231	900000	68001	0	51	1.00	1.00	2008-04-01	0
174	1	109861682	JENNY ALEXA CARVAJAL	\N	\N	\N	\N	\N	2 	2 	1098616828  	JENNY ALEXA CARVAJAL FLOREZ             	17	3	1986-06-17	1	salkdlaskjdlk	6486189	68001	2	1	0	5	4545644	8 	2007-04-04	232	433700	68001	1	52	0.00	1.00	2008-04-02	0
175	1	28214958	MIREYA GOYENECHE UMA	\N	\N	\N	\N	\N	0 	0 	28214958    	MIREYA GOYENECHE UMAÑA                  	29	1	1981-04-01	1	DKLADKLAKD	6447300	68001	2	1	0	5	45465465	8 	2008-07-21	235	700000	68001	1	51	0.00	1.00	2008-05-02	0
176	1	13842089	JORGE ENRIQUE DELGAD	\N	\N	\N	\N	\N	0 	0 	13842089    	JORGE ENRIQUE DELGADO DUARTE            	29	1	1957-03-14	2	sdaskdakdlka	6447300	68001	2	1	0	5	132123123	8 	2015-02-03	236	6600000	68001	0	51	0.00	1.00	2008-05-01	0
177	1	110235481	MARDY LILIANA CAMACH	\N	\N	\N	\N	\N	2 	2 	1102354811  	MARDY LILIANA CAMACHO CAMACHO           	17	3	1988-01-20	1	DASD,ASDÑLAWK	6447300	68001	2	1	0	5	4545454	8 	2007-05-04	237	433700	68001	1	52	0.00	1.00	2008-05-04	0
178	1	109860550	EDINSON AQUILES SANT	\N	\N	\N	\N	\N	7 	7 	1098605503  	EDINSON AQUILES SANTIESTEBAN JIMENEZ    	15	3	1985-10-15	2	aldklakdl	6447300	68001	2	1	0	5	4564564	8 	2007-05-10	238	461500	68001	1	52	0.00	1.00	2008-05-10	0
179	1	109619492	TEODOLINDA PINILLA C	\N	\N	\N	\N	\N	1 	1 	1096194924  	TEODOLINDA PINILLA CESPEDES             	20	3	1988-04-09	1	ajdkajkdjakl	6447300	68001	2	1	0	5	456456465	8 	2007-05-21	241	1700000	68001	0	52	0.00	1.00	2008-05-20	0
180	1	37861494	ZAYRA SMITH BARRERA 	\N	\N	\N	\N	\N	3 	3 	37861494    	ZAYRA SMITH BARRERA RAMIREZ             	17	3	1981-06-23	1	kdkadklakdñl	6447300	68001	2	1	0	5	5465465465	8 	2007-05-17	242	461500	68001	1	52	0.00	1.00	2008-05-16	0
181	1	91110988	FABIAN AUGUSTO VARGA	\N	\N	\N	\N	\N	0 	0 	91110988    	FABIAN AUGUSTO VARGAS NIETO             	29	1	1981-08-12	2	NADJAJDKAJ	6447300	68001	2	1	0	5	4454	8 	2007-03-26	223	450000	68001	1	51	0.00	1.00	2008-03-25	0
182	1	28488891	LEONOR MARIA QUIÑONE	\N	\N	\N	\N	\N	4 	4 	28488891    	LEONOR MARIA QUIÑONEZ SERRANO           	17	3	1980-11-22	1	KDLAKDLAK	6447300	68001	2	1	0	5	4545465	8 	2007-03-29	224	461500	68001	1	52	0.00	1.00	2008-03-28	0
183	1	109860486	JESUS ALBERTO MARTIN	\N	\N	\N	\N	\N	6 	6 	1098604867  	JESUS ALBERTO MARTINEZ SERRANO          	15	3	1985-08-12	2	ALDLADK	6447300	68001	2	1	0	5	545454	8 	2007-03-28	225	433700	68001	1	52	0.00	1.00	2008-03-27	0
184	1	91508420	JAIME ENRIQUE HERNAN	\N	\N	\N	\N	\N	7 	7 	91508420    	JAIME ENRIQUE HERNANDEZ LUQUE           	15	3	1982-01-22	2	ALÑDLADKKA	6447300	68001	2	1	0	5	47564564	8 	2007-03-28	226	461500	68001	1	52	0.00	1.00	2008-03-27	0
185	1	110050229	LAURA MILENA CASTAÑE	\N	\N	\N	\N	\N	2 	2 	1100502291  	LAURA MILENA CASTAÑEDA PEÑALOZA         	40	3	1988-05-05	1	ADLALDLLA	6447300	68001	2	1	0	5	54564564	8 	2010-10-10	227	515000	68001	1	52	0.00	1.00	2007-03-21	0
186	1	109862805	YENNIFER XIOMARA RUE	\N	\N	\N	\N	\N	2 	2 	1098628055  	YENNIFER XIOMARA RUEDA GOMEZ            	17	3	1986-12-10	1	KLAJDKJAJD	6447300	68001	2	1	0	5	545454	8 	2007-03-20	228	433700	68001	1	52	0.00	1.00	2008-03-19	0
187	1	13540348	MARIO TORRES SUAREZ 	\N	\N	\N	\N	\N	4 	4 	13540348    	MARIO TORRES SUAREZ                     	15	3	1978-02-09	2	KALKLASDKLADK	6447300	68001	2	1	0	5	1445445	8 	2007-03-17	229	433700	68001	1	52	0.00	1.00	2008-03-16	0
188	1	13571135	ANDRES HUMBERTO RUED	\N	\N	\N	\N	\N	4 	4 	13571135    	ANDRES HUMBERTO RUEDA TOLOZA            	15	3	1985-11-20	2	KDALKDKAÑLDK	647300	68001	2	1	0	5	54544654654	8 	2007-05-16	243	433700	68001	1	52	0.00	1.00	2008-05-15	0
189	1	13569984	CESAR AUGUSTO BARBOS	\N	\N	\N	\N	\N	4 	4 	13569984    	CESAR AUGUSTO BARBOSA PINEDA            	15	3	1984-11-01	2	ALDKLAKDK	6447300	68001	2	1	0	5	5454556	8 	2007-05-16	244	496900	68001	1	52	0.00	1.00	2008-05-15	0
190	1	109619637	ANDREA MARCELA AVILA	\N	\N	\N	\N	\N	1 	1 	1096196379  	ANDREA MARCELA AVILA LONDOÑO            	17	3	1988-06-17	1	ADKMAKDKLAKD	6447300	68001	2	1	0	5	45454564	8 	2007-06-16	245	433700	68001	1	52	0.00	1.00	2007-06-16	0
191	1	13721826	ERICK GIOVANNY PUENT	\N	\N	\N	\N	\N	6 	6 	13721826    	ERICK GIOVANNY PUENTES CASTILLO         	13	3	1979-07-13	2	DAPODPAOD	6320505	68001	2	1	0	5	44546	8 	2007-06-19	246	650000	68001	1	52	0.00	1.00	2008-06-18	0
192	1	109860963	VICTOR JULIO ARIAS J	\N	\N	\N	\N	\N	3 	3 	1098609635  	VICTOR JULIO ARIAS JAIMES               	15	3	1986-03-01	2	ASDJASJDK	6486189	68001	2	1	0	5	454654654	8 	2007-06-16	247	496900	68001	1	52	0.00	1.00	2008-06-18	0
193	1	63541032	GLORIA JOHANNA PEDRA	\N	\N	\N	\N	\N	2 	2 	63541032    	GLORIA JOHANNA PEDRAZA SIZA             	17	3	1983-07-24	1	DJJMAKDLAK	6320505	19110	2	1	0	5	46546546	8 	2007-07-06	248	433700	68001	1	52	0.00	1.00	2008-07-01	0
194	1	43974768	SILVIA SANDOVAL MEJI	\N	\N	\N	\N	\N	4 	4 	43974768    	SILVIA SANDOVAL MEJIA                   	17	3	1984-06-18	1	ADJKLJDAJD	6203547	68081	1	1	0	5	4654455	8 	2011-07-02	249	566700	68081	1	52	1.00	1.00	2008-08-29	0
195	1	104221118	TATIANA  MARCELA ROL	\N	\N	\N	\N	\N	4 	4 	1042211186  	TATIANA  MARCELA ROLON                  	17	3	1988-05-07	1	DAJKKDADJJKA	6203547	68081	2	1	0	5	44546546	8 	2007-08-30	250	461500	68081	1	52	0.00	1.00	2008-08-30	0
196	1	88234897	GILBERTO HERNANDEZ J	\N	\N	\N	\N	\N	1 	1 	88234897    	GILBERTO HERNANDEZ JARAMILLO            	15	3	1978-06-06	2	ADJAKSDJAJKD	6224514	68001	2	1	0	5	465465465	8 	2007-08-28	251	461500	68001	1	52	0.00	1.00	2008-08-28	0
197	1	91269992	PEDRO JESUS RAMIREZ 	\N	\N	\N	\N	\N	0 	0 	91269992    	PEDRO JESUS RAMIREZ ROJAS               	29	1	1970-02-01	2	DADKADK	6447300	68001	2	1	0	5	4654646	8 	2007-09-11	252	700000	68001	1	51	0.00	1.00	2008-05-10	0
198	1	63563608	KARENT YILLIANA GARC	\N	\N	\N	\N	\N	0 	0 	63563608    	KARENT YILLIANA GARCIA SALCEDO          	29	1	1985-06-03	1	DFKSLGNFf	6446577	68001	1	1	0	5	44653465	8 	2008-01-02	208	680000	68001	1	51	0.00	1.00	2008-06-29	0
199	1	37547190	OLGA MARIA ARIZA TRI	\N	\N	\N	\N	\N	5 	5 	37547190    	OLGA MARIA ARIZA TRIANA                 	17	3	1977-08-20	1	EWÑTFLWçkñ	6565	68001	1	1	0	2	144633	8 	2007-01-20	209	433700	68001	1	52	0.00	1.00	2007-04-19	0
200	1	91510135	ROGELIO OSPINO GUEVA	\N	\N	\N	\N	\N	4 	4 	91510135    	ROGELIO OSPINO GUEVARA                  	15	3	1981-11-08	2	FDSFHGFJH	54511	68081	1	1	0	1	234632	8 	2009-01-26	210	433700	68081	1	52	0.00	1.00	2007-04-25	0
201	1	91487698	MARIO ALFREDO MACIAS	\N	\N	\N	\N	\N	0 	0 	91487698    	MARIO ALFREDO MACIAS SARMIENTO          	29	1	1976-01-20	2	BGR .H-GFMHRÇDGR	55433	68001	2	1	0	5	16546523	8 	2007-01-25	211	5638100	68001	1	51	0.00	1.00	2007-12-31	0
202	1	63502693	ELSA TATIANA CASTELL	\N	\N	\N	\N	\N	0 	0 	63502693    	ELSA TATIANA CASTELLANOS LASSO          	29	1	1975-04-30	1	CALLE 10 No 34-15 T2 APT 404 LOS PINOS	6361752	68001	2	2	0	4	265445441	8 	2007-01-18	182	1200000	68001	1	51	0.00	1.00	2007-05-01	0
203	1	91161913	JONATHAN FERNANDO LI	\N	\N	\N	\N	\N	2 	2 	91161913    	JONATHAN FERNANDO LINARES ROA           	15	3	1985-09-09	2	ADKASLDKALK	64861898	68001	2	1	0	5	454654	8 	2007-04-28	233	461500	68001	1	52	0.00	1.00	2008-04-27	0
204	1	91182799	REYNALDO ROJAS VELAS	\N	\N	\N	\N	\N	5 	5 	91182799    	REYNALDO ROJAS VELASCO                  	31	3	1980-09-13	2	DALDKAKD	45465464	68001	2	1	0	5	4564654	8 	2007-04-16	234	750000	68001	1	52	0.00	1.00	2008-04-16	0
205	1	91429223	DEOGRACIAS D J HERRE	\N	\N	\N	\N	\N	1 	1 	91429223    	DEOGRACIAS D J HERRERA NIÑO             	15	1	1966-09-01	2	CLL 55 No 35A-23 BARRANCA	6227603	68081	1	1	0	2	0	60	2004-07-21	19	535600	68081	1	52	0.00	1.00	2004-12-31	0
206	1	91449287	ELIECER LUNA SOLORZA	\N	\N	\N	\N	\N	4 	4 	91449287    	ELIECER LUNA SOLORZANO                  	15	1	1978-07-25	2	JDHJFDHSKDJHDLAKF	3565322	68081	2	1	0	4	4541546	8 	2006-10-03	196	461500	68081	1	52	0.00	1.00	2007-02-02	0
207	1	109579284	GERMAN ALFONSO TARAZ	\N	\N	\N	\N	\N	6 	6 	1095792840  	GERMAN ALFONSO TARAZONA DURAN           	15	1	1987-07-25	2	DFH SD SJ	644541	68001	1	1	0	2	415233	8 	2006-10-04	197	433700	68001	1	52	0.00	1.00	2007-02-03	0
208	1	63494018	DORIS REY ENCISO    	\N	\N	\N	\N	\N	2 	2 	63494018    	DORIS REY ENCISO                        	19	3	1973-10-12	1	asdjkajdajd	6486189	68001	2	1	0	5	545646546	8 	2007-10-18	254	1250000	68001	1	52	0.00	1.00	2008-10-17	0
209	1	37722937	PAOLA ANDREA FERRER 	\N	\N	\N	\N	\N	0 	0 	37722937    	PAOLA ANDREA FERRER FIGUEROA            	29	1	1979-01-19	1	JKAJFAJFLAF	6320505	68001	1	1	0	5	4546	8 	2007-12-12	255	2080000	68001	1	51	0.00	1.00	2008-12-10	0
210	1	109618707	AURORA TRASLAVIÑA SA	\N	\N	\N	\N	\N	1 	1 	1096187075  	AURORA TRASLAVIÑA SANDOVAL              	17	3	1986-07-28	1	ADADLADKOPAD	62245114	68081	2	1	0	5	454645	8 	2007-12-08	256	496900	68001	1	52	0.00	1.00	2008-12-10	0
211	1	13854733	JOSE LUIS VESGA SANC	\N	\N	\N	\N	\N	4 	4 	13854733    	JOSE LUIS VESGA SANCHEZ                 	15	3	1981-04-03	2	ADKAPDKPAKD	6224514	68001	2	1	0	5	4654654	8 	2007-12-04	257	461500	68001	1	52	0.00	1.00	2007-12-04	0
212	1	63530521	YENNY KATERINE PAIPA	\N	\N	\N	\N	\N	2 	2 	63530521    	YENNY KATERINE PAIPA SARMIENTO          	17	3	1982-03-08	1	JDKAJDKJAKDJ	6203547	68001	2	1	0	5	45465465	65	2008-01-22	258	461500	68001	1	52	0.00	1.00	2009-01-23	0
213	1	110234828	VIVIANA CRISTINA MAR	\N	\N	\N	\N	\N	2 	2 	1102348286  	VIVIANA CRISTINA MARIN MARTINEZ         	17	3	1985-10-26	1	AODAKDJAKD	6320505	68001	2	1	0	5	4654654	8 	2010-12-14	259	535600	68001	1	52	0.00	1.00	2009-02-01	0
214	1	91523634	EDINSON QUINTERO GOM	\N	\N	\N	\N	\N	7 	7 	91523634    	EDINSON QUINTERO GOMEZ                  	33	3	1983-09-03	2	jdkajdajd	6487819	68001	2	1	0	5	121211	8 	2010-08-27	260	515000	68001	1	52	0.00	1.00	2009-02-01	0
215	1	13852970	DIRSEU CADENA MARMOL	\N	\N	\N	\N	\N	1 	1 	13852970    	DIRSEU CADENA MARMOL                    	15	3	1980-06-14	2	dadjahd	4464654	68001	2	1	0	5	4545465	8 	2008-02-09	261	496900	68001	1	52	0.00	1.00	2009-02-09	0
216	1	63550998	KAROL VIVIANA ROA FL	\N	\N	\N	\N	\N	0 	0 	63550998    	KAROL VIVIANA ROA FLOREZ                	29	1	1984-03-21	1	dkalkdadk	6447300	68001	2	1	0	5	44454545	8 	2008-02-02	262	680000	68001	1	51	0.00	1.00	2009-02-02	0
217	1	91022439	JACOB ROA ROJAS     	\N	\N	\N	\N	\N	0 	0 	91022439    	JACOB ROA ROJAS                         	29	1	1962-08-13	2	adlñadkadk	6447300	68001	2	1	0	5	4545465	8 	2015-01-08	263	2200000	68001	0	51	0.00	1.00	2009-02-01	0
218	1	109864503	YULEIMA ORTEGA RAMIR	\N	\N	\N	\N	\N	3 	3 	1098645039  	YULEIMA ORTEGA RAMIREZ                  	17	3	1987-11-16	1	dadjajdjad	673000	68001	2	1	0	5	45464654	8 	2008-07-03	264	496900	68001	1	52	0.00	1.00	2008-02-01	0
219	1	28352692	BELKY YURLEY MALDONA	\N	\N	\N	\N	\N	7 	7 	28352692    	BELKY YURLEY MALDONADO PICO             	17	3	1982-06-19	1	hadjadkjadjkla	6447300	68001	2	1	0	5	545646546	8 	2010-09-11	265	535600	68001	1	52	0.00	1.00	2009-02-01	0
220	1	109936470	YURLEY GARAVITO GUAL	\N	\N	\N	\N	\N	3 	3 	1099364700  	YURLEY GARAVITO GUALDRON                	16	3	1981-02-13	1	AJDKFJAKAFJ	6447300	68001	2	1	0	5	454654654	8 	2008-02-01	266	496900	68001	1	52	0.00	1.00	2009-02-01	0
221	1	109864697	MARLY NAYDU AGARITA 	\N	\N	\N	\N	\N	0 	0 	1098646979  	MARLY NAYDU AGARITA VILLAMIZAR          	29	1	1987-12-21	1	adjadkjajdjad	645465465	68001	2	1	0	5	45465465	8 	2008-03-25	281	650000	68001	1	51	0.00	1.00	2009-03-25	0
222	1	91445814	MARIO MARTINEZ MENDO	\N	\N	\N	\N	\N	1 	1 	91445814    	MARIO MARTINEZ MENDOZA                  	15	3	1976-07-29	1	FSFSFSF	44456654	68001	2	1	0	5	546546546	8 	2008-03-19	282	532500	68001	1	52	0.00	1.00	2009-03-19	0
223	1	109619311	MARIA ANGELICA PERDO	\N	\N	\N	\N	\N	4 	4 	1096193114  	MARIA ANGELICA PERDOMO SANCHEZ          	17	3	1987-12-16	1	DADKALKDLAK	56654654654	68001	2	1	0	5	454654	8 	2008-04-12	283	461500	68001	1	52	0.00	1.00	2009-04-13	0
224	1	109866661	JHON JAIRO ESPINOSA 	\N	\N	\N	\N	\N	9 	9 	1098666619  	JHON JAIRO ESPINOSA OSORIO              	15	3	2004-05-10	1	KRLAKRQKRQ	4546465465	68001	2	1	0	5	465465465	8 	2009-05-01	284	535600	68001	1	52	0.00	1.00	2010-05-01	0
225	1	109618706	YEIMYS FLOREZ SERRAN	\N	\N	\N	\N	\N	1 	1 	1096187060  	YEIMYS FLOREZ SERRANO                   	17	3	2004-05-10	1	KLJKLJJ	465464465	68001	2	1	0	5	445445458	8 	2011-01-22	285	535600	68001	1	52	0.00	1.00	2011-07-06	0
226	1	91296412	JUAN CARLOS SANABRIA	\N	\N	\N	\N	\N	7 	7 	91296412    	JUAN CARLOS SANABRIA HERRERA            	20	3	2004-05-10	1	AKLJFKLAJFKLJ	454654564	68001	2	1	0	5	54654564	65	2008-04-02	286	1248000	68001	1	52	0.00	1.00	2009-04-02	0
227	1	109866139	PAOLA ANDREA LOZANO 	\N	\N	\N	\N	\N	0 	0 	1098661394  	PAOLA ANDREA LOZANO SOLANO              	29	1	1985-05-10	1	LÑKDLAKDKLÑ	64654646	68001	2	1	0	5	46465465	8 	2008-05-14	288	700000	68001	1	51	0.00	1.00	2009-05-12	0
228	1	13570926	RICHARD ALFONSO TAND	\N	\N	\N	\N	\N	1 	1 	13570926    	RICHARD ALFONSO TANDAZO                 	15	3	1985-05-02	2	AÑLDLALLD	64654645	68001	2	1	0	5	151321	8 	2008-05-10	289	461500	68001	1	52	0.00	1.00	2009-05-09	0
229	1	109864815	SAMUEL ANDRES GUERRE	\N	\N	\N	\N	\N	5 	5 	1098648154  	SAMUEL ANDRES GUERRERO VEGA             	15	3	1981-05-01	2	DMKLADLJAD	556465465	68001	2	1	0	5	465465465	8 	2008-05-02	290	461500	68001	1	52	0.00	1.00	2009-05-01	0
230	1	37576025	YENNY ECHEVERRY HERR	\N	\N	\N	\N	\N	1 	1 	37576025    	YENNY ECHEVERRY HERRERA                 	17	3	1982-05-01	1	DADADAD	5465654	68001	2	1	0	5	5646654	8 	2008-05-09	291	461500	68001	1	52	0.00	1.00	2009-05-09	0
231	1	91542641	OSCAR JAVIER AYALA P	\N	\N	\N	\N	\N	4 	4 	91542641    	OSCAR JAVIER AYALA PLATA                	15	3	1985-08-29	2	DADJAKJD	52554	68001	2	1	0	5	46544456	8 	2008-05-03	292	496900	68001	1	52	0.00	1.00	2009-05-02	0
232	1	109619268	MIGUEL ANGEL HERNAND	\N	\N	\N	\N	\N	4 	4 	1096192688  	MIGUEL ANGEL HERNANDEZ VILLAREAL        	15	3	1985-02-14	2	COLOMBIA	54654654	68001	2	1	0	5	4654654	8 	2008-05-24	293	461500	68001	1	52	0.00	1.00	2009-05-23	0
233	1	109862398	LUIS ALEXANDER MOLIN	\N	\N	\N	\N	\N	2 	2 	1098623981  	LUIS ALEXANDER MOLINA BETANCOURT        	15	3	2004-05-10	2	CRA 8 NO 21-26	6486189	68001	1	3	0	2	65456	96	2008-10-31	294	515000	68001	1	52	0.00	1.00	2010-05-10	0
234	1	103749916	LEIDY CRISTINA GOMEZ	\N	\N	\N	\N	\N	4 	4 	1037499167  	LEIDY CRISTINA GOMEZ SALAZAR            	17	3	1987-11-26	1	sfjksfklsfjsf	6447300	68001	2	1	0	5	454564654	8 	2008-02-01	267	496900	68001	1	52	0.00	1.00	2009-02-01	0
235	1	37728316	ANA MILENA GUARIN BU	\N	\N	\N	\N	\N	3 	3 	37728316    	ANA MILENA GUARIN BUENO                 	16	3	2004-05-10	1	CRA PTE 13-14 BUCARCIAA	6496727	68001	1	1	0	2	54543	40	2008-06-01	295	535600	68001	1	52	0.00	1.00	2010-05-10	0
236	1	109620136	AURA TATIANA DUEÑEZ 	\N	\N	\N	\N	\N	1 	1 	1096201367  	AURA TATIANA DUEÑEZ OLIVERO             	17	3	1989-08-05	1	JADKAJDKJAKDJ	6203547	68001	2	1	0	5	4654564564	8 	2011-04-09	268	535600	68001	1	52	0.00	1.00	2009-02-01	0
237	1	63523720	CARMEN ELISA CARREÑO	\N	\N	\N	\N	\N	2 	2 	63523720    	CARMEN ELISA CARREÑO RIVERA             	17	3	1981-11-18	1	ASJDKAJDKJADKJ	6203527	68001	2	1	0	5	4654645	8 	2008-02-01	269	515000	68001	1	52	0.00	1.00	2009-02-01	0
238	1	109579577	MANUEL FERNANDO CESP	\N	\N	\N	\N	\N	2 	2 	1095795771  	MANUEL FERNANDO CESPEDES PINZON         	15	3	2004-05-10	2	DAKDJKADJKJD	6447100	68001	2	1	0	5	4545546544	8 	2008-02-01	270	461500	68001	1	52	0.00	1.00	2009-02-01	0
239	1	109579719	DANIELA MERCEDES RIN	\N	\N	\N	\N	\N	9 	9 	1095797192  	DANIELA MERCEDES RINCON GALLARDO        	13	3	1988-08-04	1	adakdakdkad	64473000	68001	2	1	0	5	465456454	8 	2010-11-19	271	900000	68001	1	52	1.00	1.00	2009-02-01	0
240	1	13850296	LUIS ALBEIRO LOPEZ P	\N	\N	\N	\N	\N	5 	5 	13850296    	LUIS ALBEIRO LOPEZ PULIDO               	15	3	1978-07-15	1	NHADAJDJAKL	645465465	68001	2	1	0	5	46545454	8 	2008-02-01	272	496900	68001	1	52	0.00	1.00	2009-02-01	0
241	1	91354968	LUIS EDUARDO ESPINOZ	\N	\N	\N	\N	\N	7 	7 	91354968    	LUIS EDUARDO ESPINOZA JAIMES            	15	3	2004-05-10	2	DADKLAJDKLAJDKJ	6447300	68001	2	1	0	5	45456464	8 	2008-02-01	273	461500	68001	1	52	0.00	1.00	2009-02-01	0
242	1	109592004	GREILY XIOMARA BLANC	\N	\N	\N	\N	\N	3 	3 	1095920049  	GREILY XIOMARA BLANCO SANCHEZ           	17	3	2004-05-10	1	SFHJGFHGJ	4543213	68001	1	1	0	2	54535	5 	2008-06-01	296	496900	68001	1	52	0.00	1.00	2010-05-10	0
243	1	63558817	LAURA LIZETH GONZALE	\N	\N	\N	\N	\N	2 	2 	63558817    	LAURA LIZETH GONZALEZ ESTUPIÑAN         	17	3	2004-05-10	1	gkdjhhçxdz	6542	68001	1	1	0	2	42521	40	2008-06-01	297	461500	68001	1	52	0.00	1.00	2010-05-10	0
244	1	63554843	SANDRA LUCIA HERNAND	\N	\N	\N	\N	\N	5 	5 	63554843    	SANDRA LUCIA HERNANDEZ                  	17	3	2004-05-10	1	´lddf	654655	68001	2	1	0	5	1232	40	2006-06-01	298	461500	68001	1	52	0.00	1.00	2010-05-10	0
245	1	37513676	YADITH ROCIO CASTRO 	\N	\N	\N	\N	\N	7 	7 	37513676    	YADITH ROCIO CASTRO MACIAS              	17	3	2004-05-10	1	dadafry	6544565	68001	1	1	0	2	14312	40	2008-06-01	299	461500	68001	1	52	0.00	1.00	2010-05-10	0
246	1	109862424	YULY ANDREA AVILA CA	\N	\N	\N	\N	\N	2 	2 	1098624241  	YULY ANDREA AVILA CASTRO                	17	3	2004-05-10	1	gdtffvkñt,gpe	655652	68001	1	1	0	2	15342132	40	2008-06-01	300	461500	68001	1	52	0.00	1.00	2010-05-10	0
247	1	13278801	OMAR FERNANDO FUENTE	\N	\N	\N	\N	\N	5 	5 	13278801    	OMAR FERNANDO FUENTES ORDOÑEZ           	15	3	2004-05-10	1	mmsklg nfjhgmrtñd	445441	68001	1	1	0	2	454	40	2008-06-01	301	461500	68001	1	52	0.00	1.00	2010-06-01	0
248	1	109591695	NIDIA RUBIELA AGUILA	\N	\N	\N	\N	\N	8 	8 	1095916950  	NIDIA RUBIELA AGUILAR REMOLINA          	16	3	2004-05-10	1	jijgp`ldhpkgfh	652145653	68001	1	1	0	1	1435413	25	2008-06-01	302	515000	68001	1	52	0.00	1.00	2010-05-10	0
249	1	106586481	YERIS GUEVARA LEMUS 	\N	\N	\N	\N	\N	0 	0 	1065864812  	YERIS GUEVARA LEMUS                     	29	1	1986-06-09	1	ADKAODKPAKD	6546546	68001	2	1	0	5	46546546	8 	2010-06-01	287	1400000	68001	0	51	0.00	1.00	2008-12-30	0
250	1	109864697	MAYERLY MARTINEZ VAR	\N	\N	\N	\N	\N	0 	0 	1098646975  	MAYERLY MARTINEZ VARGAS                 	29	1	1986-12-01	1	tgeyrtyrtu	556463	68001	2	1	0	5	56453	8 	2010-02-01	425	680000	68001	1	51	0.00	1.00	2011-01-31	0
251	1	91288033	ALDEMAR MONTAÑO OCHO	\N	\N	\N	\N	\N	0 	0 	91288033    	ALDEMAR MONTAÑO OCHOA                   	29	3	1976-12-11	2	asdfsdghfgjh	24534	68001	1	1	0	5	4534	8 	2010-02-01	426	1200000	68001	1	52	0.00	1.00	2011-01-31	0
252	1	63354755	FLOR EDDY CARRILLO C	\N	\N	\N	\N	\N	0 	0 	63354755    	FLOR EDDY CARRILLO CARRILLO             	29	1	1970-07-12	1	tetleryu	1456413	68001	2	1	0	5	2634654	8 	2010-02-01	427	770000	68001	0	51	1.00	1.00	2011-01-21	0
253	1	109576619	DENNYS FERNEY CADENA	\N	\N	\N	\N	\N	1 	1 	1095766197  	DENNYS FERNEY CADENA GARAVITO           	15	3	1987-12-01	2	weteryer	21313	68081	1	1	0	5	565463	8 	2010-03-02	428	515000	68081	1	52	0.00	1.00	2011-01-21	0
254	1	109860791	LEIDY LISETH SAAVEDR	\N	\N	\N	\N	\N	7 	7 	1098607918  	LEIDY LISETH SAAVEDRA CASALLAS          	17	3	1988-12-01	1	hgtrgyhry	1456356	68001	2	1	0	5	534635	8 	2010-02-06	429	515000	68001	1	52	0.00	1.00	2011-01-31	0
255	1	109619702	CYNTHIA JULIET ARRIE	\N	\N	\N	\N	\N	4 	4 	1096197023  	CYNTHIA JULIET ARRIETA PINTO            	17	3	1980-12-01	1	fsdtdry	3131	68081	2	1	0	5	26143	8 	2010-02-06	430	515000	68081	1	52	0.00	1.00	2011-01-31	0
256	1	37713241	MARISELA FUENTES VAL	\N	\N	\N	\N	\N	7 	7 	37713241    	MARISELA FUENTES VALVUENA               	21	3	2004-05-10	1	cdjfisdfgd	453	68001	2	1	0	5	456436	8 	2011-07-03	431	1248000	68001	1	52	0.00	1.00	2011-01-31	0
257	1	110236755	BLADIMIR ANDRES ARIA	\N	\N	\N	\N	\N	8 	8 	1102367551  	BLADIMIR ANDRES ARIAS RAMIREZ           	15	3	1991-10-08	2	lofhefQ<ERUUKY7LO	456354	68001	2	1	0	5	53543	8 	2012-02-10	432	566700	68001	1	52	1.00	1.00	2011-01-31	0
258	1	63544170	LEIDY JOHANNA SANABR	\N	\N	\N	\N	\N	3 	3 	63544170    	LEIDY JOHANNA SANABRIA DIAZ             	17	3	1986-12-01	1	TREWTLETKE	6356543	68001	2	1	0	5	4346354	8 	2010-02-12	433	535600	68001	1	52	0.00	1.00	2011-01-31	0
259	1	91510137	ALEX ORLANDO MADRIGA	\N	\N	\N	\N	\N	2 	2 	91510137    	ALEX ORLANDO MADRIGAL PINZON            	20	3	1985-12-01	2	CSDLÑFLÑSDKGLDH	5346465	68001	2	1	0	5	3113205621	8 	2010-04-22	448	800000	68001	1	52	0.00	1.00	2011-04-01	0
260	1	109828619	ADRIANO FERNANDO VAL	\N	\N	\N	\N	\N	2 	2 	1098286190  	ADRIANO FERNANDO VALBUENA OCHOA         	33	3	1988-03-30	2	DSFHKDSHFJKSDD	54565465463	68001	2	1	0	5	565463	8 	2010-04-16	449	1050000	68001	0	52	1.00	1.00	2011-04-15	0
261	1	91473187	WALTHER ALFONSO CELI	\N	\N	\N	\N	\N	2 	2 	91473187    	WALTHER ALFONSO CELIS GOMEZ             	15	3	1985-12-01	2	CRA 8 No 3-61	6486189	68001	2	1	0	5	45242056	8 	2010-05-11	450	535600	68001	1	52	0.00	1.00	2011-05-10	0
262	1	109579444	JHON JAIRO RINCON LI	\N	\N	\N	\N	\N	8 	8 	1095794443  	JHON JAIRO RINCON LIZARAZO              	15	3	1988-01-09	2	CRA 8 3-61	6486189	68001	3	1	3	2	14546	8 	2010-05-07	451	515000	68001	1	52	0.00	1.00	2011-05-07	0
263	1	63508971	ADRIANA PATRICIA BAC	\N	\N	\N	\N	\N	0 	0 	63508971    	ADRIANA PATRICIA BACCA RIVERA           	29	1	1975-12-23	1	CALLE 70 44W-156 KM 4 VIA GIRON	6370099	68001	2	1	1	5	4646	8 	2010-05-07	452	1800000	68001	1	51	0.00	1.00	2011-05-07	0
264	1	63553794	LAURA MILENA DIAZ SA	\N	\N	\N	\N	\N	7 	7 	63553794    	LAURA MILENA DIAZ SARMIENTO             	16	3	1983-07-28	1	CRA 27 21-26	6350333	68001	1	5	1	2	53467	8 	2010-05-07	453	840000	68001	0	52	1.00	1.00	2011-05-07	0
265	1	109865678	MARY LUZ CARREÑO GON	\N	\N	\N	\N	\N	3 	3 	1098656787  	MARY LUZ CARREÑO GONZALEZ               	17	3	1988-06-27	1	CRA 23 No 14-40	6320505	68001	2	1	0	5	5434163	8 	2010-05-15	454	515000	68001	1	52	0.00	1.00	2011-05-10	0
266	1	112186037	MONICA PATRICIA BERN	\N	\N	\N	\N	\N	4 	4 	1121860373  	MONICA PATRICIA BERNAL PEÑUELA          	17	3	1990-01-12	1	cra 35 47-75	6218618	68081	1	5	0	2	468456456	8 	2010-06-01	462	515000	68081	1	52	0.00	1.00	2011-06-01	0
267	1	109860893	NATALY ESMERAL AMAYA	\N	\N	\N	\N	\N	0 	0 	1098608933  	NATALY ESMERAL AMAYA                    	29	1	1986-01-22	1	CALLE 27 6-31 LAGOS 3	6849275	68001	3	5	1	3	144545386	8 	2010-06-16	464	860000	68001	1	51	1.00	1.00	2011-06-16	0
268	1	111749919	YURY MILDRED MARTINE	\N	\N	\N	\N	\N	8 	8 	1117499195  	YURY MILDRED MARTINEZ MUÑOZ             	17	3	1988-12-01	1	xzcdgvfdhf	41241	68001	2	1	0	5	22323	8 	2010-02-16	434	515000	68001	1	52	0.00	1.00	2011-02-14	0
269	1	109861915	LEIDYZ JENIFER RUEDA	\N	\N	\N	\N	\N	2 	2 	1098619151  	LEIDYZ JENIFER RUEDA FIGUEROA           	17	3	1989-12-01	1	ASDSFDFHHJK	563543	68001	2	1	0	5	4314136	8 	2010-02-16	435	515000	68001	1	52	0.00	1.00	2011-02-14	0
270	1	28070408	LUZ ENITH CASTRO OSO	\N	\N	\N	\N	\N	1 	1 	28070408    	LUZ ENITH CASTRO OSORIO                 	17	3	1981-09-30	1	DF´GLFÑGKHRF HG	45246351	68001	2	1	0	5	123121	8 	2012-07-03	436	680000	68001	1	52	1.00	1.00	2011-02-15	0
271	1	109619467	DAISSON TORRES SALGU	\N	\N	\N	\N	\N	4 	4 	1096194676  	DAISSON TORRES SALGUERO                 	37	3	1987-08-18	2	CALLE 49 54-14  VILLARELIS II	3138121619	68081	1	5	0	2	5451454154	8 	2010-06-23	465	535600	68081	1	52	0.00	1.00	2011-06-22	0
272	1	107523231	KERLY JOHANNA CAICED	\N	\N	\N	\N	\N	1 	1 	1075232315  	KERLY JOHANNA CAICEDO CORDOBA           	17	3	1988-02-01	1	CALLE 46 36B-104  TAMARINDOS CLUB	3143433665	68081	3	5	1	2	2453454544	8 	2010-10-05	475	515000	68081	1	52	0.00	1.00	2011-10-04	0
273	1	63341171	LIGIA JUDITH GOMEZ Z	\N	\N	\N	\N	\N	0 	0 	63341171    	LIGIA JUDITH GOMEZ ZAMBRANO             	29	1	1968-04-09	1	CARRERA 30 # 16-61 PISO 2	6342389	68001	1	2	0	4	1256	8 	2010-10-12	476	900000	68001	1	51	0.00	1.00	2010-10-11	0
274	1	109620892	KELLY JOHANNA NOEL C	\N	\N	\N	\N	\N	4 	4 	1096208924  	KELLY JOHANNA NOEL CARBALLO             	17	3	2004-05-10	1	CRA 19 # 49-37	6370099	68081	2	1	0	2	2356	8 	2011-02-17	477	535600	68081	1	52	0.00	1.00	2011-10-13	0
275	1	109578931	MARISOL JAIMES VELAN	\N	\N	\N	\N	\N	7 	7 	1095789311  	MARISOL JAIMES VELANDIA                 	39	3	1986-08-05	1	CRA 9AE  29A-27	6581332	68276	1	2	0	3	23659	8 	2010-10-26	480	515000	68001	1	52	0.00	1.00	2011-10-25	0
276	1	91533147	HERNAN MAURICIO MORA	\N	\N	\N	\N	\N	2 	2 	91533147    	HERNAN MAURICIO MORALES CUELLAR         	15	3	1984-09-05	2	CALLE 23C  1W-37 PORTAL DEL VALLE	6346243	68547	1	5	0	2	23569	8 	2012-11-16	487	566700	50001	1	52	1.00	1.00	2011-11-21	0
277	1	109872687	JOHAN NICOLAS ORTIZ 	\N	\N	\N	\N	\N	9 	9 	1098726878  	JOHAN NICOLAS ORTIZ ORTIZ               	15	3	1992-09-13	2	CALLE 61A  2W-66 MUTIS	6449219	68001	1	5	0	2	23569	8 	2013-05-09	488	680000	68001	1	52	1.00	1.00	2011-11-21	0
278	1	109579911	MARCELA MARGARITA PI	\N	\N	\N	\N	\N	2 	2 	1095799119  	MARCELA MARGARITA PICO ALVAREZ          	17	3	1988-12-21	1	SECTOR 20 APTO 211 BUCARICA	6483866	68276	1	2	0	2	6825365	8 	2010-12-05	489	535600	47001	1	52	0.00	1.00	2011-12-05	0
279	1	91539981	JOVANY ALBERTO PALOM	\N	\N	\N	\N	\N	7 	7 	91539981    	JOVANY ALBERTO PALOMINO                 	15	3	1985-03-10	2	CALLE 5  16-25 COMUNEROS	6719408	68001	1	5	0	2	236598	8 	2010-12-06	490	680000	68001	1	52	1.00	1.00	2011-12-05	0
280	1	109591517	SANDRA LILINA RUEDA 	\N	\N	\N	\N	\N	9 	9 	1095915171  	SANDRA LILINA RUEDA BARRAGAN            	17	3	1988-10-20	1	CALLE 28  30-81 GIRON	6465338	68307	2	5	0	2	2536598	8 	2011-07-17	491	535600	68001	1	52	0.00	1.00	2011-12-05	0
281	1	91255772	JOSE DANIEL OSORIO I	\N	\N	\N	\N	\N	9 	9 	91255772    	JOSE DANIEL OSORIO IBARRA               	35	3	1967-09-16	2	TRANSV. 128  63-15 CIUDAD JARDIN	6771845	68276	2	5	0	2	2356985421	8 	2010-12-01	492	650000	54810	1	52	1.00	1.00	2011-11-30	0
282	1	63541210	ANDREA MILENA ACOSTA	\N	\N	\N	\N	\N	9 	9 	63541210    	ANDREA MILENA ACOSTA MERCHAN            	39	3	1983-08-07	1	CALLE 13  29-47 APTO 201 SAN ALONSO	6347124	68001	2	5	0	2	2536598	8 	2010-12-01	493	535600	68001	1	52	0.00	1.00	2011-11-30	0
283	1	109427005	XIOMARA PATRICIA CAR	\N	\N	\N	\N	\N	7 	7 	1094270056  	XIOMARA PATRICIA CARRILLO CAICEDO       	17	3	1992-12-25	1	CRA. 18 N° 22-23	3204287529	68001	1	5	0	3	2525	8 	2012-03-02	705	680000	54518	1	52	1.00	1.00	2013-03-01	0
284	1	91299871	FERNANDO FRANCISCO C	\N	\N	\N	\N	\N	0 	0 	91299871    	FERNANDO FRANCISCO COLMENARES TELLEZ    	29	1	1974-06-21	2	LAGOS V ETAPA TORRE 18 APTO 401	6370099	68276	2	1	0	4	23659	8 	2010-11-08	484	0	8001 	1	51	0.00	1.00	2011-11-07	0
285	1	109591253	MERLY YURLEY LOPEZ P	\N	\N	\N	\N	\N	9 	9 	1095912535  	MERLY YURLEY LOPEZ PATIÑO               	17	3	1987-06-08	1	CRA 11  103E-75 MANUELA BELTRAN	6370792	68001	3	1	0	2	236598	8 	2011-08-18	481	535600	68001	1	52	0.00	1.00	2011-10-27	0
286	1	63357551	MARIA EUGENIA SUAREZ	\N	\N	\N	\N	\N	7 	7 	63357551    	MARIA EUGENIA SUAREZ MORENO             	41	3	1970-03-26	1	CALLE 61  3-91 SAMANES IV	6948708	68001	2	1	0	2	235698	8 	2010-12-06	494	535600	68169	1	52	0.00	1.00	2011-12-05	0
287	1	109868483	JOHNS DAYVER PALENCI	\N	\N	\N	\N	\N	9 	9 	1098684831  	JOHNS DAYVER PALENCIA HERNANDEZ         	14	3	1990-04-04	2	CALLE 1  25B-26 REGADEROS	3104762158	68001	3	5	0	2	236598	8 	2010-11-06	485	900000	68001	1	52	1.00	1.00	2011-11-07	0
288	1	109591877	FABIO FERNANDO GARZO	\N	\N	\N	\N	\N	7 	7 	1095918772  	FABIO FERNANDO GARZON ROMERO            	15	3	1989-07-26	2	CARRERA 20  11-88 SAN FRANCISCO	3185949695	68001	1	2	0	2	326598	8 	2010-11-06	486	566700	1001 	1	52	1.00	1.00	2011-11-05	0
289	1	91530766	OMAR AUGUSTO GARCIA 	\N	\N	\N	\N	\N	2 	2 	91530766    	OMAR AUGUSTO GARCIA GONZALEZ            	15	3	1984-07-14	2	CALLE 22  11B-31 LOS ROSALES	3153424512	68276	1	5	0	2	23569	8 	2010-12-01	495	535600	68001	1	52	0.00	1.00	2011-12-01	0
290	1	18496404	GABRIEL MARIO LOPEZ 	\N	\N	\N	\N	\N	0 	0 	18496404    	GABRIEL MARIO LOPEZ ESTRADA             	29	1	1973-05-13	2	DADLADKADKLAKD	6370099	68001	2	1	0	5	546544	8 	2008-07-22	304	5999500	68001	1	51	0.00	1.00	2008-07-21	0
291	1	13707732	JOSE OLMEDO BARRAGAN	\N	\N	\N	\N	\N	4 	4 	13707732    	JOSE OLMEDO BARRAGAN MOGOLLON           	15	3	1984-07-02	2	BARRANCA	6224514	68001	1	1	0	5	1545465	8 	2008-08-12	305	461500	68001	1	52	0.00	1.00	2008-05-12	0
292	1	28214988	DEINY TASCO GOMEZ   	\N	\N	\N	\N	\N	4 	4 	28214988    	DEINY TASCO GOMEZ                       	41	3	1981-05-04	1	BARRANCA	6224514	68001	2	1	0	5	4654654	8 	2009-10-06	306	515000	68001	1	52	0.00	1.00	2010-10-08	0
293	1	109580578	JUAN CARLOS MARTINEZ	\N	\N	\N	\N	\N	7 	7 	1095805783  	JUAN CARLOS MARTINEZ FIGUEROA           	14	3	1990-07-26	2	DKLADKLAKD	465456465	68001	2	1	0	5	45456456	8 	2008-06-18	307	800000	68001	1	52	0.00	1.00	2009-06-17	0
294	1	900726567	0                   	\N	\N	\N	\N	\N	0 	0 	90072656740 	0                                       	15	3	1992-04-10	2	LAKLAKDÑK	64565656	68001	2	1	0	5	4654654	8 	2008-06-18	303	461500	68001	1	52	0.00	1.00	2009-06-17	0
295	1	109591196	YEFERSON YESID GARCI	\N	\N	\N	\N	\N	4 	4 	1095911964  	YEFERSON YESID GARCIA AMOROCHO          	14	3	1987-11-04	2	LÑKLADKKLADJD	6203595	68001	2	1	0	5	454654654	8 	2008-09-01	308	770000	68001	0	52	1.00	1.00	2009-09-01	0
296	1	37578618	AIRELY RODRIGUEZ ORT	\N	\N	\N	\N	\N	4 	4 	37578618    	AIRELY RODRIGUEZ ORTIZ                  	16	3	1984-03-19	1	DADKALDK	87877878	68001	2	1	0	5	5454564	8 	2008-09-29	309	515000	68001	1	52	0.00	1.00	2009-09-28	0
297	1	109618934	RICHAR ALEXANDER ROJ	\N	\N	\N	\N	\N	1 	1 	1096189347  	RICHAR ALEXANDER ROJO HINCAPIE          	15	3	1985-12-11	2	ASDADAD	6224514	68001	2	1	0	5	446456456	8 	2008-09-26	310	496900	68001	1	52	0.00	1.00	2009-09-26	0
298	1	109591053	MARIA TERESA LUNA RI	\N	\N	\N	\N	\N	7 	7 	1095910534  	MARIA TERESA LUNA RINCON                	17	3	1987-05-19	1	DAHDJAHKDH	6350333	68001	2	1	0	5	46464	8 	2008-10-27	313	496900	68001	1	52	0.00	1.00	2009-10-26	0
299	1	63536113	IRINA PAOLA CARDENAS	\N	\N	\N	\N	\N	0 	0 	63536113    	IRINA PAOLA CARDENAS CACERES            	29	1	1982-11-15	1	CALLE 14B Nº 25-59 URB. 1o de MAYO GIRON	6590940	68001	2	1	0	5	456454	8 	2008-12-19	314	650000	68001	1	51	0.00	1.00	2009-12-19	0
300	1	109620651	LEONARDO FABIO GARRI	\N	\N	\N	\N	\N	1 	1 	1096206513  	LEONARDO FABIO GARRIDO BENAVIDES        	15	3	1990-07-16	2	COLOMBIA	6203597	68001	2	1	0	5	4545646	8 	2008-12-20	315	532500	68001	1	52	0.00	1.00	2009-12-31	0
301	1	91219738	CESAR MAURICIO PEDRO	\N	\N	\N	\N	\N	0 	0 	91219738    	CESAR MAURICIO PEDROZA VARGAS           	29	1	1962-06-30	2	CRA 8 Nº 3-61	6370099	68001	2	1	0	5	454564444	8 	2009-01-28	318	3640000	68001	1	51	0.00	1.00	2010-01-28	0
302	1	72241681	ESNEIDER JOSE BONILL	\N	\N	\N	\N	\N	1 	1 	72241681    	ESNEIDER JOSE BONILLA BARBOSA           	15	3	1979-04-04	2	ADJAKLDJAKJD	6224514	68001	2	1	0	5	454564	8 	2009-01-27	319	496900	68001	1	52	0.00	1.00	2009-01-26	0
303	1	109620232	MARIA YESENIA DIAZ S	\N	\N	\N	\N	\N	1 	1 	1096202324  	MARIA YESENIA DIAZ SERRANO              	16	3	1989-09-26	1	JDAJDKJ	6224514	68001	2	1	0	5	54564564	8 	2009-01-24	320	1100000	68001	0	52	1.00	1.00	2010-09-24	0
304	1	37575929	TATIANA ALQUICHIRE C	\N	\N	\N	\N	\N	4 	4 	37575929    	TATIANA ALQUICHIRE CABALLERO            	39	3	1983-01-05	1	DADADA	6224514	68001	2	1	0	5	45456456	8 	2009-01-16	321	515000	68001	1	52	0.00	1.00	2010-01-16	0
305	1	77195390	FRAHENGLIS JOSE BOHO	\N	\N	\N	\N	\N	4 	4 	77195390    	FRAHENGLIS JOSE BOHORQUEZ RAMIREZ       	15	3	1979-02-02	2	BARRANCA	6224514	68001	2	1	0	5	464564	8 	2009-02-13	322	535600	68001	1	52	0.00	1.00	2010-02-13	0
903	1	109621683	ANGELA VILORIA OTERO	\N	\N	\N	\N	\N	4 	4 	1096216835  	ANGELA VILORIA OTERO                    	39	3	1992-07-19	1	1	1	68081	2	1	2	2	14523	8 	2013-11-16	983	680000	68081	0	52	1.00	1.00	2014-05-10	0
306	1	109620125	PAOLA ANDREA HERNAND	\N	\N	\N	\N	\N	1 	1 	1096201253  	PAOLA ANDREA HERNANDEZ GOMEZ            	17	3	1989-05-11	1	BARRNACA	6224514	68001	2	1	0	5	454564	8 	2009-02-12	323	496900	68001	1	52	0.00	1.00	2010-02-11	0
307	1	37580201	SHIRLEY TATIANA DURA	\N	\N	\N	\N	\N	4 	4 	37580201    	SHIRLEY TATIANA DURAN ARRIETA           	17	3	1984-12-05	1	BARRANCA	6224514	68001	2	1	0	5	454564	8 	2009-02-07	324	515000	68001	1	52	0.00	1.00	2010-02-06	0
308	1	109620140	JOHN JAVIER ROJAS FO	\N	\N	\N	\N	\N	1 	1 	1096201407  	JOHN JAVIER ROJAS FONSECA               	15	3	1989-08-17	2	COMERCIO	6224514	68001	2	1	0	5	4646465	8 	2009-02-18	325	496900	68001	1	52	0.00	1.00	2010-02-17	0
309	1	109862571	MIRYAM LEONOR CASTIL	\N	\N	\N	\N	\N	1 	1 	1098625711  	MIRYAM LEONOR CASTILLO LOPEZ            	17	3	1986-11-04	1	DAJDKLAJDL	6224514	68001	2	1	0	5	5454564	8 	2009-02-26	326	496900	68001	1	52	0.00	1.00	2010-02-25	0
310	1	109620325	IVETH YURANY ARDILA 	\N	\N	\N	\N	\N	1 	1 	1096203258  	IVETH YURANY ARDILA ROYERO              	17	3	2004-05-10	1	CRA 6 Nº 49-29	6224514	68001	2	1	0	5	454564	8 	2009-03-13	327	496900	68001	1	52	0.00	1.00	2010-03-12	0
311	1	109619443	INGRID PAOLA ZABALET	\N	\N	\N	\N	\N	1 	1 	1096194436  	INGRID PAOLA ZABALETA ALVAREZ           	17	3	2004-05-10	1	CARRERA 19 Nº 49-29	456456	68001	2	1	0	5	445465	8 	2009-03-11	328	496900	68001	1	52	0.00	1.00	2010-03-10	0
312	1	109619836	ERIKA MILENA RUEDA H	\N	\N	\N	\N	\N	4 	4 	1096198366  	ERIKA MILENA RUEDA HERRERA              	17	3	2004-05-10	1	CRA 19 Nº 49-29	545454	68001	2	1	0	5	44654	8 	2009-03-11	329	496900	68001	1	52	0.00	1.00	2010-03-10	0
313	1	9692616	JHON FABIO BOLIVAR U	\N	\N	\N	\N	\N	1 	1 	9692616     	JHON FABIO BOLIVAR URQUIJO              	10	3	1982-08-15	1	CRA 19 Nº 49-29	6224514	68001	2	1	0	5	445456	8 	2009-03-11	330	940000	68001	1	52	1.00	1.00	2010-03-11	0
314	1	91535132	SERGIO DARIO ARTEAGA	\N	\N	\N	\N	\N	1 	1 	91535132    	SERGIO DARIO ARTEAGA GOMEZ              	14	3	2004-05-10	1	CRA 8 Nº 3-61	454546	68001	2	1	0	5	45454	8 	2009-03-05	331	700000	68001	1	52	0.00	1.00	2010-03-04	0
315	1	35005795	MAYRA ESTELA ALVAREZ	\N	\N	\N	\N	\N	1 	1 	35005795    	MAYRA ESTELA ALVAREZ NOVOA              	17	3	1985-02-03	1	CRA 6 Nº 49-27	6224514	68001	2	1	0	5	45454	8 	2014-07-06	337	680000	68001	0	52	1.00	1.00	2010-05-09	0
316	1	91041825	NICEFORO ARDILA SAAV	\N	\N	\N	\N	\N	7 	7 	91041825    	NICEFORO ARDILA SAAVEDRA                	15	3	2004-05-10	1	cra 27 nº 21-26	6350333	68001	2	1	0	5	45454	8 	2010-06-22	338	515000	68001	1	52	0.00	1.00	2010-05-11	0
317	1	109864543	IVAN ANDRES BOHORQUE	\N	\N	\N	\N	\N	2 	2 	1098645436  	IVAN ANDRES BOHORQUEZ PALOMINO          	15	3	1987-11-19	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	5454564	8 	2010-07-08	339	515000	68001	1	52	0.00	1.00	2011-07-09	0
318	1	91352956	JORGE MAURICIO QUIJA	\N	\N	\N	\N	\N	8 	8 	91352956    	JORGE MAURICIO QUIJANO FRANCO           	15	3	1980-11-01	2	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	15456456	8 	2009-05-01	340	496900	68001	1	52	0.00	1.00	2010-05-10	0
319	1	91519406	JOSE FRANCISCO RODRI	\N	\N	\N	\N	\N	8 	8 	91519406    	JOSE FRANCISCO RODRIGUEZ CAMPOS         	15	3	1980-05-15	2	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	456454	8 	2009-05-01	341	515000	68001	1	52	0.00	1.00	2009-05-01	0
320	1	109864744	PATRICIA SAAVEDRA UR	\N	\N	\N	\N	\N	7 	7 	1098647444  	PATRICIA SAAVEDRA URIBE                 	17	3	1987-02-16	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	454564	8 	2009-05-01	342	496900	68001	1	52	0.00	1.00	2010-05-01	0
321	1	63559907	DIANA CONSUELO NAVAR	\N	\N	\N	\N	\N	3 	3 	63559907    	DIANA CONSUELO NAVARRO NIÑO             	17	3	1985-05-20	1	CRA 23 Nº 14-40	6320505	68001	2	1	0	5	54564564	8 	2009-07-02	343	515000	68001	1	52	0.00	1.00	2010-05-10	0
322	1	102233079	LESLY JULIETH PORTIL	\N	\N	\N	\N	\N	7 	7 	1022330797  	LESLY JULIETH PORTILLA                  	17	3	1987-03-08	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	456454	8 	2009-05-01	344	515000	68001	1	52	0.00	1.00	2010-09-10	0
323	1	109861184	DORIA MILENA ARDILA 	\N	\N	\N	\N	\N	2 	2 	1098611843  	DORIA MILENA ARDILA MARTINEZ            	17	3	1986-02-01	1	CRA 8 Nº 49-27	6486189	68001	2	1	0	5	5454	8 	2009-05-01	345	515000	68001	1	52	0.00	1.00	2010-05-01	0
324	1	63557847	DIANA MARCELA CABALL	\N	\N	\N	\N	\N	2 	2 	63557847    	DIANA MARCELA CABALLERO ROJAS           	17	3	2004-05-10	1	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	5454	8 	2009-05-01	346	496900	68001	1	52	0.00	1.00	2010-05-01	0
325	1	109867570	MONICA JOHANNA SOLAN	\N	\N	\N	\N	\N	7 	7 	1098675708  	MONICA JOHANNA SOLANO LOZADA            	39	3	2004-05-10	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	54564	8 	2009-05-01	347	496900	68001	1	52	0.00	1.00	2010-05-01	0
326	1	110022180	ANGEL LEONARDO CALDE	\N	\N	\N	\N	\N	7 	7 	1100221807  	ANGEL LEONARDO CALDERON ARGUELLO        	15	3	1992-06-07	1	CRA. 12 N° 42-62	3112370689	68001	1	5	0	2	2525	8 	2013-07-05	702	680000	68001	1	52	1.00	1.00	2013-02-15	0
327	1	109619751	CARMEN PAOLA ISAZA H	\N	\N	\N	\N	\N	4 	4 	1096197516  	CARMEN PAOLA ISAZA HERRERA              	15	3	2004-05-10	1	DOAIDOAIDOAI	45646546	68001	2	1	0	5	465465465	8 	2012-02-03	274	566700	68001	1	52	1.00	1.00	2009-05-27	0
328	1	28488892	HELENITA ASPRILLA VA	\N	\N	\N	\N	\N	4 	4 	28488892    	HELENITA ASPRILLA VARGAS                	17	3	2004-05-10	1	ADAPODIOAPDI	45454654	68001	2	1	0	5	46545465	8 	2008-02-27	275	461500	68001	1	52	0.00	1.00	2009-02-27	0
329	1	4984503	MILTON HERNANDO HOYO	\N	\N	\N	\N	\N	4 	4 	4984503     	MILTON HERNANDO HOYOS                   	15	3	1976-07-29	1	DADKOADKPO	64654654	68001	2	1	0	5	4654654	8 	2008-02-27	276	461500	68001	1	52	0.00	1.00	2009-02-27	0
330	1	109618848	CLAUDIA MILENA TORRE	\N	\N	\N	\N	\N	1 	1 	1096188484  	CLAUDIA MILENA TORRES JIMENEZ           	17	3	2004-05-10	1	ADKALDKKL	465454654	68001	2	1	0	5	465464	8 	2008-02-16	277	515000	68001	1	52	0.00	1.00	2009-02-27	0
331	1	109867014	OSCAR GERARDO GOMEZ 	\N	\N	\N	\N	\N	9 	9 	1098670146  	OSCAR GERARDO GOMEZ MORENO              	44	3	1989-05-14	1	CRA 23 Nº 17-40	6320505	68001	2	1	0	5	454564	8 	2009-05-01	348	700000	68001	1	52	1.00	1.00	2010-05-01	0
332	1	109866428	JUAN DAVID BALLESTER	\N	\N	\N	\N	\N	2 	2 	1098664282  	JUAN DAVID BALLESTEROS GIL              	15	3	2004-05-10	1	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	5454	8 	2009-05-01	349	515000	68001	1	52	0.00	1.00	2010-05-01	0
333	1	63545001	IVONNE JOHANNA CARVA	\N	\N	\N	\N	\N	3 	3 	63545001    	IVONNE JOHANNA CARVAJAL DIAZ            	17	3	2004-05-10	1	CRA 23 Nº 14-40	6320505	68001	2	1	0	5	45456	8 	2009-05-01	350	515000	68001	1	52	0.00	1.00	2010-05-01	0
334	1	109861703	FAWER AVELLA BENAVID	\N	\N	\N	\N	\N	7 	7 	1098617036  	FAWER AVELLA BENAVIDEZ                  	15	3	2004-05-10	1	CRA 8 Nº 3-61	64861889	68001	2	1	0	5	454564	8 	2009-05-01	351	515000	68001	1	52	0.00	1.00	2010-05-01	0
335	1	109580580	ERICA YURLEY FLOREZ 	\N	\N	\N	\N	\N	2 	2 	1095805809  	ERICA YURLEY FLOREZ MANOSALVA           	17	3	1990-08-04	1	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	45456	8 	2009-05-01	352	535600	68001	1	52	0.00	1.00	2010-05-01	0
336	1	111049271	LINA PAOLA PEÑARANDA	\N	\N	\N	\N	\N	8 	8 	1110492712  	LINA PAOLA PEÑARANDA MEJIA              	17	3	2004-05-10	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	4564564	8 	2009-05-01	353	496900	68001	1	52	0.00	1.00	2010-05-01	0
337	1	109578677	LUDY PATRICIA MARTIN	\N	\N	\N	\N	\N	7 	7 	1095786773  	LUDY PATRICIA MARTINEZ AMAYA            	39	3	2004-05-10	1	CRA 27 Nº 21-26	63503333	68001	2	1	0	5	454564	8 	2010-02-17	354	515000	68001	1	52	0.00	1.00	2010-05-01	0
338	1	37751159	GENNY XIMENA PINZON 	\N	\N	\N	\N	\N	7 	7 	37751159    	GENNY XIMENA PINZON OJEDA               	17	3	1980-06-08	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	5454	56	2009-05-01	355	496900	68001	1	52	0.00	1.00	2010-05-01	0
339	1	109426558	CINDY MILENA OTALORA	\N	\N	\N	\N	\N	2 	2 	1094265589  	CINDY MILENA OTALORA ANTOLINEZ          	17	3	1990-11-24	1	CRA 8 Nº 3-61	6486189	68001	2	1	0	5	45456	8 	2009-05-01	356	515000	68001	1	52	0.00	1.00	2010-05-01	0
340	1	110088974	LEIDY PAOLA FERNANDE	\N	\N	\N	\N	\N	7 	7 	1100889747  	LEIDY PAOLA FERNANDEZ JOYA              	39	3	1987-12-04	1	CRA 27 Nº 21-26	6330533	68001	2	1	0	5	45456	8 	2009-07-01	361	535600	68001	1	52	0.00	1.00	2010-07-01	0
341	1	13569512	FARID ENRIQUE ARZUAG	\N	\N	\N	\N	\N	1 	1 	13569512    	FARID ENRIQUE ARZUAGA RODRIGUEZ         	15	3	1984-11-20	1	CRA 19 Nº 49-296	54564564	68001	2	1	0	5	45645456	8 	2009-07-27	362	496900	68001	1	52	0.00	1.00	2010-07-29	0
342	1	109619859	MARIA IRENE OSPINA P	\N	\N	\N	\N	\N	4 	4 	1096198599  	MARIA IRENE OSPINA PINZON               	17	3	2004-05-10	1	ADKADJKA	4564546	68001	2	1	0	5	6454564	8 	2009-07-21	363	496900	68001	1	52	0.00	1.00	2010-07-20	0
343	1	109861140	MARTHA LILIANA SANCH	\N	\N	\N	\N	\N	0 	0 	1098611405  	MARTHA LILIANA SANCHEZ VELASQUEZ        	29	1	2004-05-10	1	ADAPDPLA	46456456	68001	2	1	0	5	45465456	8 	2009-07-17	364	580000	68001	1	51	0.00	1.00	2010-07-20	0
344	1	109620232	ALVARO FERNEY GOMEZ 	\N	\N	\N	\N	\N	1 	1 	1096202323  	ALVARO FERNEY GOMEZ GONZALEZ            	15	3	2004-05-10	2	CARRERA 6 Nº 49-29	6224514	68001	2	1	0	5	5456465	8 	2009-08-25	365	496900	68001	1	52	0.00	1.00	2010-08-24	0
345	1	91346475	CARLOS AUGUSTO SERRA	\N	\N	\N	\N	\N	10	10	91346475    	CARLOS AUGUSTO SERRANO SERRANO          	12	3	1972-02-21	2	CALLE 7 N° 11-46	6562664	68001	2	1	0	5	46546546	8 	2012-01-09	366	3000000	68001	0	52	0.00	1.00	2013-01-08	0
346	1	63352538	MARTHA BELTRAN QUIRO	\N	\N	\N	\N	\N	0 	0 	63352538    	MARTHA BELTRAN QUIROGA                  	29	1	1970-03-05	1	CALLE 70 Nº 44W-156	545645646	68001	2	1	0	5	54564564	8 	2009-08-18	367	1560000	68001	1	52	0.00	1.00	2010-08-22	0
347	1	109618589	TERESA DEL PILAR ALE	\N	\N	\N	\N	\N	4 	4 	1096185899  	TERESA DEL PILAR ALEMAN APARICIO        	17	3	1986-10-09	1	adakldkadlkad	465464	68001	2	1	0	5	54564564	35	2012-01-20	384	566700	68001	1	52	1.00	1.00	2010-10-05	0
348	1	63560868	LADY ELOISA GONZALEZ	\N	\N	\N	\N	\N	4 	4 	63560868    	LADY ELOISA GONZALEZ HERAZO             	17	3	1985-06-13	1	kajdkajkdj	456456456	68001	2	1	0	5	54564564	8 	2011-07-02	385	535600	68001	1	52	0.00	1.00	2010-10-05	0
349	1	109619454	NEYRA SIRLEY TOLOZA 	\N	\N	\N	\N	\N	4 	4 	1096194543  	NEYRA SIRLEY TOLOZA NIÑO                	17	3	1988-03-20	1	adadad	44654564	68001	2	1	0	5	54564564	8 	2009-10-06	386	515000	68001	1	52	0.00	1.00	2010-10-05	0
350	1	91527213	WILLIAM FERNANDO CAS	\N	\N	\N	\N	\N	8 	8 	91527213    	WILLIAM FERNANDO CASTAÑEDA ALHUCEMA     	15	3	1983-12-01	1	KAJDKAJDJ	465564	68001	2	1	0	5	54654564	8 	2009-10-06	387	515000	68001	1	52	0.00	1.00	2010-10-05	0
351	1	13831852	JAIME GOMEZ FORERO  	\N	\N	\N	\N	\N	0 	0 	13831852    	JAIME GOMEZ FORERO                      	29	1	1956-02-02	2	CALLE 70 Nº 44 W -156	6370099	68001	2	1	0	5	54564564	8 	2009-05-27	357	2000000	68001	1	52	0.00	1.00	2010-05-10	0
352	1	13570897	JONATHAN JOSE SILVA 	\N	\N	\N	\N	\N	4 	4 	13570897    	JONATHAN JOSE SILVA MELLADO             	15	3	1985-08-28	2	CRA 6 Nº 4-29	6224514	68001	2	1	0	5	45464	8 	2009-05-27	358	496900	68001	1	52	0.00	1.00	2010-05-26	0
353	1	109862664	ZULLY YARITZA TRUJIL	\N	\N	\N	\N	\N	7 	7 	1098626644  	ZULLY YARITZA TRUJILLO URQUIJO          	17	3	1986-12-11	1	CRA 27 Nº 21-26	6350333	68001	2	1	0	5	45454	8 	2009-05-18	359	496900	68001	1	52	0.00	1.00	2010-05-17	0
354	1	109618966	EDITH PAOLA RAMIREZ 	\N	\N	\N	\N	\N	1 	1 	1096189664  	EDITH PAOLA RAMIREZ PERTUZ              	17	3	1987-06-21	1	CRA. 59 N° 47A-32	3212510910	68081	1	5	1	2	2525	8 	2012-04-03	718	680000	68081	1	52	1.00	1.00	2013-04-02	0
355	1	13874650	EDWIN JESUS MUÑOZ LO	\N	\N	\N	\N	\N	0 	0 	13874650    	EDWIN JESUS MUÑOZ LOPEZ                 	29	3	1982-01-11	2	CALLE 7 N° 48-26	3177480638	68001	2	1	0	5	456456	8 	2012-04-23	360	1500000	68001	1	52	0.00	1.00	2012-07-22	0
356	1	63533890	MARIA XIMENA QUIJANO	\N	\N	\N	\N	\N	0 	0 	63533890    	MARIA XIMENA QUIJANO LOPEZ              	29	1	1983-07-20	1	CALLE 70 Nº 44W	6370099	68001	2	1	0	5	416464	8 	2009-01-09	316	800000	68001	1	51	0.00	1.00	2010-01-09	0
357	1	109860302	YENI ZONEY DIAZ SANC	\N	\N	\N	\N	\N	2 	2 	1098603022  	YENI ZONEY DIAZ SANCHEZ                 	17	3	1985-08-21	1	CALLE 70 Nº 44W -156	445645646	68001	2	1	0	5	445454	8 	2009-01-02	317	496900	68001	1	52	0.00	1.00	2010-01-02	0
358	1	63536406	JEIDY YERCENIA DIAZ 	\N	\N	\N	\N	\N	7 	7 	63536406    	JEIDY YERCENIA DIAZ                     	20	3	1981-04-15	1	kaldklakdlñ	54564564	68001	2	1	0	5	54564654	8 	2009-09-24	369	1700000	68001	0	52	0.00	1.00	2010-09-27	0
359	1	109866962	LEYDY CAROLINA NAVAS	\N	\N	\N	\N	\N	7 	7 	1098669629  	LEYDY CAROLINA NAVAS GUTIERREZ          	39	3	2004-05-10	1	HAJHDJKAHD	45645646	68001	2	1	0	5	4546546	8 	2009-09-24	370	535600	68001	1	52	0.00	1.00	2010-05-27	0
360	1	37863164	SHIRLEY MILENA ARIAS	\N	\N	\N	\N	\N	8 	8 	37863164    	SHIRLEY MILENA ARIAS DULCEY             	12	3	1980-09-28	1	ADJAJDOJAD	66454565464	68001	2	1	0	5	4564564	8 	2009-09-24	371	2300000	68001	1	52	0.00	1.00	2010-09-23	0
361	1	109866444	CAROLINA PARADA BELT	\N	\N	\N	\N	\N	2 	2 	1098664448  	CAROLINA PARADA BELTRAN                 	41	3	2004-05-10	1	JADJKADJADJL	454646	68001	2	1	0	5	45444	8 	2009-09-24	372	515000	68001	1	52	0.00	1.00	2010-09-23	0
362	1	103235895	ASTRID JOHANNA CAMPI	\N	\N	\N	\N	\N	1 	1 	1032358953  	ASTRID JOHANNA CAMPILLO BARRERA         	17	3	1986-03-06	1	KJDKAJDJK	45645646	68001	2	1	0	5	5456465	8 	2009-09-28	368	515000	68001	1	52	0.00	1.00	2010-09-27	0
363	1	109618731	KATHERINE ANDREA AZU	\N	\N	\N	\N	\N	4 	4 	1096187314  	KATHERINE ANDREA AZUERO                 	17	3	1986-11-15	1	KDAKDKDPKAD	645456456	68001	2	1	0	5	54564564	8 	2010-02-02	373	515000	68001	1	52	0.00	1.00	2010-09-23	0
364	1	111048377	NILSON MAYORGA RESTR	\N	\N	\N	\N	\N	4 	4 	1110483775  	NILSON MAYORGA RESTREPO                 	15	3	2004-05-10	1	DADKLALDÑL	4564564564	68001	2	1	0	5	54564564	8 	2010-10-23	381	515000	68001	1	52	0.00	1.00	2010-10-12	0
365	1	109866115	DIANA PATRICIA AVILA	\N	\N	\N	\N	\N	0 	0 	1098661156  	DIANA PATRICIA AVILA FERREIRA           	29	1	2004-05-10	1	DADADA	87848	68001	2	1	0	5	54564564	8 	2009-10-13	382	650000	68001	1	51	0.00	1.00	2010-10-12	0
366	1	109863325	JENNIFER LISSET RAMO	\N	\N	\N	\N	\N	4 	4 	1098633250  	JENNIFER LISSET RAMOS LEAL              	17	3	1987-04-15	1	DADADOAPODI	46456654	68001	2	1	0	5	4654564	8 	2009-10-06	383	496900	68001	1	52	0.00	1.00	2010-10-07	0
367	1	109618932	YESICA MILENA VALLE 	\N	\N	\N	\N	\N	1 	1 	1096189320  	YESICA MILENA VALLE MACIAS              	17	3	1987-04-12	1	DJKAKDJKAJ	44654645	68001	2	1	0	5	4545465	8 	2008-03-12	278	461500	68001	1	52	0.00	1.00	2009-03-11	0
368	1	109618219	SHEILA MONTES SERRAN	\N	\N	\N	\N	\N	1 	1 	1096182199  	SHEILA MONTES SERRANO                   	17	3	1985-07-09	1	POPÀOFDPAO	6437000	68001	2	1	0	5	45465465	8 	2008-03-12	279	496900	68001	1	52	0.00	1.00	2009-03-11	0
369	1	110271444	MARITZA PATIÑO GALVI	\N	\N	\N	\N	\N	4 	4 	1102714441  	MARITZA PATIÑO GALVIS                   	13	3	1985-10-01	1	ADAKDJJQ	644454654	68001	2	1	0	5	46546546	8 	2008-03-11	280	1000000	68001	0	52	1.00	1.00	2009-03-01	0
370	1	109579676	MAYRA ALEJANDRA RODR	\N	\N	\N	\N	\N	8 	8 	1095796768  	MAYRA ALEJANDRA RODRIGUEZ GARCIA        	17	3	2004-05-10	1	daldkladk	231231321	68001	2	1	0	5	4654564	8 	2009-10-06	388	515000	68001	1	52	0.00	1.00	2010-10-05	0
371	1	37901279	NAYDU MAYERLY DIAZ A	\N	\N	\N	\N	\N	8 	8 	37901279    	NAYDU MAYERLY DIAZ ARIAS                	17	3	1984-12-20	1	dklakdlkad	56656	68001	2	1	0	5	656	8 	2009-10-06	389	515000	68001	1	52	0.00	1.00	2010-10-05	0
372	1	109868075	YESLI TALIA DIAZ CAS	\N	\N	\N	\N	\N	7 	7 	1098680757  	YESLI TALIA DIAZ CASTILLO               	17	3	1981-02-01	1	jajldjaldj	654564	68001	2	1	0	5	4564654	8 	2009-10-19	395	496900	68001	1	51	0.00	1.00	2010-10-19	0
373	1	37577175	LUZ STELLA BENAVIDES	\N	\N	\N	\N	\N	1 	1 	37577175    	LUZ STELLA BENAVIDES BARRERA            	17	3	1981-02-01	1	dadada	564564564	68001	2	1	0	5	54564654	8 	2009-10-16	396	515000	68001	1	52	0.00	1.00	2010-10-16	0
374	1	109620460	YULI PAOLA TOLOZA GA	\N	\N	\N	\N	\N	4 	4 	1096204606  	YULI PAOLA TOLOZA GARCIA                	17	3	1990-02-13	1	dadjajkdk	46545646	68001	2	1	0	5	4564564	8 	2009-10-16	397	566700	68001	1	52	1.00	1.00	2010-10-15	0
375	1	109618610	MAYRA ALEJANDRA CARR	\N	\N	\N	\N	\N	4 	4 	1096186107  	MAYRA ALEJANDRA CARREÑO PUMAREJO        	17	3	1981-02-23	1	adadjaidj	4564564	68001	2	1	0	5	546546	8 	2009-10-16	398	496900	68001	1	52	0.00	1.00	2010-10-15	0
376	1	109863789	JEIMMY LIZETH BAUTIS	\N	\N	\N	\N	\N	7 	7 	1098637894  	JEIMMY LIZETH BAUTISTA FIGUEROA         	17	3	1987-07-12	1	DKAJDKJAL	45645646	68001	2	1	0	5	5456465	8 	2009-10-16	399	515000	68001	1	52	0.00	1.00	2010-02-15	0
377	1	63548450	LAURA CAROLINA TARAZ	\N	\N	\N	\N	\N	7 	7 	63548450    	LAURA CAROLINA TARAZONA SEPULVEDA       	39	3	1984-04-11	1	DADJKLADJ	64564564	68001	2	1	0	5	5456465	8 	2009-10-16	400	496900	68001	1	52	0.00	1.00	2010-10-15	0
378	1	91521633	JORGE ARMANDO ALVARE	\N	\N	\N	\N	\N	9 	9 	91521633    	JORGE ARMANDO ALVAREZ ALVAREZ           	15	3	1983-08-27	1	JKDKLJAKLDJ	56	68001	2	1	0	6	5465465	8 	2009-10-06	390	535600	68001	1	52	0.00	1.00	2010-10-05	0
379	1	109580173	KARLA BRIJITH RUEDA 	\N	\N	\N	\N	\N	8 	8 	1095801732  	KARLA BRIJITH RUEDA FIGUEROA            	17	3	2004-05-10	1	ADADLÑALD	5564564	68001	2	1	0	5	465464	8 	2009-10-05	391	515000	68001	1	52	0.00	1.00	2010-10-04	0
380	1	37617617	ISABEL CRISTINA DELG	\N	\N	\N	\N	\N	8 	8 	37617617    	ISABEL CRISTINA DELGADO VILLAMIZAR      	20	3	1982-04-02	1	kadjadjjd	5644654	68001	2	1	0	5	5456456	8 	2009-10-05	392	900000	68001	1	52	1.00	1.00	2010-10-05	0
381	1	91530390	JOHN FREDDY GRATERON	\N	\N	\N	\N	\N	8 	8 	91530390    	JOHN FREDDY GRATERON GODOY              	15	3	1984-05-04	1	dadad	4655656	68001	2	1	0	5	4654564	8 	2009-10-05	393	680000	68001	1	52	1.00	1.00	2010-10-05	0
382	1	91159619	JOSE VICENTE MORA FL	\N	\N	\N	\N	\N	10	10	91159619    	JOSE VICENTE MORA FLOREZ                	10	3	1980-09-16	1	JKDA<LDJKALJD	4564654	68001	2	1	0	5	54564564	8 	2013-08-17	394	700000	68001	1	52	1.00	1.00	2010-10-09	0
383	1	109866700	SANDRA LILIANA BELTR	\N	\N	\N	\N	\N	7 	7 	1098667000  	SANDRA LILIANA BELTRAN RUEDA            	39	3	1989-01-13	1	ADADAOPDI	6465454	68001	2	1	0	5	54654564	8 	2009-10-16	401	515000	68001	1	52	0.00	1.00	2010-10-15	0
384	1	37727887	ALYUL SANCHEZ OSORIO	\N	\N	\N	\N	\N	9 	9 	37727887    	ALYUL SANCHEZ OSORIO                    	17	3	1979-08-04	1	ADAKDJKAJD	4654564	68001	2	1	0	5	545454	8 	2009-10-16	402	535600	68001	1	52	0.00	1.00	2010-10-15	0
385	1	109869570	LEIDY TATIANA SANCHE	\N	\N	\N	\N	\N	7 	7 	1098695707  	LEIDY TATIANA SANCHEZ TAMAYO            	17	3	1990-10-05	1	DADKAÑDK	45465	68001	2	1	0	5	456464654	8 	2009-11-10	403	515000	68001	1	52	0.00	1.00	2009-11-10	0
386	1	109619808	DIANA MARCELA PEREA 	\N	\N	\N	\N	\N	1 	1 	1096198087  	DIANA MARCELA PEREA VELASQUEZ           	17	3	1988-02-26	1	DADADAD	46545646	68001	2	1	0	5	54564564	8 	2009-11-05	404	515000	68001	1	52	0.00	1.00	2009-11-05	0
387	1	63471285	DORIS JANET ROSAS DI	\N	\N	\N	\N	\N	4 	4 	63471285    	DORIS JANET ROSAS DIAZ                  	41	3	1977-12-03	2	CRA 19 Nº 49-37	546545645	68001	2	1	0	5	546545646	8 	2009-11-23	405	515000	68001	1	52	0.00	1.00	2010-11-22	0
388	1	63545937	MARIA YESENIA PIRATO	\N	\N	\N	\N	\N	1 	1 	63545937    	MARIA YESENIA PIRATOA MALAVER           	17	3	1985-12-01	1	t.grdt,gdtfyh	3223	68001	1	1	0	2	54136	8 	2010-03-04	437	535600	68001	1	52	0.00	1.00	2011-03-03	0
389	1	63470625	CLAUDIA LEONOR PINZO	\N	\N	\N	\N	\N	1 	1 	63470625    	CLAUDIA LEONOR PINZON GOMEZ             	17	3	1977-06-10	1	CALLE 57 Nº 35-47 PRIMERO DE MAYO	6217117	68001	2	1	0	5	4545456	8 	2009-04-25	332	496900	68001	1	52	0.00	1.00	2010-04-24	0
390	1	109620288	JAIRO NOEL DURAN QUI	\N	\N	\N	\N	\N	4 	4 	1096202887  	JAIRO NOEL DURAN QUINTERO               	15	3	1989-10-19	2	CALLE 33 Nº 52-07 LA TOCCA	3167016171	68001	2	1	0	5	45644564	8 	2009-04-22	333	515000	68001	1	52	0.00	1.00	2010-04-25	0
391	1	109618886	VIVIANA ANDREA HERNA	\N	\N	\N	\N	\N	1 	1 	1096188866  	VIVIANA ANDREA HERNANDEZ RAMIREZ        	17	3	1984-11-02	2	CRA 6 Nº 19-49	4545646	68001	2	1	0	5	454564	8 	2009-04-17	334	515000	68001	1	52	0.00	1.00	2010-04-25	0
392	1	13540980	ALEXANDER MANTILLA F	\N	\N	\N	\N	\N	1 	1 	13540980    	ALEXANDER MANTILLA FLOREZ               	15	3	1978-04-22	1	CRA 6 Nº 49-29	6224514	68001	2	1	0	5	456456	8 	2009-04-17	335	496900	68001	1	52	0.00	1.00	2010-04-25	0
393	1	91281218	WILLIAM ALBERTO VELA	\N	\N	\N	\N	\N	0 	0 	91281218    	WILLIAM ALBERTO VELASCO MURILLO         	29	1	2004-05-10	2	CALLE 70 Nº 44 W-156 KM 4 VIA GIRON	6447300	68001	2	1	0	5	45645456	8 	2009-04-17	336	1560000	68001	1	52	0.00	1.00	2010-04-25	0
394	1	13718041	WILLIAM ENRIQUE MATI	\N	\N	\N	\N	\N	2 	2 	13718041    	WILLIAM ENRIQUE MATIZ PEDRAZA           	15	3	1981-12-01	2	fghfghtg	415435	68001	2	1	0	5	2121	8 	2010-03-04	438	515000	68001	1	52	0.00	1.00	2011-03-03	0
395	1	91296674	JAIRO ENRIQUE JIMENE	\N	\N	\N	\N	\N	0 	0 	91296674    	JAIRO ENRIQUE JIMENEZ BAUTISTA          	29	3	1974-04-05	1	gfsdlgñf	452121	68001	2	1	0	5	52113	8 	2010-03-01	439	3500000	68001	0	52	0.00	1.00	2011-03-01	0
396	1	110236627	GENNY ROCIO ROMERO R	\N	\N	\N	\N	\N	8 	8 	1102366278  	GENNY ROCIO ROMERO RAMIREZ              	17	3	1980-12-01	1	setdkterlñt	4153463	68001	2	1	0	5	341524	8 	2010-03-01	440	515000	68001	1	52	0.00	1.00	2011-02-28	0
397	1	63508926	ELSSY KATHERYN GARZO	\N	\N	\N	\N	\N	3 	3 	63508926    	ELSSY KATHERYN GARZON FRIAS             	16	3	1980-05-10	1	klñklñsdfk	4456	68001	2	1	0	5	5341413	8 	2010-03-01	441	770000	68001	0	52	1.00	1.00	2011-02-28	0
398	1	91527583	FREDY ARMANDO CACERE	\N	\N	\N	\N	\N	2 	2 	91527583    	FREDY ARMANDO CACERES CAMACHO           	15	3	1983-05-08	2	SAFDDSFGDF	534546	68001	2	1	0	5	4341	8 	2010-04-01	447	535600	68001	1	52	0.00	1.00	2011-04-10	0
399	1	109621415	OLGA LUCIA ANTURY RE	\N	\N	\N	\N	\N	1 	1 	1096214156  	OLGA LUCIA ANTURY REYES                 	17	3	1992-01-22	1	CRA 48A 29-36  EL CERRO	6205969	68081	1	1	0	2	4444556	8 	2011-08-18	455	566700	68081	1	52	1.00	1.00	2011-05-15	0
400	1	37749364	AMILDE SANCHEZ SOLER	\N	\N	\N	\N	\N	0 	0 	37749364    	AMILDE SANCHEZ SOLER                    	29	1	1980-04-13	1	CRA. 23 N° 30-25 AP 501 TORRE 2	3152130752	68001	1	5	2	3	414124	8 	2015-02-04	720	2500000	68001	0	51	0.00	1.00	2013-04-18	0
401	1	109581160	CAMILO ANDRES RIATIG	\N	\N	\N	\N	\N	3 	3 	1095811608  	CAMILO ANDRES RIATIGA BONILLA           	15	3	1992-03-24	2	CALLE 105A N° 41A-71	3183272628	68001	1	1	0	2	252525	8 	2014-02-21	722	680000	68001	1	52	1.00	1.00	2013-04-17	0
402	1	109620161	ANGIE SULAY CELIS CO	\N	\N	\N	\N	\N	4 	4 	1096201612  	ANGIE SULAY CELIS CONTRERAS             	17	3	1988-05-25	1	KLDLADKLKAD	44545	68001	2	1	0	5	5464564	8 	2009-11-23	406	515000	68001	1	52	0.00	1.00	2010-11-22	0
403	1	109861296	LEIDY XIOMARA BARBOS	\N	\N	\N	\N	\N	4 	4 	1098612968  	LEIDY XIOMARA BARBOSA ALQUICHIRE        	41	3	1986-02-22	1	ADKKLKLÑKLDA	44654654	68001	2	1	0	5	54654564	8 	2009-11-20	407	515000	68001	1	52	0.00	1.00	2010-11-22	0
404	1	103364761	JOHANA CAROLINA LOND	\N	\N	\N	\N	\N	4 	4 	1033647618  	JOHANA CAROLINA LONDOÑO CORREA          	17	3	1987-09-07	1	ADLÑKLÑDÑAKDK	45645646	68001	2	1	0	5	554546	8 	2009-11-20	408	515000	68001	1	52	0.00	1.00	2010-11-20	0
405	1	91530378	ANDRES RICARDO RODRI	\N	\N	\N	\N	\N	2 	2 	91530378    	ANDRES RICARDO RODRIGUEZ SANTAMARIA     	15	3	1985-12-01	2	FGDCHGRF	14245687	68001	2	1	0	5	353436	8 	2010-01-08	415	515000	68001	1	52	0.00	1.00	2011-01-07	0
406	1	107524710	LEIDY PAOLA SEPULVED	\N	\N	\N	\N	\N	3 	3 	1075247106  	LEIDY PAOLA SEPULVEDA NAVAS             	17	3	1991-09-07	1	SAD FSDTFGRTDYG	14175253	68001	2	1	0	5	435	8 	2010-01-09	416	515000	68001	1	52	0.00	1.00	2011-01-08	0
407	1	91529181	DIEGO FERNANDO HERNA	\N	\N	\N	\N	\N	2 	2 	91529181    	DIEGO FERNANDO HERNANDEZ AVILA          	15	3	1986-12-10	2	BFDHGTGFDHGFD	5643654	68001	2	1	0	5	4534	8 	2010-04-02	417	515000	68001	1	52	0.00	1.00	2011-01-11	0
408	1	91516835	JOSE EFRAIN CASTRO M	\N	\N	\N	\N	\N	3 	3 	91516835    	JOSE EFRAIN CASTRO MACIAS               	15	3	1986-12-01	2	DSAFDESTERD	465453	68001	1	1	0	2	12131	8 	2010-01-12	418	535600	68001	1	52	0.00	1.00	2011-01-11	0
409	1	109871282	ELISA TATIANA MANTIL	\N	\N	\N	\N	\N	2 	2 	1098712825  	ELISA TATIANA MANTILLA GONZALEZ         	17	3	1986-01-01	1	DSFSGREGFD	2423416	68001	2	1	0	5	536435	8 	2010-01-12	419	515000	68001	1	52	0.00	1.00	2011-01-11	0
410	1	109864796	ADRIANA CAROLINA RIV	\N	\N	\N	\N	\N	0 	0 	1098647960  	ADRIANA CAROLINA RIVERA ZABALA          	29	1	1988-01-13	1	CALLE 11 28-	54654654	68001	2	1	0	5	32131	8 	2010-01-12	420	680000	68001	1	51	0.00	1.00	2011-01-15	0
411	1	63555993	DERLY VIVIANA MEJIA 	\N	\N	\N	\N	\N	7 	7 	63555993    	DERLY VIVIANA MEJIA RAMIREZ             	17	3	1984-12-01	1	ETAPA 11 MZ D ST E CS 9 BETANIA NORTE	3158674323	68001	3	1	0	2	545454545	40	2010-05-16	456	515000	68001	1	52	0.00	1.00	2011-05-16	0
412	1	109867913	JAVIER ANDRES BARAJA	\N	\N	\N	\N	\N	7 	7 	1098679136  	JAVIER ANDRES BARAJAS ROJAS             	15	3	1989-12-07	2	CALLE 105 29-08 DIAMANTE 1	6829422	68001	1	1	0	2	534354230123	96	2010-05-26	457	515000	68001	1	52	0.00	1.00	2011-05-26	0
413	1	109863839	INGRID JULIETH DIAZ 	\N	\N	\N	\N	\N	7 	7 	1098638394  	INGRID JULIETH DIAZ PABON               	17	3	1987-07-13	1	COLSEGUROS NORTE BLOQUE 3 APTO 101	6406374	68001	3	1	1	2	5453455646	40	2010-05-26	458	535600	68001	1	52	0.00	1.00	2011-05-26	0
414	1	109618393	DARWIN DAVID RINCON 	\N	\N	\N	\N	\N	1 	1 	1096183934  	DARWIN DAVID RINCON CARREÑO             	15	3	1986-06-12	2	MANZANA B CASA 18	6024120	68081	3	1	0	2	5454050453452	19	2010-05-27	459	535600	68081	1	52	0.00	1.00	2011-05-27	0
415	1	112956711	LEONARDO ANDRES GARR	\N	\N	\N	\N	\N	2 	2 	1129567116  	LEONARDO ANDRES GARRIDO GUARIN          	15	3	1986-04-20	2	BALCON DEL TEJAR 5 PORTERIA T-4 APTO 301	3116769208	68001	1	1	0	2	4641684654	8 	2010-05-29	460	566700	68001	1	52	1.00	1.00	2011-05-29	0
416	1	920316625	JULIETH MAYERLING RO	\N	\N	\N	\N	\N	8 	8 	92031662577 	JULIETH MAYERLING RONDON RAMIREZ        	17	3	2004-05-10	1	REWTF	75272455	68001	2	1	0	2	44545234	8 	2009-12-23	411	515000	68001	1	52	0.00	1.00	2010-05-10	0
417	1	63469877	MARIA HELENA CAMACHO	\N	\N	\N	\N	\N	1 	1 	63469877    	MARIA HELENA CAMACHO GUILLEN            	17	3	2004-05-10	1	FDGSDGF	547274524	68001	2	3	0	2	146363	8 	2009-12-19	412	515000	68001	1	52	0.00	1.00	2010-12-22	0
418	1	103968278	JENNIFER TATIANA CAS	\N	\N	\N	\N	\N	1 	1 	1039682781  	JENNIFER TATIANA CASTILLO               	17	3	2004-05-10	1	DAFDFGF	745742	68001	2	1	0	5	4554352	8 	2009-12-19	413	532500	68001	1	52	0.00	1.00	2010-12-25	0
419	1	920316683	JURLEY TATIANA MACIA	\N	\N	\N	\N	\N	7 	7 	92031668311 	JURLEY TATIANA MACIAS QUIJANO           	17	3	2004-05-10	1	FDSGDSGFDHFD	4542361	68001	2	1	0	5	46542	8 	2009-12-19	414	535600	68001	1	52	0.00	1.00	2010-12-10	0
420	1	109869103	SANDRA YISETH CALDER	\N	\N	\N	\N	\N	9 	9 	1098691032  	SANDRA YISETH CALDERON SEQUEDA          	17	3	1990-08-04	1	CRA 15 53-40  OASIS FLORIDA	6493963	68001	1	2	1	2	453453413574	8 	2010-07-24	466	535600	68001	1	52	0.00	1.00	2011-07-23	0
421	1	109579943	LUZ AMALIA PRIETO HE	\N	\N	\N	\N	\N	8 	8 	1095799436  	LUZ AMALIA PRIETO HERNANDEZ             	17	3	1988-12-29	1	MESA DE RUITOQUE VEREDA LA ESPERANZA	6844734	68001	3	1	0	2	42445243	8 	2014-09-13	467	680000	68001	1	52	1.00	1.00	2011-07-28	0
422	1	63366987	CLAUDIA CECILIA CORZ	\N	\N	\N	\N	\N	0 	0 	63366987    	CLAUDIA CECILIA CORZO PABON             	29	1	2010-12-04	1	CRA 26 34-18 APTO 1205  ANTONIA SANTOS	6343195	68001	2	1	1	5	12121545	8 	2011-01-01	468	6962800	68001	1	51	0.00	1.00	2011-07-27	0
423	1	109580886	MISLEYDY DIAZ DIAZ  	\N	\N	\N	\N	\N	8 	8 	1095808861  	MISLEYDY DIAZ DIAZ                      	17	3	1991-05-21	1	MESA DE RUITOQUE VEREDA BUENOS AIRES	33138071197	68001	1	5	0	2	5434560	8 	2010-07-30	469	566700	68001	1	52	1.00	1.00	2011-07-30	0
424	1	63538797	ANGELA BARRIOS TORRE	\N	\N	\N	\N	\N	2 	2 	63538797    	ANGELA BARRIOS TORRES                   	17	3	1983-01-23	1	CALLE 70 44W-156 KM 4 VIA GIRON	6370099	68001	3	1	3	3	4787777565	8 	2010-08-07	470	535600	68001	1	52	0.00	1.00	2011-08-07	0
425	1	109861097	LILIANA MARCELA CAMA	\N	\N	\N	\N	\N	9 	9 	1098610976  	LILIANA MARCELA CAMARGO BARRAGAN        	17	3	1985-11-23	1	CALLE 112 32A-33   EL DORADO FLORIDA	6315606	68001	2	5	1	3	5454604	8 	2010-08-12	471	535600	68001	1	52	0.00	1.00	2011-08-12	0
426	1	109620883	MARIA GABRIELA GONZA	\N	\N	\N	\N	\N	4 	4 	1096208836  	MARIA GABRIELA GONZALEZ FORERO          	39	3	1990-06-07	1	CRA 46 36B-93 TAMARINDOS CLUB	3133955726	68081	1	1	0	2	55454545	8 	2010-08-13	472	535600	68081	1	52	0.00	1.00	2011-08-13	0
427	1	110234986	MARTHA LILIANA OLART	\N	\N	\N	\N	\N	3 	3 	1102349862  	MARTHA LILIANA OLARTE FLOREZ            	17	3	1985-12-12	1	CALLE 43 23-06 EL POBLADO GIRON	3168563228	68001	1	5	0	3	546514861456	8 	2011-05-02	473	535600	68001	1	52	0.00	1.00	2011-09-07	0
428	1	110235372	ADRIANA KATHERINE DI	\N	\N	\N	\N	\N	8 	8 	1102353725  	ADRIANA KATHERINE DIAZ ESCOBAR          	17	3	1987-09-16	1	CRA 15C 19-03 PASEO DEL PUENTE PCTA	3115285853	68001	3	1	1	2	546545646	8 	2010-09-11	474	566700	68001	1	52	1.00	1.00	2011-09-11	0
429	1	109620175	YAJAIRA ELIANA ALVAR	\N	\N	\N	\N	\N	1 	1 	1096201753  	YAJAIRA ELIANA ALVAREZ ARANGO           	17	3	1989-02-22	1	CALLE 26  47-174 BELLAVISTA	6106880	68081	3	1	0	2	236598	8 	2010-11-02	482	515000	68081	1	52	0.00	1.00	2011-11-01	0
430	1	109580072	MONICA MARCELA GUARG	\N	\N	\N	\N	\N	2 	2 	1095800724  	MONICA MARCELA GUARGUATI FLOREZ         	17	3	1989-03-08	1	CAKKE 7  12-18 FLORIDABLANCA	3112155938	68276	1	5	0	2	235685214	8 	2010-12-07	507	535600	68001	1	52	0.00	1.00	2011-12-06	0
431	1	107225492	NIUBAR JOSE PERTUZ C	\N	\N	\N	\N	\N	12	12	1072254925  	NIUBAR JOSE PERTUZ CONDE                	33	3	1988-08-29	2	CRA. 25A N° 55N-26	3203958451	68001	1	1	0	3	2525	8 	2012-04-20	725	770000	68001	0	52	1.00	1.00	2013-04-19	0
432	1	109580689	JESSICA PATRICIA GAL	\N	\N	\N	\N	\N	8 	8 	1095806899  	JESSICA PATRICIA GALINDO                	17	3	2004-05-01	1	CALLE 70 44W-156 KM 4 VIA GIRON	6370099	68001	1	1	0	2	5654545	8 	2010-04-01	461	515000	68001	1	52	0.00	1.00	2011-04-01	0
433	1	109579456	JENNY PAOLA GALVAN G	\N	\N	\N	\N	\N	8 	8 	1095794560  	JENNY PAOLA GALVAN GOMEZ                	60	3	1987-12-22	1	MESA DE RUITOQUE VEREDA LOS PINARES	3174326764	68001	1	1	1	2	45154544	8 	2010-06-05	463	650000	68001	1	52	1.00	1.00	2011-06-05	0
434	1	110095506	JULIANA ANDREA RIVER	\N	\N	\N	\N	\N	9 	9 	1100955066  	JULIANA ANDREA RIVEROS ARENAS           	17	3	1989-06-05	1	CALLE 64A  17A-92 LA CEIBA	6949241	68001	2	5	1	2	235698	8 	2010-12-01	496	515000	68464	1	52	0.00	1.00	2011-11-30	0
435	1	109869857	GEIMY CAROLINA HERRE	\N	\N	\N	\N	\N	8 	8 	1098698573  	GEIMY CAROLINA HERRERA GARCIA           	17	3	1990-12-10	1	CALLE 148  38-20 VILLA REAL DEL SUR	3134068138	68276	1	1	0	2	235698	8 	2010-12-01	497	680000	68276	1	52	1.00	1.00	2011-12-01	0
436	1	13872708	WILLIAM RUEDA HERRER	\N	\N	\N	\N	\N	9 	9 	13872708    	WILLIAM RUEDA HERRERA                   	15	3	1981-05-30	2	calle 39  32-15  QUINTA DEL LLANITO GIRO	6467313	68307	1	4	0	2	235698	8 	2010-12-06	499	515000	68001	1	52	0.00	1.00	2011-12-05	0
437	1	13512764	HENRY CUCHIA MANTILL	\N	\N	\N	\N	\N	9 	9 	13512764    	HENRY CUCHIA MANTILLA                   	15	3	1977-06-25	2	CALLE 69  10C-36 PABLO VI	6431788	68001	2	5	0	2	235698	8 	2010-12-06	500	535600	68001	1	52	0.00	1.00	2011-12-05	0
438	1	110235013	JHON ALEXIS RAMIREZ 	\N	\N	\N	\N	\N	2 	2 	1102350133  	JHON ALEXIS RAMIREZ ROJAS               	15	3	1986-06-08	2	CALLE 3A  9C-12 VILLANUEVA PIEDECUESTA	6559418	68547	1	1	0	2	6589562	8 	2010-12-01	501	535600	68547	1	52	0.00	1.00	2011-11-30	0
439	1	109592317	ANDRES FELIPE MOLINA	\N	\N	\N	\N	\N	9 	9 	1095923175  	ANDRES FELIPE MOLINA ALVAREZ            	15	3	1990-09-24	2	PORTAL DE SAN SEBASTIAN TORRE 3 APTO 202	3134673755	68001	2	5	0	2	235698	8 	2010-12-06	502	532500	68001	1	52	0.00	1.00	2011-12-05	0
440	1	13568102	HAIR AGUIRRE PIÑERES	\N	\N	\N	\N	\N	1 	1 	13568102    	HAIR AGUIRRE PIÑERES                    	15	3	1987-05-13	2	KLWKDLAKDLAK	6224714	68001	2	1	0	5	45464	8 	2008-10-01	311	515000	68001	1	52	0.00	1.00	2009-10-01	0
441	1	110236101	MARGY LICETH CASTILL	\N	\N	\N	\N	\N	8 	8 	1102361012  	MARGY LICETH CASTILLO DIAZ              	17	3	1989-08-13	1	CRA 16N  1B-08 SANFRANCISCO PIEDECUESTA	6560453	68547	1	1	0	2	2365	8 	2012-11-09	483	566700	68001	1	52	1.00	1.00	2011-11-01	0
442	1	30083035	MARCELA CAMACHO CONT	\N	\N	\N	\N	\N	4 	4 	30083035    	MARCELA CAMACHO CONTRERAS               	41	3	1969-05-22	1	CRA 50  14-58	3132831823	68081	2	2	0	3	23569	8 	2010-10-24	478	535600	68081	1	52	0.00	1.00	2011-10-23	0
443	1	109621624	KATHERINE SANDOVAL B	\N	\N	\N	\N	\N	1 	1 	1096216247  	KATHERINE SANDOVAL BLANCO               	17	3	1992-06-18	1	CRA 19  49-37	6203547	68081	1	5	0	2	52658	8 	2010-10-24	479	535600	68547	1	52	0.00	1.00	2011-10-23	0
444	1	109868304	SAMMI LOPEZ REYES   	\N	\N	\N	\N	\N	7 	7 	1098683046  	SAMMI LOPEZ REYES                       	15	3	1990-12-01	2	WR WFDG	46345	68001	2	1	0	5	423	8 	2011-08-19	442	535600	68001	1	52	0.00	1.00	2011-04-28	0
445	1	111812433	CINDY CAROLINA ORTIZ	\N	\N	\N	\N	\N	1 	1 	111812433   	CINDY CAROLINA ORTIZ LONDOÑO            	17	3	1987-12-06	1	FPKSDKFKD	565635	68081	2	1	0	5	535233	8 	2010-01-28	421	515000	68081	1	52	0.00	1.00	2011-01-15	0
446	1	109868848	MAYERLI GELVEZ GARCI	\N	\N	\N	\N	\N	7 	7 	1098688483  	MAYERLI GELVEZ GARCIA                   	17	3	1990-03-14	1	CALLE 5  23-30 COMUNEROS	3187611681	68001	1	5	0	3	2356987	8 	2010-12-09	509	535600	5615 	1	52	0.00	1.00	2011-12-08	0
447	1	109872880	MARLY YARITZA DELGAD	\N	\N	\N	\N	\N	9 	9 	1098728800  	MARLY YARITZA DELGADO GUERRERO          	17	3	1992-08-13	1	SECTOR 6 BLOQUE 10-10 APTO 401 BUCARICA	3106488091	68001	1	5	0	3	235698	8 	2010-12-09	510	535600	68001	1	52	0.00	1.00	2011-12-09	0
448	1	109861294	DORIS HELENA DAVILA 	\N	\N	\N	\N	\N	4 	4 	1098612943  	DORIS HELENA DAVILA RODRIGUEZ           	17	3	1986-03-08	1	CALLE 33  34-04 EL REFUGIO	3115643006	68081	1	5	0	2	235698521	8 	2010-12-08	511	535600	68081	1	52	0.00	1.00	2011-12-07	0
449	1	22736320	JULIE VIVIANA OROZCO	\N	\N	\N	\N	\N	9 	9 	22736320    	JULIE VIVIANA OROZCO QUINTERO           	17	3	1982-11-27	1	CALLE 22  30-34 GALLINERAL GIRON	3112432687	68307	1	5	0	2	235698	8 	2010-12-10	513	535600	68001	1	52	0.00	1.00	2011-12-09	0
450	1	109580794	DIVA CAROLINA DURAN 	\N	\N	\N	\N	\N	4 	4 	1095807943  	DIVA CAROLINA DURAN MONSALVE            	17	3	1990-12-16	1	CRA 19  49-37	6203547	68081	3	5	0	2	235689	8 	2010-12-10	514	535600	68001	1	52	0.00	1.00	2011-04-08	0
451	1	109580738	JUAN DAVID CABALLERO	\N	\N	\N	\N	\N	2 	2 	1095807388  	JUAN DAVID CABALLERO GARCIA             	15	3	1990-12-06	2	CALLE 27A  32C-40 EL LIMONAR	6108545	68081	1	1	0	2	235412	8 	2011-07-03	515	566700	68276	1	52	1.00	1.00	2011-12-09	0
452	1	109867924	JOHANNA ANDREA ROJAS	\N	\N	\N	\N	\N	9 	9 	1098679248  	JOHANNA ANDREA ROJAS RIOS               	17	3	1989-11-19	1	CRA 8AW  58-22 MUTIS	6418854	68001	1	5	0	2	235698	8 	2010-12-06	503	535600	68001	1	52	0.00	1.00	2011-12-05	0
453	1	13715205	EDWARD VILLANUEVA MA	\N	\N	\N	\N	\N	3 	3 	13715205    	EDWARD VILLANUEVA MARTINEZ              	34	3	1977-09-16	2	CALLE 58  1W-08 PISO 3 MUTIS	3163973920	68001	1	5	0	2	235698	8 	2010-12-06	504	900000	68001	1	52	1.00	1.00	2011-12-05	0
454	1	106587025	LUZ MERYS RUEDA RODR	\N	\N	\N	\N	\N	9 	9 	1065870255  	LUZ MERYS RUEDA RODRIGUEZ               	17	3	1987-06-19	1	CRA 5 OCC-  44-47 CAMPO HERMOSO	3182774220	68001	1	5	0	2	2356984	8 	2010-12-09	516	566700	13074	1	52	1.00	1.00	2011-12-08	0
455	1	109860209	AURA MERCEDES CARREÑ	\N	\N	\N	\N	\N	2 	2 	1098602090  	AURA MERCEDES CARREÑO ZAMBRANO          	36	3	1985-09-02	1	TRANSV ORIENTAL  47-36 CONJUNTO PIEMONTI	6493583	68276	1	1	0	4	256897	8 	2010-12-11	517	1300000	68001	1	52	0.00	1.00	2011-12-10	0
456	1	109592391	SANDRA MILENA AMAYA 	\N	\N	\N	\N	\N	9 	9 	1095923911  	SANDRA MILENA AMAYA GARZON              	18	3	1990-12-22	1	CRA 32  46-09 BELLAVISTA GIRON	6460144	68307	1	1	0	2	235697	8 	2010-12-11	518	1200000	25183	0	52	1.00	1.00	2011-12-10	0
457	1	109872536	YULY ANDREA RINCON R	\N	\N	\N	\N	\N	9 	9 	1098725367  	YULY ANDREA RINCON ROJAS                	17	3	1992-08-14	1	CRA 17 A  55-76 RICAUTE	6391547	68001	1	5	0	2	236598	8 	2010-12-11	519	566700	68001	1	52	1.00	1.00	2011-12-10	0
458	1	109579896	TATIANA PAOLA RODRIG	\N	\N	\N	\N	\N	2 	2 	1095798962  	TATIANA PAOLA RODRIGUEZ MANCILLA        	17	3	1988-05-18	1	CALLE 20  29-28 SAN ALONSO	6459184	68001	1	6	0	2	235698	8 	2010-12-11	520	535600	68001	1	52	0.00	1.00	2011-12-10	0
459	1	42447836	LEIDY DIANA COGOLLO 	\N	\N	\N	\N	\N	3 	3 	42447836    	LEIDY DIANA COGOLLO ARIAS               	17	3	1980-06-05	1	CALLE 18  19-57 SAN FRANCISCO	3163827882	68001	3	5	0	2	235984125	8 	2010-12-11	521	535600	20770	1	52	0.00	1.00	2011-12-10	0
460	1	109619590	VERONICA RODRIGUEZ S	\N	\N	\N	\N	\N	1 	1 	1096195908  	VERONICA RODRIGUEZ SANABRIA             	33	3	1988-07-28	1	CALLE 49  13-72 COLOMBIA	3142622112	68081	2	5	0	2	235698	8 	2010-12-14	522	840000	68001	0	52	1.00	1.00	2011-12-13	0
461	1	63538599	MARTHA LILIANA NOVOA	\N	\N	\N	\N	\N	7 	7 	63538599    	MARTHA LILIANA NOVOA CARREÑO            	17	3	1982-12-10	1	CRA 14W  46-22 CAMPOHERMOSO	3163738898	68001	1	6	0	3	21546	8 	2010-12-14	523	535600	20770	1	52	0.00	1.00	2011-12-14	0
462	1	63558388	LISNEY NAILU MACIAS 	\N	\N	\N	\N	\N	9 	9 	63558388    	LISNEY NAILU MACIAS CARDENAS            	17	3	1984-09-03	1	CALLE 17  20A-50 EL CRISTAL	3123122951	68001	1	2	0	2	235698	8 	2010-12-22	527	566700	68001	1	52	1.00	1.00	2011-12-21	0
463	1	91509600	CARLOS EDUARDO CIPAG	\N	\N	\N	\N	\N	7 	7 	91509600    	CARLOS EDUARDO CIPAGAUTA BARAJAS        	15	3	1982-05-20	2	CRA 29  72-35 ANTONIA SANTOS SUR	6816642	68001	1	6	0	2	235698	8 	2010-12-15	524	535600	68001	1	52	0.00	1.00	2011-12-14	0
464	1	13925966	RICARDO FLOREZ DUART	\N	\N	\N	\N	\N	8 	8 	13925966    	RICARDO FLOREZ DUARTE                   	12	3	1972-08-08	2	CALLE 1A BIS  5-37 CASA 178 PASEO CATALU	3116685850	68547	2	7	0	4	235698	8 	2010-12-27	525	2000000	68001	1	52	0.00	1.00	2011-12-16	0
465	1	109871129	SLENDY RUEDA RUEDA  	\N	\N	\N	\N	\N	7 	7 	1098711290  	SLENDY RUEDA RUEDA                      	60	3	1991-09-19	1	CRA 8W  64-42 MONTERREDONDO	6410836	68001	1	1	0	2	23564	8 	2013-07-19	529	680000	68895	1	52	1.00	1.00	2012-01-04	0
466	1	13743737	LUIS HIGUERA IBAÑEZ 	\N	\N	\N	\N	\N	2 	2 	13743737    	LUIS HIGUERA IBAÑEZ                     	35	3	1980-05-14	2	CARRERA 5  15-21 SANTA ANA	6395129	68276	1	5	0	2	235698	8 	2011-02-23	547	680000	68001	1	52	0.00	1.00	2012-02-22	0
467	1	109618964	ALFREDO MARTINEZ GOM	\N	\N	\N	\N	\N	4 	4 	1096189643  	ALFREDO MARTINEZ GOMEZ                  	15	3	1987-05-03	2	dadad	646544	68001	2	1	0	5	454564	8 	2012-07-05	312	680000	68001	1	52	1.00	1.00	2009-10-01	0
468	1	110236695	YULIETH VANESSA GARC	\N	\N	\N	\N	\N	9 	9 	1102366957  	YULIETH VANESSA GARCIA FUENTES          	39	3	1991-06-27	1	METROPOLIS II TORRE 2 APTO 504	6419578	68001	3	5	0	3	235698	8 	2010-12-10	512	566700	68001	1	52	1.00	1.00	2011-12-09	0
469	1	109869448	CRISTIAN RENE VELASQ	\N	\N	\N	\N	\N	3 	3 	1098694489  	CRISTIAN RENE VELASQUEZ HERNANDEZ       	15	3	1990-11-01	2	CALLE 19  21-31 APTO 201 SAN FRANCISCO	6322639	68001	1	5	0	2	2356852	8 	2010-12-06	498	535600	68001	1	52	0.00	1.00	2011-12-06	0
470	1	91230441	JOSE IGNACIO CORREA 	\N	\N	\N	\N	\N	7 	7 	91230441    	JOSE IGNACIO CORREA                     	19	3	1978-12-01	1	VSDFFLGLÑRDFKG	56463	68001	2	1	0	5	53434	51	2011-01-03	443	1872000	68001	1	52	0.00	1.00	2011-12-01	0
471	1	109868593	YURI ALEXANDRA RODRI	\N	\N	\N	\N	\N	0 	0 	1098685932  	YURI ALEXANDRA RODRIGUEZ URIBE          	29	1	1990-12-01	1	DAFASDFDS	35663	68001	2	1	0	5	23131	8 	2010-03-23	444	650000	68001	1	51	0.00	1.00	2011-03-01	0
472	1	109580116	YUDI ANDREA CAMACHO 	\N	\N	\N	\N	\N	0 	0 	1095801162  	YUDI ANDREA CAMACHO DURAN               	29	1	1980-12-01	1	FF.SALFÑL	545321	68001	2	1	0	5	5354	8 	2010-03-20	445	680000	68001	1	51	0.00	1.00	2011-12-01	0
473	1	37941653	OLGA LUCIA NARANJO M	\N	\N	\N	\N	\N	0 	0 	37941653    	OLGA LUCIA NARANJO MARIN                	29	1	1963-05-27	1	SDASFDG	564634	68001	2	1	0	5	435543	8 	2010-03-17	446	3600000	68001	1	51	0.00	1.00	2011-01-03	0
474	1	63342106	LINA DOLORES OSORIO 	\N	\N	\N	\N	\N	8 	8 	63342106    	LINA DOLORES OSORIO PORRAS              	42	3	1968-10-08	1	KDALKDLAKD	655565	68001	2	1	0	5	545646	8 	2009-09-30	374	496900	68001	1	52	0.00	1.00	2010-09-29	0
475	1	109578667	EDINSON CHAPARRO CON	\N	\N	\N	\N	\N	3 	3 	1095786670  	EDINSON CHAPARRO CONTRERAS              	36	3	1985-12-07	2	CRA 8W-62-48 CASA D-7 MUTIS	6410678	68001	4	1	0	2	235698	8 	2010-12-01	505	1300000	68001	1	52	0.00	1.00	2011-11-30	0
476	1	63540864	0                   	\N	\N	\N	\N	\N	5 	5 	63540864    	0                                       	42	3	2004-05-10	1	KADKALKD	545645646	68001	2	1	0	5	45456456	8 	2009-09-30	375	496900	68001	1	52	0.00	1.00	2010-09-29	0
477	1	37544391	YANETH MENDEZ DELGAD	\N	\N	\N	\N	\N	8 	8 	37544391    	YANETH MENDEZ DELGADO                   	42	3	2004-05-10	1	HAKJDHKAHD	564545646	68001	2	1	0	5	564545	8 	2009-09-30	376	496900	68001	1	52	0.00	1.00	2010-09-30	0
478	1	37618242	DIANA ADELAIDA DELGA	\N	\N	\N	\N	\N	8 	8 	37618242    	DIANA ADELAIDA DELGADO VILLAMIZAR       	42	3	2004-05-10	1	ASADOADIO	4465464	68001	2	1	0	5	544564	8 	2009-09-30	377	496900	68001	1	52	0.00	1.00	2010-09-29	0
479	1	63450391	LAURA MARIA LEON MAN	\N	\N	\N	\N	\N	8 	8 	63450391    	LAURA MARIA LEON MANTILLA               	42	3	2004-05-10	1	DKLAKDLAKD	54564564	68001	2	1	0	5	4554644	8 	2009-09-30	378	496900	68001	1	52	0.00	1.00	2010-09-29	0
480	1	109591728	JOHANNA DIAZ DIAZ   	\N	\N	\N	\N	\N	8 	8 	1095917286  	JOHANNA DIAZ DIAZ                       	42	3	2004-05-10	1	XAKDADÑKLAKÑ	564564564	68001	2	1	0	5	16156456	8 	2009-09-30	379	496900	68001	1	52	0.00	1.00	2010-09-29	0
481	1	109580959	ANDREA DIAZ CACERES 	\N	\N	\N	\N	\N	8 	8 	1095809598  	ANDREA DIAZ CACERES                     	42	3	2004-05-10	1	ADKALDKALKD	45456446	68001	2	1	0	5	5454564	8 	2009-09-30	380	496900	68001	1	52	0.00	1.00	2010-09-30	0
482	1	111666391	SINDY JAENCY MALDONA	\N	\N	\N	\N	\N	1 	1 	1116663911  	SINDY JAENCY MALDONADO GONZALEZ         	17	3	1989-06-25	1	CENTRO ECOPETROL CAMPO 22	3123406644	68081	3	5	0	2	235698	8 	2010-12-16	528	535600	85430	1	52	0.00	1.00	2011-12-15	0
483	1	109936723	RUTH AMPARO VEGA ANA	\N	\N	\N	\N	\N	4 	4 	1099367231  	RUTH AMPARO VEGA ANAYA                  	17	3	1990-02-07	1	BARRIO TORCOROMA BARRANCABERMEJA	3118690362	68081	3	2	0	2	235698	8 	2012-03-09	530	566700	68217	1	52	1.00	1.00	2012-01-08	0
484	1	109865549	EDINSON LOPEZ SANTAM	\N	\N	\N	\N	\N	3 	3 	1098655490  	EDINSON LOPEZ SANTAMARIA                	35	3	1988-02-21	2	CALLE 23  20-18 VILLA ROSA	6404204	68001	1	5	0	3	23569852	8 	2011-01-25	533	680000	68001	1	52	0.00	1.00	2012-01-24	0
485	1	109871264	INGRID XIOMARA ORTEG	\N	\N	\N	\N	\N	7 	7 	1098712645  	INGRID XIOMARA ORTEGA CONTRERAS         	17	3	1991-08-01	1	CRA 12  104A-28 MANUELA BELTRAN	6373058	68001	1	5	0	3	2545621	8 	2011-01-25	534	535600	68001	1	52	0.00	1.00	2012-01-24	0
486	1	63539200	LUZ STELLA RANGEL RU	\N	\N	\N	\N	\N	3 	3 	63539200    	LUZ STELLA RANGEL RUEDA                 	17	3	1983-04-05	1	CRA 12  64-14 MIRAMAR	6730281	68001	1	5	0	2	23598546	8 	2011-01-26	535	535600	68001	1	52	0.00	1.00	2012-01-25	0
487	1	109864351	JHON EMERSON GUIO BR	\N	\N	\N	\N	\N	3 	3 	1098643511  	JHON EMERSON GUIO BRICEÑO               	15	3	1987-10-07	2	CALLE 32  10CC-33	6940583	68001	1	1	0	2	235698	8 	2011-01-29	536	680000	68001	1	52	1.00	1.00	2012-01-28	0
488	1	109619879	CINDY JOHANNA REINA 	\N	\N	\N	\N	\N	1 	1 	1096198791  	CINDY JOHANNA REINA SILVA               	17	3	1989-02-12	1	CRA 8  47-87 CALLEJON GUTIERREZ	3102931509	68081	1	5	0	2	23569845	8 	2011-02-02	537	566700	68081	1	52	1.00	1.00	2012-02-01	0
489	1	63523645	LUZ STELLA SOLANO CA	\N	\N	\N	\N	\N	2 	2 	63523645    	LUZ STELLA SOLANO CAMACHO               	16	3	1981-11-13	1	CRA 18B  15N-31 VILLA ROSA	6404666	68001	4	5	0	3	23569521	8 	2011-02-07	538	800000	68895	1	52	1.00	1.00	2012-02-05	0
490	1	109619852	CARLOS ANDRES CASTRO	\N	\N	\N	\N	\N	1 	1 	1096198522  	CARLOS ANDRES CASTRO CADENA             	15	3	1989-01-08	2	CRA 6  49-29	6224514	68081	1	5	0	2	235698	8 	2011-01-09	531	566700	68081	1	52	1.00	1.00	2012-01-08	0
491	1	63352564	LUZ VIANEY RINCON SU	\N	\N	\N	\N	\N	3 	3 	63352564    	LUZ VIANEY RINCON SUAREZ                	31	3	1970-02-28	1	CALLE 147  58A-66 MANZANA 6 RECODOS FLOR	6584076	68276	4	1	0	3	26598542	8 	2011-02-08	541	1000000	68001	1	52	0.00	1.00	2012-02-07	0
492	1	110168353	ROBINSON FABIAN CALD	\N	\N	\N	\N	\N	3 	3 	1101683539  	ROBINSON FABIAN CALDERON HOLGUIN        	15	3	1986-10-31	2	CALLE 4  3A-55 LA TACHUELA PIEDECUESTA	3124148587	68547	1	5	0	2	52653245	8 	2011-08-02	542	535600	68689	1	52	0.00	1.00	2012-02-10	0
493	1	63552920	SANDRA MILENA VARGAS	\N	\N	\N	\N	\N	2 	2 	63552920    	SANDRA MILENA VARGAS PARRA              	17	3	1983-12-17	1	SAFSNFJDG	6320505	68001	2	3	0	2	12132	8 	2011-04-19	409	535600	68001	1	52	0.00	1.00	2010-12-10	0
494	1	109868213	DORIAN LORENA REYES 	\N	\N	\N	\N	\N	2 	2 	1098682133  	DORIAN LORENA REYES NAVARRO             	39	3	1989-12-25	1	GFDÑGLTFDH	6136231	68001	2	1	0	2	32121	25	2012-02-05	410	566700	68001	1	52	1.00	1.00	2010-12-09	0
495	1	109862392	GENIFER XIMENA PICO 	\N	\N	\N	\N	\N	2 	2 	1098623929  	GENIFER XIMENA PICO SANCHEZ             	17	3	1986-09-27	1	CALLE 115  45-15 ZAPAMANGA 4	6772349	68276	2	2	0	2	2569845	8 	2011-02-12	543	535600	68001	1	52	0.00	1.00	2012-02-11	0
496	1	109591870	NATHALY SOLANO CASTR	\N	\N	\N	\N	\N	7 	7 	1095918700  	NATHALY SOLANO CASTRO                   	17	3	1989-08-02	1	CRA 22  48-16 EL POBLADO	6810946	68307	1	5	0	2	235698	8 	2010-12-06	545	535600	68001	1	52	0.00	1.00	2011-12-05	0
497	1	37520638	CARMEN ALICIA VELASQ	\N	\N	\N	\N	\N	3 	3 	37520638    	CARMEN ALICIA VELASQUEZ QUINTERO        	36	3	1980-04-13	1	CRA 25  35-21 TORRE 2 APTO 405 SAN MARCO	3115622258	68001	2	2	0	4	235698	8 	2011-02-15	546	1300000	68079	1	52	0.00	1.00	2011-02-15	0
498	1	65731095	LUZ STELLA RUBIANO R	\N	\N	\N	\N	\N	1 	1 	65731095    	LUZ STELLA RUBIANO RODRIGUEZ            	41	3	1966-12-16	1	CRA 19  49-37	6203547	68081	2	5	0	2	25698	8 	2011-02-25	548	535600	68081	1	52	0.00	1.00	2011-02-25	0
499	1	63489810	SANDRA LILIANA TAVER	\N	\N	\N	\N	\N	0 	0 	63489810    	SANDRA LILIANA TAVERA PEREZ             	29	1	1973-12-09	1	calle 147  22-189 QUINTAS DEL PALMAR	3108518206	68276	1	1	0	4	235698	8 	2011-03-02	549	3000000	68001	1	51	0.00	1.00	2012-03-01	0
500	1	37713873	YANETH MENESES BENIT	\N	\N	\N	\N	\N	2 	2 	37713873    	YANETH MENESES BENITEZ                  	16	3	2013-11-28	1	AVENIDA EL TEJAR 104-25 CASA 7	6318127	68001	3	5	0	2	2456120	8 	2014-07-03	550	1000000	68679	0	52	1.00	1.00	2012-03-04	0
501	1	109873300	SANDRA LUCIA ACOSTA 	\N	\N	\N	\N	\N	7 	7 	1098733004  	SANDRA LUCIA ACOSTA GARCIA              	39	3	1993-01-21	1	CRA 26  20-74 EDF. XENIA APTO 401	3214878886	68001	1	5	0	2	2562314	8 	2011-03-05	551	535600	76250	1	52	0.00	1.00	2012-03-04	0
502	1	109962218	TATIANA SIRLEY VILLA	\N	\N	\N	\N	\N	7 	7 	1099622181  	TATIANA SIRLEY VILLAMIZAR               	17	3	1988-07-01	1	CRA 24  24-20 SAN FRANCISCO	6347285	68001	1	5	0	2	23569854	8 	2011-03-17	564	680000	68169	1	52	1.00	1.00	2012-03-16	0
503	1	109936464	SINDY TATIANA HERNAN	\N	\N	\N	\N	\N	3 	3 	1099364647  	SINDY TATIANA HERNANDEZ CARVAJAL        	40	3	1988-06-07	1	CRA 38W  59-16 ESTORAQUES	6416110	68001	3	5	0	2	2546	8 	2011-03-05	553	800000	47245	1	52	1.00	1.00	2012-03-04	0
504	1	109868719	CINDY MARCELA MELGAR	\N	\N	\N	\N	\N	7 	7 	1098687193  	CINDY MARCELA MELGAREJO MAYORGA         	17	3	1990-05-18	1	CRA 28  11-39 SAN ALONSO	6705718	68001	1	1	0	2	235697	8 	2011-03-05	554	535600	68152	1	52	0.00	1.00	2012-03-04	0
505	1	109869394	LISDI BRAJANA RODRIG	\N	\N	\N	\N	\N	0 	0 	1098693946  	LISDI BRAJANA RODRIGUEZ ROMAN           	29	3	1990-10-07	1	CRA 27W  64-53 MONTERREDONDO	3158219263	68001	2	2	0	3	235698	8 	2011-03-09	555	900000	68001	0	52	1.00	1.00	2012-03-08	0
506	1	102074570	YENNY PAOLA CASALLAS	\N	\N	\N	\N	\N	0 	0 	1020745702  	YENNY PAOLA CASALLAS                    	29	1	1989-09-26	1	cra 12  24-59	3115464723	68008	3	5	0	3	236412	8 	2011-02-02	539	750000	25513	1	51	1.00	1.00	2012-02-01	0
507	1	37581582	MAYORLI SALCEDO ARDI	\N	\N	\N	\N	\N	1 	1 	37581582    	MAYORLI SALCEDO ARDILA                  	17	3	1986-01-03	1	CALLE 77  77-46 BELEN	316446961	68081	1	5	0	2	2569845	8 	2011-02-02	540	535600	68081	1	52	0.00	1.00	2012-02-01	0
508	1	109621253	LUIS EDUARDO MARTINE	\N	\N	\N	\N	\N	1 	1 	1096212532  	LUIS EDUARDO MARTINEZ VIANA             	15	3	1991-10-03	2	CALLE 27A  33-16 EL LIMONAR	6030309	68081	1	2	0	2	235698	8 	2011-03-11	557	535600	68081	1	52	0.00	1.00	2012-03-10	0
509	1	109580875	MARIA ALEJANDRA MEND	\N	\N	\N	\N	\N	2 	2 	1095808754  	MARIA ALEJANDRA MENDOZA PICO            	17	3	1991-02-18	1	SECTOR 20  21-17 APTO 113 BUCARICA	6996710	68276	1	1	0	3	235698	8 	2011-03-12	561	535600	68001	1	52	0.00	1.00	2012-03-11	0
510	1	109872910	EDWING MAURICIO HERN	\N	\N	\N	\N	\N	8 	8 	1098729102  	EDWING MAURICIO HERNANDEZ PEDRAZA       	44	3	1992-11-03	2	CRA 26  10-48 LA UNIVERSIDAD	6452063	68001	1	5	0	2	236598	8 	2013-08-27	506	700000	68001	1	52	1.00	1.00	2011-11-30	0
511	1	100496630	FRANKLIN LEONARDO BA	\N	\N	\N	\N	\N	2 	2 	1004966303  	FRANKLIN LEONARDO BALLEN CORONEL        	15	3	1989-06-15	2	CRA 52  102-11 ARRAYANES FLORIDABLANCA	6814668	68276	3	2	0	2	235698542	8 	2013-07-19	556	680000	54001	1	52	1.00	1.00	2012-03-08	0
512	1	112182357	MARIA RUTH PINEDA RA	\N	\N	\N	\N	\N	2 	2 	1121823575  	MARIA RUTH PINEDA RAMIREZ               	17	3	1986-08-09	1	DIAGONAL 34  197A-16 PARAGUITAS	3114679078	68276	1	1	0	3	25698	8 	2011-03-12	562	535600	68001	1	52	0.00	1.00	2012-03-11	0
513	1	109591730	MIGUEL ANGEL SANABRI	\N	\N	\N	\N	\N	3 	3 	1095917302  	MIGUEL ANGEL SANABRIA HERNANDEZ         	15	3	1989-05-05	2	DIAGONAL 9  20-26 ARENALES	3172458758	68307	2	1	0	2	236598	8 	2011-01-15	532	680000	68307	1	52	0.00	1.00	2012-01-14	0
514	1	100794900	WILLIAM MORALES FLOR	\N	\N	\N	\N	\N	1 	1 	1007949009  	WILLIAM MORALES FLOREZ                  	15	3	1985-12-12	2	tryutyiuyiy	415454	68081	2	1	0	5	434	8 	2010-02-01	423	515000	68081	1	52	0.00	1.00	2011-01-31	0
515	1	109869300	ERIKA TATIANA MUSKUS	\N	\N	\N	\N	\N	3 	3 	1098693004  	ERIKA TATIANA MUSKUS GELVEZ             	17	3	1985-12-12	1	gyrtuytuiy	4553	68001	2	1	0	5	1412	8 	2011-03-19	424	535600	68001	1	52	0.00	1.00	2011-01-31	0
516	1	63502338	ELIZABETH PINILLA RI	\N	\N	\N	\N	\N	0 	0 	63502338    	ELIZABETH PINILLA RINCON                	29	1	1974-03-09	1	CRA 40A  105-15 SAN BERNARDO	6773910	68276	1	1	0	2	235698	8 	2011-03-01	563	535600	68001	1	51	0.00	1.00	2012-02-28	0
517	1	104566996	JANETH FORERO RAMIRE	\N	\N	\N	\N	\N	0 	0 	1045669960  	JANETH FORERO RAMIREZ                   	29	1	1988-04-28	1	calle 47 nº 22 - 31	3205416410	68307	1	5	0	3	235698521	8 	2014-02-15	565	1000000	81736	1	51	1.00	1.00	2012-03-21	0
518	1	91534858	ALEXANDER ESTUPIÑAN 	\N	\N	\N	\N	\N	7 	7 	91534858    	ALEXANDER ESTUPIÑAN FLOREZ              	10	3	1984-09-21	2	CRA 12D  103C-19 MANUELA BELTRAN	6376169	68001	1	5	0	2	236598	8 	2011-03-24	566	900000	5615 	1	52	1.00	1.00	2012-03-23	0
519	1	109860457	GLADYS ROCIO BELTRAN	\N	\N	\N	\N	\N	0 	0 	1098604574  	GLADYS ROCIO BELTRAN VILLAMIZAR         	29	3	1985-10-12	1	CRA 18B  15N-67 CASA 4 VILLAROSA	3204473042	68001	1	5	0	3	236598542	8 	2011-03-29	567	4200000	68001	0	52	0.00	1.00	2012-03-27	0
520	1	91277148	JOSE LUIS COA ZORRO 	\N	\N	\N	\N	\N	0 	0 	91277148    	JOSE LUIS COA ZORRO                     	29	1	1975-02-09	2	UR. BOSQUE SEC C AGRUP S TORRE 4 AP 102B	6371119	68276	2	5	0	4	41545454	8 	2011-04-11	569	1500000	68575	0	51	0.00	1.00	2012-04-10	0
521	1	109618374	LUIS JONNATHAN ZULUA	\N	\N	\N	\N	\N	1 	1 	1096183748  	LUIS JONNATHAN ZULUAIKA TORRES          	15	3	1985-11-07	2	calle 36 a nº 77 -55	3143688691	68081	1	5	0	2	55454	8 	2011-04-02	568	535600	68081	1	52	0.00	1.00	2012-04-01	0
522	1	80810289	ANGEL MARIA HERNANDE	\N	\N	\N	\N	\N	7 	7 	80810289    	ANGEL MARIA HERNANDEZ TURCA             	15	3	1984-05-07	2	CALLE 104 Nº 16A - 62	3115849383	68001	2	5	0	3	2553535	8 	2011-04-11	570	535600	1001 	1	52	0.00	1.00	2012-04-10	0
523	1	13569404	OSMAN DE JESUS NAVAR	\N	\N	\N	\N	\N	1 	1 	13569404    	OSMAN DE JESUS NAVARRO MORALES          	15	3	1984-12-15	2	CALLE 52A Nº 41 - 28	3202074817	68081	1	2	0	2	5454545	8 	2011-04-06	571	535600	47707	1	52	0.00	1.00	2011-04-05	0
524	1	28070539	SANDRA PATRICIA CAST	\N	\N	\N	\N	\N	1 	1 	28070539    	SANDRA PATRICIA CASTRILLON GALEANO      	17	3	1981-07-09	1	TRV. 45 Nº 57 - 54	3144856920	68081	2	5	0	2	1424	8 	2011-04-11	572	535600	5579 	1	52	0.00	1.00	2012-04-10	0
525	1	109618602	NELLY MARLEY JARAMIL	\N	\N	\N	\N	\N	4 	4 	1096186026  	NELLY MARLEY JARAMILLO BAUTISTA         	17	3	1985-04-25	1	lkslksjkogj	2545	68081	2	5	0	2	54545	8 	2011-04-14	574	535600	68081	1	52	0.00	1.00	2012-04-13	0
526	1	109861770	LEIDY YUSELY QUIROGA	\N	\N	\N	\N	\N	7 	7 	1098617703  	LEIDY YUSELY QUIROGA DURAN              	17	3	1986-01-06	1	calle 49 n° 9c- 36	6496050	68001	2	5	0	3	5454	8 	2011-04-13	575	535600	68001	1	52	0.00	1.00	2012-04-12	0
527	1	109872137	JURLEY TATIANA MACIA	\N	\N	\N	\N	\N	7 	7 	1098721370  	JURLEY TATIANA MACIAS QUIJANO           	17	4	1992-03-16	1	CALLE 43 N° 26-31	3185397220	68001	1	5	0	2	5465	8 	2009-12-19	576	535600	68001	1	52	0.00	1.00	2012-03-17	0
528	1	110236595	MIKE HENRY SALAZAR A	\N	\N	\N	\N	\N	9 	9 	1102365957  	MIKE HENRY SALAZAR AMAYA                	15	3	1991-03-12	2	CALLE 1A N° 4A -11	6901418	68547	1	5	0	2	5141564	8 	2011-04-16	577	566700	68001	1	52	1.00	1.00	2012-04-15	0
529	1	109868709	LISSETH MAYERLY TORR	\N	\N	\N	\N	\N	3 	3 	1098687096  	LISSETH MAYERLY TORRES LANDAZABAL       	17	3	1990-03-16	1	CALLE 125A N° 66A-35	3168617581	68001	1	5	0	3	54556466	8 	2011-05-05	578	566700	68001	1	52	1.00	1.00	2012-05-04	0
530	1	60261054	NUBIA YADIRA CAÑAS L	\N	\N	\N	\N	\N	4 	4 	60261054    	NUBIA YADIRA CAÑAS LIZCANO              	42	3	1976-06-14	1	carrera 33 n° 71 - 18	3118831512	68001	3	1	0	2	25451541	8 	2011-04-30	580	535600	68001	1	52	0.00	1.00	2012-04-29	0
531	1	109619780	MARIVEL CARDENAS AFA	\N	\N	\N	\N	\N	1 	1 	1096197804  	MARIVEL CARDENAS AFANADOR               	42	3	1988-11-05	1	CALLE 44 N° 59B - 17	321315130	68081	3	2	0	2	645464	8 	2011-05-07	581	535600	68081	1	52	0.00	1.00	2012-05-06	0
532	1	37900833	KATHERINE FIALLO CAS	\N	\N	\N	\N	\N	0 	0 	37900833    	KATHERINE FIALLO CASTRO                 	29	1	1984-01-28	1	CALLE 68B N° 10C-12	3174293213	68001	1	5	0	5	5451236	8 	2011-05-09	582	3000000	68679	1	51	0.00	1.00	2012-05-08	0
533	1	37724507	JOHANNA MILENA CUEVA	\N	\N	\N	\N	\N	0 	0 	37724507    	JOHANNA MILENA CUEVAS CELY              	29	1	1978-05-09	1	CALLE 60C N° 16F - 58	3157347074	68001	2	1	1	4	513213	8 	2011-05-09	583	1200000	68001	1	51	0.00	1.00	2012-05-08	0
534	1	37651994	SOLLEY MONSALVE DIAZ	\N	\N	\N	\N	\N	4 	4 	37651994    	SOLLEY MONSALVE DIAZ                    	17	3	1988-04-05	1	CALLE 30 N° 54-52	6201458	68081	2	1	0	2	5461654	8 	2011-05-08	584	535600	68081	1	52	0.00	1.00	2012-05-07	0
535	1	109579157	CONSTANTINO ROJAS NI	\N	\N	\N	\N	\N	8 	8 	1095791572  	CONSTANTINO ROJAS NIÑO                  	10	3	1985-07-27	2	CR. 19 N° 59-147	6492254	68001	1	5	0	2	65646464	8 	2011-05-12	585	800000	68001	0	52	1.00	1.00	2012-05-11	0
536	1	109620340	IVONNE ELENA GOMEZ R	\N	\N	\N	\N	\N	4 	4 	1096203405  	IVONNE ELENA GOMEZ RODRIGUEZ            	17	3	1989-09-27	1	TRANSVERSAL 45 N° 57-16	3118627861	68081	3	5	0	2	5641554	8 	2011-05-19	586	680000	68081	1	52	1.00	1.00	2012-05-18	0
537	1	109621430	LINDA LUCIA RESTREPO	\N	\N	\N	\N	\N	1 	1 	1096214308  	LINDA LUCIA RESTREPO VILLALBA           	17	4	1992-01-20	1	TV 43 Nº 56 BARRIO PROGRESO I ETAPA	3116854248	68081	1	1	0	2	35454	8 	2011-04-09	573	535600	68081	1	52	0.00	1.00	2012-04-08	0
538	1	109862661	CARLOS ALBERTO VALBU	\N	\N	\N	\N	\N	8 	8 	1098626614  	CARLOS ALBERTO VALBUENA MORENO          	15	3	1986-11-12	2	CR. 27 N° 64-86	6446028	68001	1	5	0	2	2131324	8 	2011-05-26	588	680000	68444	1	52	1.00	1.00	2012-05-25	0
539	1	109581171	ANGY KARELLY TORRES 	\N	\N	\N	\N	\N	2 	2 	1095811713  	ANGY KARELLY TORRES DIAZ                	17	3	1992-03-27	1	SECTOR B TORRE 1 AP 302 BELLAVISTA	6384664	68276	1	5	1	3	11326	8 	2011-05-28	593	535600	68276	1	52	0.00	1.00	2012-05-27	0
540	1	109868290	JENIFER MARCELA NUÑE	\N	\N	\N	\N	\N	0 	0 	1098682904  	JENIFER MARCELA NUÑEZ RUEDA             	29	1	1990-02-24	1	CARRERA 1B CASA 81 CIUDAD BOLIVAR	3182428431	68001	1	5	0	3	54651	8 	2011-06-01	594	650000	68001	1	51	0.00	1.00	2012-05-30	0
541	1	88170940	WILMER FLOREZ       	\N	\N	\N	\N	\N	2 	2 	88170940    	WILMER FLOREZ                           	14	3	1972-10-13	2	CALLE 112 N° 32A - 33	6315606	68001	2	5	2	3	45452112	8 	2011-06-08	597	800000	68001	1	52	0.00	1.00	2012-06-07	0
542	1	109580663	SULAY VIVIANA VARGAS	\N	\N	\N	\N	\N	9 	9 	1095806631  	SULAY VIVIANA VARGAS DUARTE             	17	3	1990-11-10	1	CR. 21 N° 10B-30	6490506	68001	1	1	0	3	5423154	8 	2011-06-14	602	535600	68001	1	52	0.00	1.00	2012-06-13	0
543	1	109869983	ANGIE VANESSA CACERE	\N	\N	\N	\N	\N	0 	0 	1098699834  	ANGIE VANESSA CACERES NOCUA             	29	1	1991-01-27	1	CRA. 12W N° 60 BIS-79	6942111	68001	1	5	0	3	12336	8 	2012-01-16	695	650000	68001	1	51	1.00	1.00	2013-01-15	0
544	1	22524543	LIDYS MILDRED MUNERA	\N	\N	\N	\N	\N	4 	4 	22524543    	LIDYS MILDRED MUNERA CARREÑO            	42	3	1981-03-05	1	CALLE 27A N° 44-37	3007238902	68081	1	5	0	2	45454	8 	2011-04-28	579	535600	8001 	1	52	0.00	1.00	2012-04-27	0
545	1	28359941	NIDIA YESMITH PEDRAZ	\N	\N	\N	\N	\N	9 	9 	28359941    	NIDIA YESMITH PEDRAZA BERNAL            	17	3	1984-11-03	1	AVENICA BUCAROS OESTE 3-11 T 6 AP 502	3124896502	68001	1	5	0	3	4253	8 	2011-05-19	587	535600	68669	1	52	0.00	1.00	2012-05-18	0
546	1	103969115	YOMAIRA ARSENY GUTIE	\N	\N	\N	\N	\N	1 	1 	1039691159  	YOMAIRA ARSENY GUTIERREZ CATAÑO         	34	3	1990-09-05	1	CALLE 63 N° 36D-29	3116212341	68081	2	5	0	3	45132131	8 	2015-01-09	589	1200000	5579 	1	52	1.00	1.00	2012-05-20	0
547	1	109579063	LEIDY DIANA GUALDRON	\N	\N	\N	\N	\N	7 	7 	1095790632  	LEIDY DIANA GUALDRON CETINA             	17	3	1986-09-06	1	CALLE 71B N° 31A-09	3122223562	68276	1	5	0	3	574321	8 	2011-05-26	591	535600	68276	1	52	0.00	1.00	2012-05-25	0
548	1	109869853	NEYLA LIZETH MEDINA 	\N	\N	\N	\N	\N	0 	0 	1098698539  	NEYLA LIZETH MEDINA ACERO               	29	1	1990-11-02	1	CR. 24 N° 31-49	3154505248	68001	1	5	0	4	54654	8 	2011-06-01	595	1500000	68001	0	51	0.00	1.00	2012-05-30	0
549	1	109620198	JESSICA PAOLA BERNAL	\N	\N	\N	\N	\N	4 	4 	1096201988  	JESSICA PAOLA BERNAL YANEZ              	17	3	1988-12-06	1	CALLE 48E  54A-21 VILLARELIS II ETAPA	3114483494	68081	1	5	0	2	2356	8 	2011-02-10	544	566700	68081	1	52	1.00	1.00	2012-02-09	0
550	1	63369610	DORIS JANETH FLOREZ 	\N	\N	\N	\N	\N	7 	7 	63369610    	DORIS JANETH FLOREZ VIVIESCAS           	14	3	1971-12-30	1	CALLE 8 N° 6 - 36	6499057	68001	2	5	0	4	432	8 	2011-05-26	590	800000	68001	1	52	0.00	1.00	2012-05-25	0
551	1	109621424	JORGE IVAN BASTIDA B	\N	\N	\N	\N	\N	1 	1 	1096214247  	JORGE IVAN BASTIDA BEDOYA               	15	3	1991-12-09	2	BARRIO TIERRADENTRO MANZANA B CASA 18	6021069	68081	1	5	0	2	2569845	8 	2011-03-11	558	566700	68081	1	52	1.00	1.00	2012-03-10	0
552	1	109864563	MARIA YESENIA ULLOA 	\N	\N	\N	\N	\N	9 	9 	1098645631  	MARIA YESENIA ULLOA RUEDA               	15	3	1987-11-21	1	CRA 5  24-38	6330132	68001	1	1	0	3	235698	8 	2011-03-12	559	535600	68001	1	52	0.00	1.00	2012-03-11	0
553	1	91523755	EDWIN ALFREDO BENITE	\N	\N	\N	\N	\N	9 	9 	91523755    	EDWIN ALFREDO BENITEZ CASTRO            	15	3	1983-11-09	2	CALLE 12B  23-39 RIO PRADO	6593789	68307	1	5	0	2	23569854	8 	2011-03-12	560	566700	68001	1	52	1.00	1.00	2012-03-11	0
554	1	109936352	JENNY PAOLA OCHOA RU	\N	\N	\N	\N	\N	7 	7 	1099363529  	JENNY PAOLA OCHOA RUEDA                 	17	3	1987-04-14	1	CR. 5 N° 12-36	3156908761	68406	1	5	0	3	21103	8 	2011-07-02	603	566700	68406	1	52	1.00	1.00	2012-06-13	0
555	1	109868666	OSCAR ORLANDO BAUTIS	\N	\N	\N	\N	\N	9 	9 	1098686663  	OSCAR ORLANDO BAUTISTA MALDONADO        	15	3	1990-05-13	2	CR. 13 N° 65 - 39	6479426	68001	1	5	1	3	223154	8 	2011-06-18	604	535600	68001	1	52	0.00	1.00	2012-06-17	0
556	1	109869076	ZAIDA CATALINA RAMIR	\N	\N	\N	\N	\N	9 	9 	1098690764  	ZAIDA CATALINA RAMIREZ CACERES          	17	3	1990-08-06	1	CONJUNTO RESIDENCIAS ACROPOLIS T.3 AP 13	6414345	68001	1	5	0	3	545421	8 	2011-06-22	605	535600	68001	1	52	0.00	1.00	2012-06-21	0
557	1	109620867	YEISON ALEXANDER CAR	\N	\N	\N	\N	\N	1 	1 	1096208674  	YEISON ALEXANDER CARREÑO PEREZ          	15	3	1990-11-27	2	CARRERA 37 A N° 52-68	3132870300	68081	1	5	0	2	454545	8 	2011-07-06	608	535600	68081	1	52	0.00	1.00	2012-07-06	0
558	1	109621113	FABIAN ANDRES RIOS O	\N	\N	\N	\N	\N	4 	4 	1096211137  	FABIAN ANDRES RIOS ORTIZ                	33	3	1991-06-18	2	PEATONAL 7 N° 36E - 21 VILLA ROSITA	6101556	68081	1	2	0	3	41544	8 	2011-07-06	611	1050000	68081	0	52	1.00	1.00	2012-07-06	0
559	1	109593068	ANA MARIA LINARES PE	\N	\N	\N	\N	\N	9 	9 	1095930684  	ANA MARIA LINARES PEREIRA               	60	3	1992-07-25	1	CALLE 33 N° 15-48	6468818	68307	1	1	0	3	4545	8 	2011-07-12	615	700000	68307	1	52	1.00	1.00	2012-07-11	0
560	1	109871132	LUISA FERNANDA GUTIE	\N	\N	\N	\N	\N	7 	7 	1098711322  	LUISA FERNANDA GUTIERREZ JAIMES         	15	3	1991-09-25	1	CR. 18 N° 48-65	6424164	68001	1	3	0	3	4613214	8 	2011-05-26	592	566700	68001	1	52	1.00	1.00	2012-05-25	0
561	1	13870438	CARLOS ANDRES SUAREZ	\N	\N	\N	\N	\N	3 	3 	13870438    	CARLOS ANDRES SUAREZ FRANCO             	13	3	1981-07-15	2	CALLE 17 N° 31-34	3173988648	68001	2	5	1	4	54521	8 	2011-07-12	616	800000	68081	1	52	1.00	1.00	2012-07-11	0
562	1	91542854	DIEGO FABIAN VELASQU	\N	\N	\N	\N	\N	7 	7 	91542854    	DIEGO FABIAN VELASQUEZ CAÑAS            	13	3	1985-07-16	2	CRA. 16 N° 108-21 CAMPO REAL	6374569	68001	1	5	0	4	123456	8 	2011-08-01	617	1300000	68001	1	52	0.00	1.00	2012-07-31	0
563	1	37390146	YULY ANDREA DIAZ SUA	\N	\N	\N	\N	\N	9 	9 	37390146    	YULY ANDREA DIAZ SUAREZ                 	17	3	1983-08-12	1	CRA. 8 N° 60-113 CASA 87 PARQUE SAN REMO	3172911931	68001	2	1	1	3	123456	8 	2011-08-06	618	535600	68001	1	52	0.00	1.00	2012-08-05	0
564	1	109619390	DIANA CRISTINA CASTA	\N	\N	\N	\N	\N	1 	1 	1096193904  	DIANA CRISTINA CASTAÑO CASTRO           	17	3	1988-01-07	1	CR. 4 N° 6A - 19	3105215166	68081	1	5	0	2	546545	8 	2011-08-11	621	680000	68081	1	52	1.00	1.00	2012-08-10	0
565	1	63529046	ROSA ADELINA ARENIS 	\N	\N	\N	\N	\N	0 	0 	63529046    	ROSA ADELINA ARENIS HERNANDEZ           	29	1	1982-04-07	1	CRA. 6 N° 28-48 T-1 AP904	3104924961	68001	2	2	0	4	123456	8 	2011-08-16	624	1200000	68780	1	51	0.00	1.00	2012-08-15	0
566	1	106771547	GABRIEL ALEXANDER RO	\N	\N	\N	\N	\N	4 	4 	1067715477  	GABRIEL ALEXANDER ROLDAN MEJIA          	15	4	1988-05-23	2	DIAGONAL 58 N° 20-56	3205518924	68081	3	5	2	2	123456	8 	2011-08-17	626	680000	68001	1	52	1.00	1.00	2012-08-16	0
904	1	37658407	RUBIELA GOMEZ BELTRA	\N	\N	\N	\N	\N	0 	0 	37658407    	RUBIELA GOMEZ BELTRAN                   	29	3	1972-03-04	1	1	1	68001	2	1	0	5	2156	32	2013-11-19	984	2500000	68001	0	52	0.00	1.00	2014-05-10	0
567	1	105677352	LICETH LORENA OSORIO	\N	\N	\N	\N	\N	1 	1 	1056773529  	LICETH LORENA OSORIO MORENO             	17	3	1989-02-20	1	CALLE 53 N° 14-17	3115011103	68081	1	1	1	3	12233	8 	2012-08-02	629	566700	68081	1	52	1.00	1.00	2012-08-22	0
568	1	109622156	YARE MARCELA SANGUIN	\N	\N	\N	\N	\N	4 	4 	1096221566  	YARE MARCELA SANGUINO PLATA             	17	3	1991-11-22	1	AV FERTILIZANTES CASA 67	6031197	68081	1	1	0	3	1223	8 	2011-08-26	630	535600	68092	1	52	0.00	1.00	2012-08-25	0
569	1	63452696	LEIDY DIANA LOZANO G	\N	\N	\N	\N	\N	2 	2 	63452696    	LEIDY DIANA LOZANO GARCIA               	17	3	1982-08-06	1	CALLE 202B N° 28-22	6498824	68276	2	5	1	2	545415	8 	2011-06-30	609	680000	68001	1	52	1.00	1.00	2012-06-29	0
570	1	109730402	LEIDY TAMI ANAYA    	\N	\N	\N	\N	\N	2 	2 	1097304024  	LEIDY TAMI ANAYA                        	17	3	1990-05-08	1	CR. 9 N° 7-33	3187653305	68276	2	5	1	2	63454	8 	2011-07-05	610	566700	68255	1	52	1.00	1.00	2012-07-04	0
571	1	104221246	LAURA URIBE BELEÑO  	\N	\N	\N	\N	\N	1 	1 	1042212467  	LAURA URIBE BELEÑO                      	17	3	1992-04-04	1	BARRIO EL PARAISO	3134635629	68081	1	2	0	3	1233	8 	2012-04-02	632	566700	68081	1	52	1.00	1.00	2012-08-26	0
572	1	109620200	CRISTIAN CAMILO SERR	\N	\N	\N	\N	\N	4 	4 	1096202007  	CRISTIAN CAMILO SERRANO PEREZ           	15	3	1989-11-02	2	cra. 36H N° 50-25	3204267328	68081	1	1	0	3	123456	8 	2011-08-02	619	535600	68001	1	52	0.00	1.00	2012-08-01	0
573	1	110168975	LUZ EDITH VILLAMIL H	\N	\N	\N	\N	\N	9 	9 	1101689753  	LUZ EDITH VILLAMIL HERRERA              	17	3	1991-08-31	1	CALLE 48 N° 26-62 POBLADO	3142693366	68001	1	1	0	3	123456	8 	2011-08-04	620	566700	68001	1	52	1.00	1.00	2012-08-03	0
574	1	109593031	LEIDY PAOLA MEJIA GU	\N	\N	\N	\N	\N	1 	1 	1095930316  	LEIDY PAOLA MEJIA GUALDRON              	17	3	1992-10-08	1	CALLE 59A N° 45 -19	3155635790	68081	1	1	0	2	5465454	8 	2011-08-11	622	535600	68081	1	52	0.00	1.00	2012-08-10	0
575	1	109866549	LAURA MARCELA SILVA 	\N	\N	\N	\N	\N	9 	9 	1098665494  	LAURA MARCELA SILVA LARROTTA            	10	3	1989-01-01	1	CR. 12 N° 11 - 57	3013576218	68001	1	5	0	3	54123143	8 	2011-06-01	598	700000	68001	1	52	1.00	1.00	2012-05-30	0
576	1	109869430	LILIANA ROJAS BARON 	\N	\N	\N	\N	\N	2 	2 	1098694301  	LILIANA ROJAS BARON                     	17	3	1990-10-15	1	CRA. 7E N° 35 CASA 15	3154938037	68001	1	6	1	3	123456	8 	2013-03-02	628	680000	68001	1	52	1.00	1.00	2012-08-23	0
577	1	109619654	KAREN LICETH RADA GU	\N	\N	\N	\N	\N	1 	1 	1096196544  	KAREN LICETH RADA GUTIERREZ             	39	3	1988-09-15	1	CARRERA 9A N° 48-43	3105503392	68081	1	5	0	2	12233	8 	2011-08-27	631	680000	68081	0	52	1.00	1.00	2012-08-26	0
578	1	109867546	DIANA MARCELA BERNAL	\N	\N	\N	\N	\N	7 	7 	1098675462  	DIANA MARCELA BERNAL MARTINEZ           	17	3	1989-09-10	1	CALLE 11 N°27-45	3115756020	68001	3	5	0	2	121255	8 	2011-09-06	634	566700	68679	1	52	0.00	1.00	2012-09-05	0
579	1	80114933	JOHN JAIRO BERNAL RE	\N	\N	\N	\N	\N	0 	0 	80114933    	JOHN JAIRO BERNAL REYES                 	29	3	1982-02-04	2	CRA. 13A N° 103-19	3184527676	68001	1	6	0	4	123455	8 	2013-05-19	639	2800000	1001 	1	52	0.00	1.00	2012-08-30	0
580	1	110271699	ORANGEL INFANTE ROJA	\N	\N	\N	\N	\N	7 	7 	1102716990  	ORANGEL INFANTE ROJAS                   	15	3	1988-03-23	2	CALLE 13 N° 29-47	3125283913	68001	1	5	1	3	54124	8 	2011-07-18	606	535600	68001	1	52	0.00	1.00	2012-06-16	0
581	1	109621722	ANGIE KATERINE PEREZ	\N	\N	\N	\N	\N	1 	1 	1096217223  	ANGIE KATERINE PEREZ CAMPOS             	17	3	1992-08-05	1	CALLE 46 N° 59A - 11	3105148574	68081	1	5	0	2	213132	8 	2011-07-09	613	566700	68001	1	52	1.00	1.00	2012-07-08	0
582	1	63451521	AURA ISABEL RAPALINO	\N	\N	\N	\N	\N	1 	1 	63451521    	AURA ISABEL RAPALINO ARIAS              	60	3	1980-11-11	1	CALLE 2C ESTE N°7-50 P-2	8900631	68081	1	1	2	3	31313	8 	2011-07-02	612	700000	68081	1	52	1.00	1.00	2012-06-30	0
583	1	109619829	MARISOL MATIZ SARMIE	\N	\N	\N	\N	\N	1 	1 	1096198292  	MARISOL MATIZ SARMIENTO                 	17	3	1989-01-15	1	DIAGONAL 58 N° 43-170	6028222	68081	1	5	0	3	45132	8 	2011-08-20	614	535600	68081	1	52	0.00	1.00	2012-07-08	0
584	1	109591660	LAURA MILENA FEO GEL	\N	\N	\N	\N	\N	9 	9 	1095916602  	LAURA MILENA FEO GELVES                 	39	3	1988-04-04	1	CALLE 19 PEATONAL 2 SUR 08	3164318497	68001	1	5	0	2	12333	8 	2011-08-12	623	680000	68001	1	52	1.00	1.00	2012-08-11	0
585	1	37713943	JAQUELINE SUAREZ NAV	\N	\N	\N	\N	\N	3 	3 	37713943    	JAQUELINE SUAREZ NAVARRO                	17	3	1977-10-17	1	CALLE 22 N° 26-112 PISO 2	3175330244	68001	1	5	1	2	541264	8 	2011-06-01	596	566700	68001	1	52	1.00	1.00	2012-05-30	0
586	1	109867536	MIGUEL ANGEL LEAÑO J	\N	\N	\N	\N	\N	7 	7 	1098675366  	MIGUEL ANGEL LEAÑO JAIMES               	43	3	1989-09-06	2	CALLE 19 N° 22-15	6454066	68001	1	1	0	3	451321	8 	2011-06-01	599	535600	68001	1	52	0.00	1.00	2012-05-30	0
587	1	109871136	JONATHAN LEONARDO AL	\N	\N	\N	\N	\N	7 	7 	1098711363  	JONATHAN LEONARDO ALONSO MARTINEZ       	43	3	1991-09-25	2	CALLE 19 N° 6 - 34	6406900	68001	2	5	0	3	246541	8 	2011-06-20	607	535600	68001	1	52	0.00	1.00	2012-06-19	0
588	1	104961394	JESICA ANDREA APONTE	\N	\N	\N	\N	\N	7 	7 	1049613946  	JESICA ANDREA APONTE AGUIRRE            	17	3	1988-07-30	1	CALLE 48 N° 2A OCCIDENTE 18	3115675749	68001	1	1	0	3	21231	8 	2011-06-08	600	535600	1001 	1	52	0.00	1.00	2012-06-07	0
589	1	109579845	YASMID DEL ROSARIO V	\N	\N	\N	\N	\N	2 	2 	1095798459  	YASMID DEL ROSARIO VILLAMIZAR SIERRA    	17	3	1988-12-26	1	CRA. 7E N° 28-16	3157789498	68001	3	1	1	3	1252525	8 	2011-09-16	641	535600	68001	1	52	0.00	1.00	2012-09-15	0
590	1	111293221	ERIKA OSORIO MURCIA 	\N	\N	\N	\N	\N	3 	3 	1112932219  	ERIKA OSORIO MURCIA                     	17	3	1990-10-17	0	CRA. 26 N° 21-74 AP 401	3105033533	68001	1	5	0	3	3321455	8 	2011-09-17	642	535600	68001	1	52	0.00	1.00	2012-09-16	0
591	1	109619645	FREDY ESNEIDER AGUAS	\N	\N	\N	\N	\N	1 	1 	1096196457  	FREDY ESNEIDER AGUAS GALINDO            	15	3	1988-07-28	2	CRA. 34A N° 44-68	6222222	68081	1	1	0	3	12525	8 	2011-09-26	644	535600	68081	1	52	0.00	1.00	2012-09-25	0
592	1	13742114	JOSE ROBERTO ALVAREZ	\N	\N	\N	\N	\N	7 	7 	13742114    	JOSE ROBERTO ALVAREZ ALVAREZ            	35	3	1980-05-20	2	CALLE 47 N° 29-15	6530008	68001	1	2	0	3	252525	8 	2011-11-17	645	680000	68001	1	52	0.00	1.00	2012-09-30	0
593	1	110089276	JHON FERNEY RODRIGUE	\N	\N	\N	\N	\N	7 	7 	1100892765  	JHON FERNEY RODRIGUEZ JAIMES            	35	3	1991-08-18	2	FINCA EL KIOSKO VDA VEGA CARREÑO	3168872606	68001	1	1	0	2	236565	8 	2011-10-22	654	680000	68615	1	52	1.00	1.00	2012-10-21	0
594	1	109871639	YESICA YULIET VARGAS	\N	\N	\N	\N	\N	12	12	1098716392  	YESICA YULIET VARGAS PIÑA               	17	3	1991-11-05	1	CALLE 10 N° 10-13	3166380101	68001	1	5	0	3	123123	8 	2011-11-03	658	680000	68001	0	52	1.00	1.00	2012-11-02	0
595	1	63536045	ALBA LUCIA GARZON LO	\N	\N	\N	\N	\N	12	12	63536045    	ALBA LUCIA GARZON LOPEZ                 	16	3	1982-07-19	1	CRA. 3 N° 2-126 CASA 14	3188750586	68001	3	6	1	3	123123	8 	2015-01-02	665	1000000	68001	0	52	1.00	1.00	2012-11-10	0
596	1	109580286	MARIA BELEN IBARRA R	\N	\N	\N	\N	\N	7 	7 	1095802868  	MARIA BELEN IBARRA ROPERO               	17	3	1989-08-30	1	SECTOR 4 TORRE 125 AP 504	6192827	68001	1	5	0	3	252525	8 	2011-11-23	670	680000	68001	1	52	1.00	1.00	2012-11-22	0
597	1	109578732	EDINSON PEREIRA DELG	\N	\N	\N	\N	\N	8 	8 	1095787323  	EDINSON PEREIRA DELGADO                 	15	3	1986-02-16	2	CRA. 66 N° 125-45	3168154500	68001	1	5	0	3	1252525	8 	2011-11-24	671	680000	68001	1	52	1.00	1.00	2012-11-23	0
598	1	57299385	ELIZABETH BAYONA ROJ	\N	\N	\N	\N	\N	10	10	57299385    	ELIZABETH BAYONA ROJAS                  	16	3	1984-03-11	1	CALLE 1B N° 16-68	3007000862	68001	2	5	0	3	125525	8 	2011-09-24	643	1100000	68001	0	52	1.00	1.00	2011-09-24	0
599	1	110089081	CLAUDIA PATRICIA CRU	\N	\N	\N	\N	\N	8 	8 	1100890816  	CLAUDIA PATRICIA CRUZ MARTINEZ          	17	3	1988-09-26	1	CALLE 41 N° 22-69	3163712635	68001	2	1	0	2	20525	8 	2011-11-23	673	566700	52693	1	52	1.00	1.00	2012-11-22	0
600	1	109865814	DIANA OBANDO RESTREP	\N	\N	\N	\N	\N	0 	0 	1098658145  	DIANA OBANDO RESTREPO                   	29	1	1988-08-21	1	CRA. 24 n° 80-12 CJTO NEPTUNO TORRE 3 AP	6941206	68001	2	3	0	4	252525	8 	2011-11-25	678	800000	68001	1	51	1.00	1.00	2012-11-24	0
601	1	109591320	VIVIANA PATRICIA PER	\N	\N	\N	\N	\N	9 	9 	1095913200  	VIVIANA PATRICIA PEREZ PEREZ            	17	3	1989-06-06	1	CALLE 44 N° 16-53	6460526	68307	1	5	0	2	252525	8 	2011-12-02	679	566700	68307	1	52	1.00	1.00	2012-12-01	0
602	1	109862423	MARIA DEL PILAR RODR	\N	\N	\N	\N	\N	7 	7 	1098624232  	MARIA DEL PILAR RODRIGUEZ RUEDA         	20	3	1986-10-28	1	CALLE 41 N°33-13 AP 502B ED. MIRAGE	3182436016	68001	2	1	0	4	25252	8 	2011-12-02	683	1300000	68001	1	52	0.00	1.00	2012-12-01	0
603	1	37713938	BELKY MAYERLY RODRIG	\N	\N	\N	\N	\N	0 	0 	37713938    	BELKY MAYERLY RODRIGUEZ CARDENAS        	29	1	1978-10-21	1	TV OR. CJ PIEMONTI T. 16 AP 402	3182819844	68001	1	1	0	4	252525	8 	2011-10-04	646	2000000	68001	1	52	0.00	1.00	2012-10-03	0
604	1	109865532	DANIEL ENRIQUE LOZAN	\N	\N	\N	\N	\N	7 	7 	1098655323  	DANIEL ENRIQUE LOZANO MUÑOZ             	15	3	1988-07-15	2	CRA. 41w N° 59-59	6416220	68001	3	5	1	2	11222	8 	2011-10-13	648	566700	68001	1	52	1.00	1.00	2012-10-12	0
605	1	109864617	FABIO ALONSO RIVERO 	\N	\N	\N	\N	\N	2 	2 	1098646174  	FABIO ALONSO RIVERO CASTAÑO             	15	3	1987-12-03	2	CALLE 14 N° 11-64	6990675	68001	1	5	0	2	121251	8 	2011-10-13	651	566700	68001	1	52	1.00	1.00	2012-10-12	0
606	1	110237057	DIANA MARCELA TORRES	\N	\N	\N	\N	\N	1 	1 	1102370573  	DIANA MARCELA TORRES NIETO              	17	3	1993-01-20	1	CRA. 17A N° 55-39	3186261605	68081	1	5	0	3	3352	8 	2011-10-15	652	566700	68547	1	52	1.00	1.00	2012-10-14	0
607	1	63562172	LUZ STELLA MENDOZA H	\N	\N	\N	\N	\N	7 	7 	63562172    	LUZ STELLA MENDOZA HERNANDEZ            	39	3	1985-06-11	1	CARRERA 17 N° 6-45	3117354974	68001	1	5	0	3	123654	8 	2011-10-22	655	680000	68001	1	52	1.00	1.00	2012-10-21	0
608	1	63559386	MARIELA HERNANDEZ GO	\N	\N	\N	\N	\N	9 	9 	63559386    	MARIELA HERNANDEZ GOMEZ                 	17	3	1985-04-21	1	SECTOR S TORRE 11 AP 104A	6396473	68001	0	5	0	3	122552	8 	2011-10-22	656	680000	68001	0	52	1.00	1.00	2012-10-21	0
609	1	110470067	DIEGO ARMANDO CORTES	\N	\N	\N	\N	\N	4 	4 	1104700671  	DIEGO ARMANDO CORTES RETAVISCA          	15	3	1989-06-01	2	CRA. 23 N° 77B-04	3163021418	68081	1	5	0	2	123123	8 	2011-11-02	659	680000	73411	1	52	1.00	1.00	2012-11-01	0
610	1	109581237	ANDREA PAOLA AVILA U	\N	\N	\N	\N	\N	2 	2 	1095812374  	ANDREA PAOLA AVILA USECHE               	17	3	1992-06-20	1	CRA. 2E N° 32-126	3213658728	68001	1	5	0	2	125525	8 	2012-02-17	666	566700	1001 	1	52	1.00	1.00	2012-11-10	0
611	1	109580538	YICED MAYERLY BAYONA	\N	\N	\N	\N	\N	2 	2 	1095805383  	YICED MAYERLY BAYONA MARTINEZ           	17	3	1990-06-26	1	CALLE 110 N° 34-09	3154593114	68001	1	1	0	2	122363	8 	2011-07-02	635	566700	68679	1	52	1.00	1.00	2012-09-08	0
612	1	91513363	JOSE ANAEL CADENA CA	\N	\N	\N	\N	\N	3 	3 	91513363    	JOSE ANAEL CADENA CARVAJAL              	10	3	1982-11-05	2	CALLE 15 NA N° 19A-17 MZ 5	3168408883	68001	3	5	4	3	25255	8 	2011-11-11	667	700000	68001	1	52	1.00	1.00	2012-11-10	0
613	1	112240542	IRINA PAOLA ARIAS MA	\N	\N	\N	\N	\N	1 	1 	1122405421  	IRINA PAOLA ARIAS MARTINEZ              	17	3	1990-09-23	1	CALLE 57 N° 21-55	3144234540	68081	1	5	0	2	252525	8 	2013-03-28	669	680000	68081	1	52	1.00	1.00	2012-11-11	0
614	1	109621229	MARIA ALEJANDRA MURI	\N	\N	\N	\N	\N	4 	4 	1096212299  	MARIA ALEJANDRA MURILLO NORIEGA         	17	3	1991-06-20	1	CALLE 52 N° 37A-26	3142322247	68081	1	5	0	2	152525	8 	2012-07-03	672	680000	68081	1	52	1.00	1.00	2012-11-18	0
615	1	109579520	JOHANNA ANDREA LARRO	\N	\N	\N	\N	\N	2 	2 	1095795201  	JOHANNA ANDREA LARROTTA RODRIGUEZ       	17	3	1988-03-20	1	SECTOR 13 BLOQUE 18-11 AP 302	3178754490	68001	1	2	0	3	124255	8 	2011-11-24	674	680000	68001	1	52	1.00	1.00	2012-11-23	0
616	1	109622187	LUZ ANGELICA AHUMADA	\N	\N	\N	\N	\N	4 	4 	1096221876  	LUZ ANGELICA AHUMADA ORTIZ              	17	3	1993-04-27	1	CALLE 33 N°39-36	6106815	68081	1	1	0	2	123554	8 	2012-07-03	640	680000	68081	1	52	1.00	1.00	2012-09-07	0
617	1	91512109	GABRIEL CARREÑO CALA	\N	\N	\N	\N	\N	7 	7 	91512109    	GABRIEL CARREÑO CALA                    	15	3	1982-03-29	2	CALLE 82 CASA 2 ALTOS DEL CACIQUE	3154609279	68001	1	5	0	2	123123	8 	2011-11-01	660	566700	68655	1	52	1.00	1.00	2012-10-30	0
618	1	91438366	WISTON SANCHEZ CAMPU	\N	\N	\N	\N	\N	1 	1 	91438366    	WISTON SANCHEZ CAMPUZANO                	15	3	1970-02-25	2	CALLE 64 N° 36D-84	3124139151	68081	2	1	2	2	556855	8 	2011-11-11	668	535600	68745	1	52	0.00	1.00	2012-11-10	0
619	1	109591291	JHONNATAN FERNEY QUI	\N	\N	\N	\N	\N	3 	3 	1095912918  	JHONNATAN FERNEY QUINTERO ORTIZ         	10	3	1988-01-30	2	CRA. 21 N° 15-29	3168603252	68001	1	5	0	3	123456	8 	2011-08-16	625	700000	68001	1	52	1.00	1.00	2012-08-15	0
620	1	109581360	ARNEY GUTIERREZ ROSA	\N	\N	\N	\N	\N	3 	3 	1095813605  	ARNEY GUTIERREZ ROSAS                   	15	3	1992-10-04	2	CR. 60 N° 5- 41	6495621	68001	1	5	0	2	654123	8 	2011-06-11	601	535600	68001	1	52	0.00	1.00	2012-06-10	0
621	1	109869829	FREDY ARMANDO RODRIG	\N	\N	\N	\N	\N	3 	3 	1098698292  	FREDY ARMANDO RODRIGUEZ RINCON          	15	3	1990-09-06	2	CALLE 103B N° 40-06	6495636	68001	1	5	0	2	121321	8 	2013-04-18	649	680000	68001	1	52	1.00	1.00	2012-10-12	0
622	1	13834794	JESUS CABEZAS HERRER	\N	\N	\N	\N	\N	0 	0 	13834794    	JESUS CABEZAS HERRERA                   	29	1	1956-03-31	2	CALLE 62 N° 45-78	3177535654	68001	2	1	1	4	14441	8 	2011-10-03	647	2000000	68001	1	51	0.00	1.00	2012-10-02	0
623	1	109581617	SOLCIDET QUINTERO CA	\N	\N	\N	\N	\N	8 	8 	1095816175  	SOLCIDET QUINTERO CASTILLO              	17	3	1993-07-01	1	RUITOQUE ALTO TRES ESQUINAS	3153339290	68001	1	1	0	2	1233	8 	2011-09-09	636	535600	68276	1	52	0.00	1.00	2012-09-08	0
624	1	109580755	YESSICA JULIANA VARG	\N	\N	\N	\N	\N	2 	2 	1095807557  	YESSICA JULIANA VARGAS SUAREZ           	60	3	1990-12-28	1	CALLE 205 N° 40-187	3175473691	68001	1	5	0	2	123655	8 	2011-10-23	657	680000	68001	1	52	1.00	1.00	2012-10-22	0
625	1	109866565	CINDY JOHANA ALMEIDA	\N	\N	\N	\N	\N	0 	0 	1098665658  	CINDY JOHANA ALMEIDA BARAJAS            	29	1	1988-10-02	1	CALLE 28 N° 1-01	6582922	68001	1	7	0	3	12233	8 	2011-08-19	627	1800000	68001	0	51	0.00	1.00	2012-08-19	0
626	1	106537310	BLADIMIR LOPEZ MARTE	\N	\N	\N	\N	\N	1 	1 	1065373103  	BLADIMIR LOPEZ MARTEZ                   	15	3	1986-05-02	2	AV. 52 N° 59-45	3208156779	68081	1	5	0	2	252525	8 	2011-12-01	684	680000	23464	1	52	1.00	1.00	2012-11-30	0
627	1	91245593	OSCAR ANGULO ALMARIO	\N	\N	\N	\N	\N	0 	0 	91245593    	OSCAR ANGULO ALMARIO                    	29	1	1966-02-20	2	CRA. 17B N° 14C-13	3115465494	68001	2	5	2	3	363636	8 	2011-12-01	685	1200000	68001	0	51	1.00	1.00	2012-11-30	0
628	1	109590825	JENNY ROCIO LEAL MUR	\N	\N	\N	\N	\N	9 	9 	1095908259  	JENNY ROCIO LEAL MURILLO                	17	3	1986-03-15	1	CRA. 10 N° 22-18	3156046114	68001	1	5	0	3	205255	8 	2011-12-07	687	680000	68001	0	52	1.00	1.00	2012-12-06	0
629	1	109618402	JEAN CARLOS ALCOCER 	\N	\N	\N	\N	\N	1 	1 	1096184025  	JEAN CARLOS ALCOCER NARVAEZ             	15	3	1986-02-11	2	CRA. 21 N° 46-59	3128445089	68081	1	5	1	2	1231414	8 	2011-12-01	688	566700	68081	1	52	1.00	1.00	2011-12-01	0
630	1	109866699	MARIBEL ARIZMENDI RA	\N	\N	\N	\N	\N	9 	9 	1098666992  	MARIBEL ARIZMENDI RAMIREZ               	17	3	1987-11-20	1	CASA 25 MZ D SECTOR 5 CRISTAL BAJO	3172181014	68001	3	1	0	3	252525	8 	2011-12-10	690	535600	68001	1	52	0.00	1.00	2012-12-09	0
631	1	79901766	FABIAN ANDRES SOLANO	\N	\N	\N	\N	\N	9 	9 	79901766    	FABIAN ANDRES SOLANO OCAMPO             	16	3	1978-03-11	2	CALLE 57A N° 20-90	3133552680	68001	2	1	1	3	1252525	8 	2011-12-16	692	800000	68001	1	52	1.00	1.00	2012-12-15	0
632	1	91520950	JUAN FRANCISCO GARZO	\N	\N	\N	\N	\N	2 	2 	91520950    	JUAN FRANCISCO GARZON ZAMBRANO          	14	3	1983-06-13	2	CALLE 103B N° 16A-57	3123124320	68001	1	1	0	3	2141444	8 	2012-01-04	693	800000	68001	1	52	1.00	1.00	2012-12-19	0
633	1	37863968	OLGA LUCIA ALVAREZ V	\N	\N	\N	\N	\N	0 	0 	37863968    	OLGA LUCIA ALVAREZ VASQUEZ              	29	1	1980-08-09	1	CALLE 40 N° 19-32 BLOQUE 1 AP 501	6533932	68307	1	5	1	3	252525	8 	2012-01-16	696	650000	13001	1	51	1.00	1.00	2013-01-15	0
634	1	109864777	INGRID CAROLINA URIB	\N	\N	\N	\N	\N	7 	7 	1098647773  	INGRID CAROLINA URIBE PAEZ              	17	3	1987-12-31	1	CALLE 101A N° 42-08	6772284	68001	1	6	0	3	252525	8 	2012-01-25	698	566700	68001	1	52	1.00	1.00	2013-01-24	0
635	1	63563464	ANGEL CAROLINA MARTI	\N	\N	\N	\N	\N	7 	7 	63563464    	ANGEL CAROLINA MARTINEZ PORRAS          	17	3	1985-08-03	1	CALLE 18 N° 32A-49	3205464194	68001	1	5	0	2	252525	8 	2012-02-23	703	566700	68001	1	52	1.00	1.00	2013-02-22	0
636	1	109869433	KAREN JULIETH ATENCI	\N	\N	\N	\N	\N	8 	8 	1098694338  	KAREN JULIETH ATENCIO PEREA             	34	3	1990-10-18	1	CRA. 5 N° 9-50	3156806424	68001	1	1	1	2	2525	8 	2013-07-04	707	1000000	68001	1	52	1.00	1.00	2013-03-04	0
637	1	109593109	JUAN CARLOS TAPIAS O	\N	\N	\N	\N	\N	9 	9 	1095931090  	JUAN CARLOS TAPIAS OSORIO               	15	3	1993-01-04	2	CRA. 20A N° 56-26 PALENQUE	3165575404	68001	1	2	0	2	2525	8 	2012-03-06	709	566700	68001	1	52	1.00	1.00	2013-03-05	0
638	1	91538015	EMANUEL ANDRES BERNA	\N	\N	\N	\N	\N	9 	9 	91538015    	EMANUEL ANDRES BERNAL MAYORGA           	15	3	1985-03-20	2	BLOQUE 28 AP 301 COLSEGUROS	3175672282	68001	1	5	0	2	2525	8 	2012-03-08	710	566700	68001	1	52	1.00	1.00	2013-03-06	0
639	1	109622699	ANGIE JULIETH MIZAR 	\N	\N	\N	\N	\N	4 	4 	1096226990  	ANGIE JULIETH MIZAR TOLOZA              	17	3	1994-04-10	1	AV. 52 N° 34-85	3106586837	68081	1	5	0	2	2525	8 	2012-04-20	726	566700	68081	1	52	1.00	1.00	2013-04-19	0
640	1	109620276	YURLEY ANDREA BELTRA	\N	\N	\N	\N	\N	1 	1 	1096202766  	YURLEY ANDREA BELTRAN HERNANDEZ         	17	3	1989-12-26	1	CRA. 35 N° 75 BIS-07	3214742543	68081	1	5	0	2	2525	8 	2012-04-24	727	680000	68081	1	52	1.00	1.00	2013-04-23	0
641	1	37721148	VIRSA VASQUEZ NIÑO  	\N	\N	\N	\N	\N	7 	7 	37721148    	VIRSA VASQUEZ NIÑO                      	39	3	1978-11-13	1	CALLE 30 N° 9OCC-05	3173381911	68001	2	5	4	2	2525	8 	2012-04-26	729	566700	68001	1	52	1.00	1.00	2013-04-25	0
642	1	109873976	GRACE JULIANA MORENO	\N	\N	\N	\N	\N	7 	7 	1098739769  	GRACE JULIANA MORENO ARENAS             	17	3	1993-06-19	1	CALLE 14 N° 30-52	3154390771	68001	1	1	0	2	252525	8 	2011-09-01	637	535600	68001	1	52	0.00	1.00	2012-08-30	0
643	1	109866499	DIANA MARCELA TORRES	\N	\N	\N	\N	\N	7 	7 	1098664995  	DIANA MARCELA TORRES RIVERA             	17	3	1988-01-06	1	CALLE 105 N° 22-115	3164357857	68001	1	5	0	2	2525	8 	2012-04-27	730	566700	68001	1	52	1.00	1.00	2013-04-26	0
644	1	109622167	PAOLA ANDREA VILLAMI	\N	\N	\N	\N	\N	1 	1 	1096221673  	PAOLA ANDREA VILLAMIZAR LOZANO          	40	3	1993-05-27	1	CRA. 48 N° 40-11	3178585929	68001	1	5	0	2	2252525	8 	2011-12-01	689	680000	68001	0	52	1.00	1.00	2012-11-30	0
645	1	109620783	JHONATHAN JULIAN LEI	\N	\N	\N	\N	\N	4 	4 	1096207830  	JHONATHAN JULIAN LEIRA NEGRON           	15	3	1990-10-09	1	CRA. 37F N° 75-77	3167566499	68081	1	5	0	2	25252	8 	2011-11-16	675	566700	5059 	1	52	1.00	1.00	2012-11-16	0
646	1	109872944	JONATHAN GAMBOA MART	\N	\N	\N	\N	\N	7 	7 	1098729444  	JONATHAN GAMBOA MARTINEZ                	15	3	1992-11-10	2	CALLE 24 N° 11-68	6348437	68001	1	1	0	2	123123	8 	2013-07-05	661	680000	68001	1	52	1.00	1.00	2012-10-30	0
647	1	52899775	BEATRIZ BELTRAN RAMI	\N	\N	\N	\N	\N	4 	4 	52899775    	BEATRIZ BELTRAN RAMIREZ                 	17	3	1981-10-20	1	CRA. 20 N° 54-71	3104940074	68081	1	2	0	2	252525	8 	2011-11-15	677	566700	17380	1	52	1.00	1.00	2012-11-14	0
648	1	109869183	LEIDY BIBIANA DIAZ S	\N	\N	\N	\N	\N	3 	3 	1098691833  	LEIDY BIBIANA DIAZ SALAMANCA            	17	3	1990-08-17	1	CALLE 31 N° 18-15	3154433245	68001	1	3	0	3	1414144	8 	2012-02-23	704	680000	68001	1	52	1.00	1.00	2012-02-23	0
649	1	109868843	LESLY VANESSA GUALDR	\N	\N	\N	\N	\N	7 	7 	1098688438  	LESLY VANESSA GUALDRON ESTUPIÑAN        	17	3	1990-05-15	1	CALLE 11 N° 18-40	6718428	68001	2	5	1	2	2525	8 	2012-01-25	699	566700	68001	1	52	1.00	1.00	2013-01-24	0
650	1	109622320	LISETH PAOLA MUÑOZ U	\N	\N	\N	\N	\N	1 	1 	1096223209  	LISETH PAOLA MUÑOZ URANGO               	17	3	1993-08-26	1	TV. 49 N° 63 LOTE 120	3168688401	68081	1	5	1	2	2525	8 	2012-03-01	708	566700	68001	1	52	1.00	1.00	2013-02-28	0
651	1	109867115	SANDRA MARCELA MARTI	\N	\N	\N	\N	\N	0 	0 	1098671153  	SANDRA MARCELA MARTINEZ ORTIZ           	29	1	1989-06-06	1	CALLE 68 N° 10A-147	6835607	68001	1	5	0	3	124144	8 	2013-01-02	680	860000	68001	1	51	1.00	1.00	2012-11-30	0
652	1	37723805	YURLEY ORTIZ BARRERA	\N	\N	\N	\N	\N	3 	3 	37723805    	YURLEY ORTIZ BARRERA                    	60	3	1978-09-01	1	CRA. 12 N° 103D-06	3174310279	68001	2	1	0	2	1222222	8 	2013-04-18	633	700000	68001	1	52	1.00	1.00	2012-09-05	0
653	1	13566525	EDGAR LEON GONZALEZ 	\N	\N	\N	\N	\N	1 	1 	13566525    	EDGAR LEON GONZALEZ                     	14	3	1983-03-03	1	CALLE 55 N° 19-07	3006474102	68081	1	5	0	2	252525	8 	2012-01-20	697	900000	68081	1	52	1.00	1.00	2013-01-19	0
654	1	109580378	CHRISTIAM ALEXANDER 	\N	\N	\N	\N	\N	9 	9 	1095803789  	CHRISTIAM ALEXANDER ACOSTA OLAYA        	15	3	1990-01-23	2	AV VILLALUZ 121-82	3168084179	68001	1	5	0	3	2525	8 	2012-04-19	721	680000	68001	1	52	1.00	1.00	2013-04-18	0
655	1	63542491	DIANA CAROLINA MORA 	\N	\N	\N	\N	\N	0 	0 	63542491    	DIANA CAROLINA MORA REY                 	29	1	1983-07-02	1	SANTA CATALINA TORRES 10 AP 528	3003152759	68001	2	5	0	4	252525	8 	2012-03-26	717	1800000	68001	1	51	0.00	1.00	2013-03-25	0
656	1	60265570	SILVIA CAROLINA GAMB	\N	\N	\N	\N	\N	13	13	60265570    	SILVIA CAROLINA GAMBOA                  	20	3	1982-10-06	1	CRA. 31W N° 63A-14 AP 301	3132901507	68001	1	1	1	2	2525	8 	2014-08-16	700	1000000	68001	1	52	1.00	1.00	2013-01-25	0
657	1	91493878	SERGIO DAVID OVIEDO 	\N	\N	\N	\N	\N	0 	0 	91493878    	SERGIO DAVID OVIEDO PIMENTEL            	29	1	1976-11-06	2	TV. 29A N° 105-40	3173683761	68001	2	5	3	5	2525	8 	2012-04-18	723	8000000	68001	1	51	0.00	1.00	2013-04-17	0
658	1	109873966	LEIDY JOHANNA CAICED	\N	\N	\N	\N	\N	7 	7 	1098739664  	LEIDY JOHANNA CAICEDO VILLAMIZAR        	39	3	1993-04-19	1	CRA. 19 N° 60-33	6493426	68001	2	5	1	3	5254	8 	2011-10-20	653	680000	68001	0	52	1.00	1.00	2012-10-19	0
659	1	109620677	CIRO ANDRES ALVAREZ 	\N	\N	\N	\N	\N	4 	4 	1096206775  	CIRO ANDRES ALVAREZ MENESES             	15	3	1990-04-23	2	CALLE 25 N° 46-46	6029117	68001	3	2	0	2	52525	8 	2011-11-19	676	566700	68001	1	52	1.00	1.00	2012-11-18	0
660	1	13851732	JOHN ALEXANDER TREJO	\N	\N	\N	\N	\N	7 	7 	13851732    	JOHN ALEXANDER TREJOS FERNANDEZ         	15	3	1980-05-30	1	CRA. 26 N° 15-58	3162917587	68001	1	1	0	2	123123	8 	2012-02-02	662	566700	68001	1	52	1.00	1.00	2012-11-02	0
661	1	109868940	LAURA MARCELA URIBE 	\N	\N	\N	\N	\N	9 	9 	1098689407  	LAURA MARCELA URIBE RUEDA               	17	3	1990-02-18	1	CRA. 2 MZ E CASA 26	6837006	68001	1	1	0	2	2525	8 	2014-05-09	681	680000	68001	1	52	1.00	1.00	2012-11-30	0
662	1	109581535	SILVIA JULIANA SANCH	\N	\N	\N	\N	\N	7 	7 	1095815356  	SILVIA JULIANA SANCHEZ BAYONA           	17	3	1993-04-06	1	BLOQUE 6-8 AP 301 BUCARICA	3154448640	68001	1	5	0	2	1252525	8 	2011-09-09	638	566700	68001	1	52	1.00	1.00	2012-09-08	0
663	1	110235388	NIDIA YANETH MOSQUER	\N	\N	\N	\N	\N	7 	7 	1102353881  	NIDIA YANETH MOSQUERA GOMEZ             	17	3	1987-02-01	1	TV 1J N° 542	6558833	68001	2	5	2	2	1414143	8 	2012-05-02	733	566700	68001	1	52	1.00	1.00	2013-05-01	0
893	1	109871656	YEISON ALFONSO HERNA	\N	\N	\N	\N	\N	2 	2 	1098716563  	YEISON ALFONSO HERNANDEZ CARVAJAL       	15	3	1992-01-02	2	asdad	425254	68001	2	1	0	2	55848	8 	2013-11-15	973	680000	68001	1	52	1.00	1.00	2014-05-10	0
664	1	110236148	GUSTAVO ADOLFO GOMEZ	\N	\N	\N	\N	\N	8 	8 	1102361481  	GUSTAVO ADOLFO GOMEZ SALON              	15	3	1989-01-15	2	CALLE 52 N° 16-63	6427397	68081	2	5	1	2	2525	8 	2012-05-16	737	566700	68001	1	52	1.00	1.00	2013-05-15	0
665	1	91518298	OSCAR IVAN ZAPATA HE	\N	\N	\N	\N	\N	7 	7 	91518298    	OSCAR IVAN ZAPATA HERNANDEZ             	44	3	1983-04-26	2	CALLE 53 N° 21-22	6940283	68001	1	1	1	3	2525	8 	2012-05-29	738	566700	68001	1	52	1.00	1.00	2013-05-22	0
666	1	109861704	ZAIRA MARIA TOLEDO T	\N	\N	\N	\N	\N	9 	9 	1098617048  	ZAIRA MARIA TOLEDO TORRES               	17	3	1985-08-30	1	CRA. 7A N° 18-71	3183109181	68001	2	1	1	2	2525	8 	2012-05-26	739	566700	68001	1	52	1.00	1.00	2013-05-25	0
667	1	13542411	JAIRO ALEXANDER GONZ	\N	\N	\N	\N	\N	0 	0 	13542411    	JAIRO ALEXANDER GONZALEZ BUENO          	29	1	1978-07-27	2	CALLE 106C N° 15B-10	6801749	68001	1	1	1	5	252525	8 	2012-06-19	745	2500000	68001	1	51	0.00	1.00	2013-06-18	0
668	1	109864862	DIANA CATALINA MANTI	\N	\N	\N	\N	\N	9 	9 	1098648629  	DIANA CATALINA MANTILLA NARANJO         	17	3	1987-08-22	1	URB. SANTA CATALINA TORRE 5 AP 313	3177729967	68001	1	2	1	2	123123	8 	2011-11-04	663	566700	68001	1	52	1.00	1.00	2012-11-03	0
669	1	91211415	PEDRO JAVIER LOPEZ J	\N	\N	\N	\N	\N	10	10	91211415    	PEDRO JAVIER LOPEZ JOYA                 	10	3	1956-11-08	2	TORRE 2 AP 903 TAIRONA	3006126108	68001	2	3	1	5	252525	8 	2012-07-03	747	2500000	68001	1	52	0.00	1.00	2013-07-02	0
670	1	63502998	CLAUDIA ROCIO CABALL	\N	\N	\N	\N	\N	0 	0 	63502998    	CLAUDIA ROCIO CABALLERO AVILA           	29	1	1975-06-14	1	CRA. 9E N° 27-53	3132543889	68001	4	1	2	3	252525	8 	2012-07-05	748	860000	68001	1	51	1.00	1.00	2013-07-04	0
671	1	109874666	ANGIE SLENDY AYALA A	\N	\N	\N	\N	\N	7 	7 	1098746664  	ANGIE SLENDY AYALA AYALA                	17	3	1983-11-21	1	CALLE 106 N° 15B-33 VILLA SARA	3154479655	68001	1	5	0	2	2525	8 	2012-07-19	750	566700	68001	1	52	1.00	1.00	2013-07-18	0
672	1	109866040	CAROL DAYANA MARTINE	\N	\N	\N	\N	\N	9 	9 	1098660405  	CAROL DAYANA MARTINEZ SANCHEZ           	17	3	1988-10-06	1	CALLE 200A N° 19-17	6440602	68001	2	5	0	2	2255	8 	2012-08-18	734	566700	68001	1	52	1.00	1.00	2013-05-03	0
673	1	109864507	LEIDY MILENA OREJARE	\N	\N	\N	\N	\N	9 	9 	1098645075  	LEIDY MILENA OREJARENA REYES            	17	3	1987-07-11	1	CALLE 58 N° 42W-27	3178737906	68001	1	1	0	2	87288	8 	2012-07-27	756	680000	68001	0	52	1.00	1.00	2013-07-26	0
674	1	28214745	LUZ DEICY BOHORQUEZ 	\N	\N	\N	\N	\N	7 	7 	28214745    	LUZ DEICY BOHORQUEZ MORENO              	17	3	1989-07-26	1	DG. 7 N° 18-31	6591123	68307	1	1	1	2	252525	8 	2010-11-15	759	566700	68307	1	52	1.00	1.00	2011-11-14	0
675	1	109618997	JOHANA ANZOLA TRIANA	\N	\N	\N	\N	\N	1 	1 	1096189974  	JOHANA ANZOLA TRIANA                    	17	3	1986-02-19	1	DG 64 N° 013 LAS GRANJAS	3214417227	68081	1	2	0	3	25252	8 	2012-08-23	763	680000	68190	1	52	1.00	1.00	2013-08-22	0
676	1	63553195	MONICA PATRICIA MORE	\N	\N	\N	\N	\N	7 	7 	63553195    	MONICA PATRICIA MORENO RUEDA            	17	3	1984-09-21	1	CALLE 57A N° 43AW-35	6418328	68001	2	2	2	3	2525	8 	2012-08-29	764	680000	68001	1	52	1.00	1.00	2013-08-28	0
677	1	109868860	MAURY LISETH URIBE C	\N	\N	\N	\N	\N	8 	8 	1098688604  	MAURY LISETH URIBE COLMENARES           	17	3	1990-06-13	1	CRA. 29A N° 70-24	3184009630	68001	1	5	0	3	32525	8 	2012-09-06	765	566700	68001	1	52	1.00	1.00	2013-08-29	0
678	1	109870918	LUISA FERNANDA VALDI	\N	\N	\N	\N	\N	7 	7 	1098709186  	LUISA FERNANDA VALDIVIESO ACOSTA        	17	3	1991-04-15	1	CALLE 18 N° 30-45	3175871952	68001	1	6	1	3	252525	8 	2012-03-01	706	566700	68001	1	52	1.00	1.00	2013-02-28	0
679	1	109618416	JIMENA MARCELA LOPEZ	\N	\N	\N	\N	\N	1 	1 	1096184168  	JIMENA MARCELA LOPEZ GARRIDO            	17	3	1986-08-01	1	TV. 51 DG 64	3144437418	68081	1	5	0	2	2525	8 	2012-08-02	728	566700	68081	1	52	1.00	1.00	2013-04-22	0
680	1	109874612	KELLY ALEXANDRA SUAR	\N	\N	\N	\N	\N	9 	9 	1098746124  	KELLY ALEXANDRA SUAREZ MAYORGA          	39	3	1993-10-23	1	CALLE 25 N° 1A-23	3126584661	68001	1	1	1	3	2525	8 	2012-06-01	743	680000	68001	0	52	1.00	1.00	2013-05-30	0
681	1	24415595	MARISOL MUÑOZ PUERTA	\N	\N	\N	\N	\N	4 	4 	24415595    	MARISOL MUÑOZ PUERTA                    	16	3	1986-01-01	1	CRA. 31B  N° 35-35	3115155781	68081	1	5	0	2	252525	8 	2012-06-19	746	840000	66045	0	52	1.00	1.00	2013-06-18	0
682	1	37550746	LINA MARCELA MORA CA	\N	\N	\N	\N	\N	7 	7 	37550746    	LINA MARCELA MORA CASTAÑEDA             	39	3	1983-11-24	1	CALLE 201A N° 21A-39	3133218339	68001	1	5	0	3	2525	8 	2012-07-17	751	566700	68001	1	52	1.00	1.00	2013-07-16	0
683	1	37844585	JENNY MILENA ARIAS R	\N	\N	\N	\N	\N	8 	8 	37844585    	JENNY MILENA ARIAS ROJAS                	12	1	1981-02-20	1	CRA. 29 N° 29-59 CONDOMINIO EL LAGO	3006496567	68001	1	5	1	4	2525	23	2012-07-23	753	2300000	68001	0	52	0.00	1.00	2013-07-22	0
684	1	109590762	OSCAR FABIAN PRADA E	\N	\N	\N	\N	\N	9 	9 	1095907628  	OSCAR FABIAN PRADA ESTUPIÑAN            	35	3	1986-06-05	2	CALLE 23 N° 27-26 RIO DE ORO	6591908	68001	2	5	2	3	252525	8 	2012-08-01	757	640000	68001	1	52	1.00	1.00	2013-07-30	0
685	1	109867863	GLENIS GENIT QUINTER	\N	\N	\N	\N	\N	7 	7 	1098678633  	GLENIS GENIT QUINTERO MARTINEZ          	17	3	1989-07-10	1	CALLE 6 N° 24-36	3173111113	68001	1	5	1	2	2525252	8 	2012-08-15	762	680000	68001	1	52	1.00	1.00	2013-08-14	0
686	1	109871747	NADIA PATRICIA BARRE	\N	\N	\N	\N	\N	7 	7 	1098717470  	NADIA PATRICIA BARRERA MENDOZA          	17	3	1991-12-22	1	CRA. 9 N° 8-52	3157562769	68001	1	5	0	2	2525	8 	2012-04-13	719	566700	68001	1	52	1.00	1.00	2013-04-12	0
687	1	109873309	JESUS DAVID CARVAJAL	\N	\N	\N	\N	\N	7 	7 	1098733095  	JESUS DAVID CARVAJAL DUEÑEZ             	15	3	1992-12-26	2	CRA. 9CC N° 29-09	6300455	68001	1	1	0	2	2525	8 	2012-08-30	766	680000	68001	1	52	1.00	1.00	2013-08-29	0
688	1	109591551	DIANA LILIANA FLOREZ	\N	\N	\N	\N	\N	9 	9 	1095915518  	DIANA LILIANA FLOREZ MURILLO            	17	3	1988-03-16	1	CALLE 25 N° 27-21	3142545788	68307	1	5	0	2	252525	8 	2012-06-04	741	566700	68307	1	52	1.00	1.00	2013-06-03	0
689	1	109551049	LUZ DARY RUIZ AVENDA	\N	\N	\N	\N	\N	7 	7 	1095510498  	LUZ DARY RUIZ AVENDAÑO                  	17	3	1998-11-30	1	CRA. 15A N° 57A-21	31442867030	68001	1	5	0	2	252525	8 	2011-12-01	682	566700	68001	1	52	1.00	1.00	2012-11-30	0
690	1	28155098	CAROLINA PARRA GONZA	\N	\N	\N	\N	\N	0 	0 	28155098    	CAROLINA PARRA GONZALEZ                 	29	1	1981-07-01	1	CALLE 34 N° 25-51	3164481977	68001	2	5	3	5	25252	8 	2012-08-01	758	3500000	68001	1	51	0.00	1.00	2013-07-30	0
691	1	109871589	WILLIAM SANCHEZ AUSE	\N	\N	\N	\N	\N	7 	7 	1098715899  	WILLIAM SANCHEZ AUSECHA                 	15	3	1992-01-13	2	CRA. 5 N° 1A-22 CAMPO VERDE	3115640622	68001	1	1	1	3	2525	8 	2012-07-24	754	680000	68001	1	52	1.00	1.00	2013-07-23	0
692	1	101424443	AURA ROSA RIOS MARTI	\N	\N	\N	\N	\N	3 	3 	1014244435  	AURA ROSA RIOS MARTINEZ                 	17	3	1993-06-01	1	CALLE 31A N° 16-06	3124795914	68001	1	5	0	2	2525	8 	2012-05-07	735	680000	68001	1	52	1.00	1.00	2013-05-06	0
693	1	109648385	JESUS ANDRES GALEANO	\N	\N	\N	\N	\N	1 	1 	1096483852  	JESUS ANDRES GALEANO GALEANO            	15	3	1992-05-17	2	CFA. 6 N° 49-29	3216721584	68081	1	5	0	2	2525	8 	2012-06-01	742	566700	68081	1	52	1.00	1.00	2013-05-30	0
694	1	13872786	OSCAR ENRIQUE RUEDA 	\N	\N	\N	\N	\N	2 	2 	13872786    	OSCAR ENRIQUE RUEDA NIÑO                	15	3	1981-10-16	2	CALLE 64 N° 17A-66	3164755004	68001	1	5	0	3	123123	8 	2014-06-20	664	680000	68001	1	52	1.00	1.00	2012-10-30	0
695	1	104901946	JOHANA GARCIA CABALL	\N	\N	\N	\N	\N	2 	2 	1049019468  	JOHANA GARCIA CABALLERO                 	17	3	1986-09-26	1	BLOQUE 14 N° 19B- AP 223	3132418148	68001	1	5	0	3	25250	8 	2014-04-11	724	680000	68001	1	52	1.00	1.00	2013-04-18	0
931	1	109875056	CRISTIAN GABRIEL ANA	\N	\N	\N	\N	\N	12	12	1098750568  	CRISTIAN GABRIEL ANAYA LEON             	15	3	1994-02-09	2	1	1	68001	2	1	0	5	3223	8 	2013-12-17	1010	680000	68001	1	52	1.00	1.00	2014-05-10	0
696	1	37754353	NHORA ZULEYMA CARDEN	\N	\N	\N	\N	\N	0 	0 	37754353    	NHORA ZULEYMA CARDENAS PAIPA            	29	1	1980-07-29	1	SAN JORGE IV CASA 164-LOS CANEYES	3167247342	68001	3	5	0	3	2525	8 	2011-10-13	650	650000	68001	1	51	0.00	1.00	2012-10-12	0
697	1	106559476	ZUNIRY DURAN NAVARRO	\N	\N	\N	\N	\N	4 	4 	1065594761  	ZUNIRY DURAN NAVARRO                    	17	3	1987-12-30	1	CALLE 76A N° 31a-54	3135031034	68081	1	5	0	2	2525	8 	2012-04-27	731	566700	68081	1	52	1.00	1.00	2013-04-26	0
698	1	109870649	VIVIANA CRUZ NAVAS  	\N	\N	\N	\N	\N	4 	4 	1098706497  	VIVIANA CRUZ NAVAS                      	17	3	1991-06-08	1	CALLE 61 N° 36E-52	3126814064	68081	3	6	1	2	252525	8 	2012-05-11	736	680000	68001	1	52	1.00	1.00	2013-05-10	0
699	1	109864248	JUAN PABLO RUIZ VASQ	\N	\N	\N	\N	\N	2 	2 	1098642486  	JUAN PABLO RUIZ VASQUEZ                 	15	3	1987-09-26	1	CRA. 13 N° 65-47	3162327348	68001	1	5	1	2	2525	8 	2012-09-11	769	566700	68001	1	52	1.00	1.00	2013-09-10	0
700	1	108509734	ROSIRIS QUIROZ GUALD	\N	\N	\N	\N	\N	1 	1 	1085097349  	ROSIRIS QUIROZ GUALDRON                 	17	3	1990-12-25	1	BARRANCA	3116517339	68001	1	1	0	2	2525	8 	2012-09-13	771	680000	68001	1	52	1.00	1.00	2013-09-07	0
701	1	109865283	DAVID FRANCISCO DUAR	\N	\N	\N	\N	\N	9 	9 	1098652834  	DAVID FRANCISCO DUARTE                  	15	3	1988-02-14	2	CALLE 85 N° 24-46	6369650	68001	1	5	0	2	2525	8 	2012-09-20	772	680000	68001	1	52	1.00	1.00	2013-09-19	0
702	1	110175518	NORYDA JAZMIN GONZAL	\N	\N	\N	\N	\N	7 	7 	1101755183  	NORYDA JAZMIN GONZALEZ LEON             	17	3	1989-03-26	1	CALLE 19 N° 31-60	6904252	68001	1	5	0	2	2525250	8 	2012-09-24	773	566700	68001	1	52	1.00	1.00	2013-09-23	0
703	1	109581614	OSCAR MAURICIO TARAZ	\N	\N	\N	\N	\N	9 	9 	1095816140  	OSCAR MAURICIO TARAZONA DIAZ            	14	3	1993-07-02	2	SECTOR B TORRE 4 APT 101	3172976275	68276	1	5	0	2	2525	8 	2012-09-27	776	700000	68001	1	52	1.00	1.00	2013-09-26	0
704	1	109936842	MIGUEL ANGEL MORALES	\N	\N	\N	\N	\N	9 	9 	1099368420  	MIGUEL ANGEL MORALES ACOSTA             	15	3	1992-02-07	1	CALLE 7 N° 22-74	3166211804	68001	1	4	0	2	525	8 	2012-10-01	777	566700	68001	1	52	1.00	1.00	2013-09-30	0
705	1	109619472	NORBERTO LOPEZ BENAV	\N	\N	\N	\N	\N	4 	4 	1096194727  	NORBERTO LOPEZ BENAVIDES                	15	3	1987-10-26	2	CALLE 48A N 7-9	3114701468	68081	1	7	0	2	2525	8 	2012-10-01	778	566700	68081	1	52	1.00	1.00	2013-09-30	0
706	1	110235367	ADRIANA MARCELA BAUT	\N	\N	\N	\N	\N	8 	8 	1102353677  	ADRIANA MARCELA BAUTISTA CHANAGA        	17	3	2012-10-05	1	CALLE 4 N° 10-46	3107086215	68001	1	5	0	2	2525	8 	2012-10-05	779	566700	68001	1	52	1.00	1.00	2013-10-04	0
707	1	30008975	CLAUDIA ALEXANDRA AR	\N	\N	\N	\N	\N	9 	9 	30008975    	CLAUDIA ALEXANDRA ARDILA PARDO          	17	3	2004-05-10	2	METROPOLIS I T4 AP 208	6741718	68001	2	1	1	3	252525	8 	2012-10-15	783	680000	68211	1	52	1.00	1.00	2013-10-15	0
708	1	109619875	MARGIE GISELL GOMEZ 	\N	\N	\N	\N	\N	4 	4 	1096198754  	MARGIE GISELL GOMEZ LASERNA             	17	3	1988-10-30	1	DG. 60 N° 44-122	3112801866	68001	2	5	2	4	2525	8 	2012-07-16	752	566700	68001	1	52	1.00	1.00	2013-07-15	0
709	1	100533129	LUISA FERNANDA LIZCA	\N	\N	\N	\N	\N	8 	8 	1005331296  	LUISA FERNANDA LIZCANO LIZARAZO         	17	3	1986-12-30	1	VEREDA LA ESPERANZA FINCA LA FORTUNA	3158787178	68001	1	5	2	2	2525	8 	2012-10-17	784	566700	68001	1	52	1.00	1.00	2013-10-16	0
710	1	109593525	AMANDA MORELA CRISTA	\N	\N	\N	\N	\N	9 	9 	1095935252  	AMANDA MORELA CRISTANCHO CARRILLO       	17	3	1993-01-30	1	CRA. 36 N° 29B-33 CAMPIÑA	3118256476	68307	1	1	0	2	252525	8 	2012-03-21	713	680000	54051	1	52	1.00	1.00	2013-03-20	0
711	1	109867402	JULIETH ALEXANDRA RU	\N	\N	\N	\N	\N	0 	0 	1098674021  	JULIETH ALEXANDRA RUIZ MEJIA            	29	1	1989-08-12	1	CALLE 13 C N° 15-64	3167581820	68307	1	5	0	3	25255	8 	2012-08-08	760	1200000	68001	0	51	1.00	1.00	2013-08-07	0
712	1	109165485	YENNY MARCELA RINCON	\N	\N	\N	\N	\N	4 	4 	1091654855  	YENNY MARCELA RINCON RAMOS              	17	3	1986-11-28	1	AVENIDA NACIONAL CASA 65	3204754236	68081	1	5	0	2	25252	8 	2012-09-08	770	566700	68081	1	52	1.00	1.00	2013-09-07	0
713	1	109861089	HANS KEVIN VEGA GUTI	\N	\N	\N	\N	\N	0 	0 	1098610897  	HANS KEVIN VEGA GUTIERREZ               	29	3	1985-09-23	1	CRA. 47B N° 30-09	6452258	68001	1	5	3	3	14144	8 	2012-10-22	785	1300000	68001	1	52	0.00	1.00	2013-10-21	0
714	1	111677589	JUAN CARLOS CEDEÑOCH	\N	\N	\N	\N	\N	9 	9 	1116775897  	JUAN CARLOS CEDEÑOCHAVEZ                	15	3	1986-11-02	2	CRA 3 58 15	3143990088	68001	1	5	0	2	252514	8 	2012-11-01	787	680000	68001	1	52	1.00	1.00	2013-10-30	0
715	1	109871429	INGRID PAOLA CASALIN	\N	\N	\N	\N	\N	7 	7 	1098714292  	INGRID PAOLA CASALINAS MORENO           	17	3	1991-12-02	1	CALLE 62 17 C 72	6952016	68001	3	5	0	2	252525	8 	2012-11-01	788	680000	68001	1	52	1.00	1.00	2013-10-30	0
716	1	109860253	SERGIO FERNANDO ROME	\N	\N	\N	\N	\N	7 	7 	1098602530  	SERGIO FERNANDO ROMERO CABALLERO        	15	3	1985-10-05	2	CRA 24 5- 16	6343022	68001	1	1	0	2	252525	8 	2012-11-01	789	680000	68001	1	52	1.00	1.00	2013-10-30	0
717	1	109869690	HENRY ALBERTO ROJAS 	\N	\N	\N	\N	\N	7 	7 	1098696907  	HENRY ALBERTO ROJAS VARGAS              	33	3	1990-10-01	2	CALLE 9 N° 22-22	6716636	68001	1	5	0	2	252525	8 	2012-11-06	790	840000	68001	0	52	1.00	1.00	2013-11-05	0
718	1	109867872	MONICA MAYERLY SOCHA	\N	\N	\N	\N	\N	9 	9 	1098678722  	MONICA MAYERLY SOCHA MARTINEZ           	17	3	1989-11-16	1	CALLE 49 20-21	3132474005	68001	1	5	0	2	252525	8 	2013-07-02	791	680000	68001	1	52	1.00	1.00	2013-11-05	0
719	1	109620805	EUDYS REDONDO SIERRA	\N	\N	\N	\N	\N	1 	1 	1096208059  	EUDYS REDONDO SIERRA                    	17	3	1990-09-08	1	DG 62 N° 46-115	3144546747	68081	1	5	0	2	252525	8 	2012-09-22	774	680000	68081	1	52	1.00	1.00	2013-09-23	0
720	1	107059647	IVONNE TATIANA LEAL 	\N	\N	\N	\N	\N	7 	7 	1070596479  	IVONNE TATIANA LEAL MARTINEZ            	17	3	1989-03-28	1	CALLE 11 23-68	3183980935	68001	3	5	0	2	252525	8 	2012-11-06	792	680000	68001	1	52	1.00	1.00	2013-11-05	0
721	1	13539791	LIBARDO ESPINOSA PEÑ	\N	\N	\N	\N	\N	10	10	13539791    	LIBARDO ESPINOSA PEÑA                   	15	3	1983-12-11	2	CALLE 3 N 1 SEGUNDO PISO	3165589958	68547	1	5	0	2	252525	8 	2013-07-04	793	680000	68307	1	52	1.00	1.00	2013-11-06	0
722	1	91468661	ARNULFO PEREZ VELAND	\N	\N	\N	\N	\N	10	10	91468661    	ARNULFO PEREZ VELANDIA                  	33	3	1984-08-28	2	CRA 36 CALLE 111 -97	3186660906	68276	1	5	0	2	252525	8 	2012-11-07	794	1050000	68615	0	52	1.00	1.00	2013-11-06	0
723	1	63531096	LESLI MILEIDIS MOREN	\N	\N	\N	\N	\N	4 	4 	63531096    	LESLI MILEIDIS MORENO LIEVANO           	17	3	1982-05-24	1	CRA 31 65 40	3213542955	68081	1	5	0	2	252525	8 	2012-11-21	802	566700	68081	1	52	1.00	1.00	2013-11-20	0
724	1	34330896	LUISA FERNANDA CARDE	\N	\N	\N	\N	\N	10	10	34330896    	LUISA FERNANDA CARDENAS ROJAS           	17	3	1985-07-30	1	CRA 17 13 05	6046385	68547	1	5	0	2	252525	8 	2012-11-21	803	680000	19001	0	52	1.00	1.00	2013-11-20	0
725	1	110235572	JOSE LUIS MARTINEZ C	\N	\N	\N	\N	\N	10	10	1102355726  	JOSE LUIS MARTINEZ CASTILLO             	15	3	1988-04-25	2	MANZANA A CASA 8 P3	3133811791	68001	3	5	0	2	2525	8 	2012-10-04	780	680000	68001	1	52	1.00	1.00	2013-10-03	0
726	1	109865621	FABIO ANDRES GALVIS 	\N	\N	\N	\N	\N	9 	9 	1098656211  	FABIO ANDRES GALVIS GOMEZ               	15	3	1988-03-21	2	CALLE 64C N° 9B-13	3183113049	68001	1	5	0	2	20202	8 	2012-09-01	767	680000	68001	1	52	1.00	1.00	2013-08-30	0
727	1	109874168	LEIDY PAOLA MARIN GA	\N	\N	\N	\N	\N	9 	9 	1098741680  	LEIDY PAOLA MARIN GARCES                	17	3	1993-05-26	1	BARRIO EL CARMEN	3175551968	68001	1	5	0	2	255520	8 	2012-09-26	775	680000	5001 	1	52	1.00	1.00	2013-09-25	0
728	1	110089294	JAIME ANDRES CEPEDA 	\N	\N	\N	\N	\N	8 	8 	1100892942  	JAIME ANDRES CEPEDA FLOREZ              	15	3	1990-10-03	2	CRA 18 CALLE 17	3166560391	68001	1	5	0	2	252525	8 	2012-11-17	801	680000	68001	1	52	1.00	1.00	2013-11-16	0
729	1	109873202	YURLENY MAYERLY CORR	\N	\N	\N	\N	\N	9 	9 	1098732027  	YURLENY MAYERLY CORREA FRANCO           	17	3	2012-10-04	1	CALLE 95 N° 13-13	3167319975	68001	1	1	0	2	2525	8 	2012-10-04	781	680000	68001	1	52	1.00	1.00	2013-10-03	0
730	1	109875931	AURA MARCELA CASTRO 	\N	\N	\N	\N	\N	7 	7 	1098759313  	AURA MARCELA CASTRO BARAJAS             	17	3	1994-08-30	1	CRA. 26 N° 32-58	3105594397	68001	1	1	0	2	2525	8 	2012-09-04	768	680000	68001	1	52	1.00	1.00	2013-09-03	0
731	1	109860443	OSCAR EDUARDO VILLAM	\N	\N	\N	\N	\N	3 	3 	1098604432  	OSCAR EDUARDO VILLAMIZAR LOPEZ          	34	3	1985-12-02	2	CALLE 199A N° 38-19	6827240	68001	2	5	0	3	5525	8 	2012-03-15	714	1000000	68001	1	52	1.00	1.00	2013-03-14	0
732	1	109618888	ELIAS ARDILA FLOREZ 	\N	\N	\N	\N	\N	4 	4 	1096188881  	ELIAS ARDILA FLOREZ                     	15	3	1986-03-24	2	CRA.35A N° 75BIS - 305	3208938275	68081	1	5	1	2	2525	8 	2012-07-25	755	680000	68081	1	52	1.00	1.00	2013-07-24	0
733	1	110235820	NATALY BARBOSA CHAVE	\N	\N	\N	\N	\N	2 	2 	1102358207  	NATALY BARBOSA CHAVES                   	17	3	1988-10-18	1	CRA. 4B N° 4A-20	3177981669	68001	1	1	1	2	2525	8 	2012-04-28	732	566700	68001	1	52	1.00	1.00	2013-04-27	0
734	1	37747931	DIANA MARIA ORTIZ BA	\N	\N	\N	\N	\N	8 	8 	37747931    	DIANA MARIA ORTIZ BALAGUERA             	60	3	1979-12-18	1	MESA DE RUITOQUE	3214870485	68001	1	5	1	2	2525	8 	2012-03-14	712	700000	68001	1	52	1.00	1.00	2013-03-13	0
735	1	110254840	JAIRO ALBERTO SUAREZ	\N	\N	\N	\N	\N	9 	9 	1102548409  	JAIRO ALBERTO SUAREZ CALA               	15	3	1987-10-22	2	DIG 8 21A 13	3164909192	68307	1	5	0	2	252525	8 	2012-11-21	804	566700	68001	1	52	1.00	1.00	2013-11-20	0
736	1	13567178	ANGEL ALBERTO VARGAS	\N	\N	\N	\N	\N	1 	1 	13567178    	ANGEL ALBERTO VARGAS TORRES             	15	3	1983-07-05	1	TRAV 64 LOTE 15 20 DE AGOSTO	3136153291	68081	1	5	0	2	252525	8 	2012-11-13	795	566700	68081	1	52	1.00	1.00	2013-11-12	0
737	1	109620646	MAIRA ALEJANDRA VERG	\N	\N	\N	\N	\N	1 	1 	1096206469  	MAIRA ALEJANDRA VERGARA PABUENA         	17	3	1990-07-24	1	DIG 57 CASA 101 EL DANUBIO	6100897	68081	3	5	0	2	252525	8 	2012-11-09	796	680000	13430	1	52	1.00	1.00	2013-11-12	0
738	1	109870998	YURY KATHERINE GONZA	\N	\N	\N	\N	\N	9 	9 	1098709980  	YURY KATHERINE GONZALEZ AFANADOR        	17	3	1991-09-01	1	CALLE 28 N° 8 OCC 05	6522045	68001	3	1	0	2	252525	8 	2012-11-09	797	566700	68001	1	52	1.00	1.00	2013-11-08	0
739	1	110237088	SILVIA MARCELA CARRE	\N	\N	\N	\N	\N	9 	9 	1102370888  	SILVIA MARCELA CARREÑO GONZALEZ         	17	3	1993-04-15	1	CALLE 5 391	6554027	68001	1	5	0	2	252525	8 	2012-12-01	806	566700	68001	1	52	1.00	1.00	2013-11-30	0
740	1	109581319	HEYDER RICARDO JAIME	\N	\N	\N	\N	\N	12	12	1095813196  	HEYDER RICARDO JAIMES ARDILA            	15	3	1992-07-04	2	CRA 17 B 14 C 23	6592396	68307	1	5	0	2	252525	8 	2013-07-01	807	680000	68001	0	52	1.00	1.00	2013-11-30	0
741	1	110277456	JHON JAIRO TOLOZA GU	\N	\N	\N	\N	\N	9 	9 	1102774565  	JHON JAIRO TOLOZA GUERRERO              	15	3	1992-11-12	2	CRA 22 19 68	6805955	68307	1	5	0	2	252525	8 	2012-12-01	808	680000	68001	1	52	1.00	1.00	2013-11-30	0
742	1	103762421	YENNIFER CAMILA ALAR	\N	\N	\N	\N	\N	4 	4 	1037624218  	YENNIFER CAMILA ALARCON URIBE           	17	3	1992-09-30	1	CALLE 52 57-29	3203109215	68081	1	1	0	2	252525	8 	2012-12-05	809	680000	5001 	1	52	1.00	1.00	2013-12-04	0
743	1	109868029	DIANA MARCELA SANTOS	\N	\N	\N	\N	\N	10	10	1098680295  	DIANA MARCELA SANTOS VELANDIA           	17	3	1989-11-10	1	CALLE 1 A 16 20	6542575	68547	1	2	0	2	252525	8 	2012-12-05	810	680000	68001	1	52	1.00	1.00	2013-12-04	0
744	1	109592585	LAURA CATALINA GONZA	\N	\N	\N	\N	\N	0 	0 	1095925850  	LAURA CATALINA GONZALEZ DOMINGUEZ       	29	1	1991-04-22	1	CALLE 28 A 31-33	6469831	68307	1	1	0	3	252525	8 	2012-12-11	811	1000000	68001	1	51	1.00	1.00	2013-12-11	0
745	1	109579677	JENNIFER MARION UMAÑ	\N	\N	\N	\N	\N	4 	4 	1095796778  	JENNIFER MARION UMAÑA ORTEGA            	17	3	1988-04-20	1	CRA 19 49-17	3174928179	68081	1	5	0	2	252525	8 	2012-12-07	812	680000	68276	1	52	1.00	1.00	2013-12-06	0
746	1	63544653	LUZ DARY JEREZ MUÑOZ	\N	\N	\N	\N	\N	2 	2 	63544653    	LUZ DARY JEREZ MUÑOZ                    	17	3	1983-11-12	1	MANZANA 4 CASA 1	3157029347	68276	1	1	0	2	252525	8 	2015-02-19	816	680000	1001 	0	52	1.00	1.00	2013-12-21	0
747	1	110236392	CAROLINA SANCHEZ GUT	\N	\N	\N	\N	\N	10	10	1102363927  	CAROLINA SANCHEZ GUTIERREZ              	17	3	1990-05-29	1	CRA 4 A 4-04	3134172524	68547	1	5	0	2	252525	8 	2012-12-22	817	680000	68547	1	52	1.00	1.00	2013-12-22	0
748	1	110236910	PAOLA ANDREA DIAZ BA	\N	\N	\N	\N	\N	10	10	1102369100  	PAOLA ANDREA DIAZ BAUTISTA              	39	3	1992-09-08	1	CALLE 14 1-09	6542580	68547	1	5	0	2	252525	8 	2012-12-22	818	680000	68547	0	52	1.00	1.00	2013-12-21	0
749	1	109866709	GUZMAN ANTONIO PARDO	\N	\N	\N	\N	\N	7 	7 	1098667093  	GUZMAN ANTONIO PARDO PAEZ               	15	3	1988-04-07	2	CALLE 104 16-24	6376274	68001	1	1	0	2	252525	8 	2012-12-27	819	680000	68001	1	52	1.00	1.00	2013-12-26	0
750	1	109875467	YADIRIS LAGOS GARCIA	\N	\N	\N	\N	\N	9 	9 	1098754672  	YADIRIS LAGOS GARCIA                    	17	3	1994-05-04	1	CALLE 61 17 A 14	6411533	68001	1	5	0	2	252525	8 	2012-12-27	820	680000	68001	1	52	1.00	1.00	2013-12-26	0
751	1	108509488	ANA EDIS DIAZ ARIAS 	\N	\N	\N	\N	\N	10	10	1085094885  	ANA EDIS DIAZ ARIAS                     	17	3	1990-07-20	1	PASEO REAL C 21 2-61	3116909672	68547	1	5	0	2	252525	8 	2013-01-02	821	680000	47245	1	52	1.00	1.00	2014-01-01	0
752	1	91354494	LUIS FERNANDO BLANCO	\N	\N	\N	\N	\N	2 	2 	91354494    	LUIS FERNANDO BLANCO VARGAS             	15	3	1982-12-01	2	CRA 27 C 14-18	6556804	68547	1	5	0	2	252525	8 	2013-01-02	822	680000	20710	1	52	1.00	1.00	2014-01-01	0
753	1	110236367	VIVIANA ANDREA GARCI	\N	\N	\N	\N	\N	10	10	1102363678  	VIVIANA ANDREA GARCIA ADARME            	60	3	1990-05-27	1	TRANSVERSAL 11 A 12-49	6562497	68547	3	1	0	2	252525	8 	2013-01-02	823	700000	68001	1	52	1.00	1.00	2014-01-01	0
754	1	110236934	DIANA MARCELA FLOREZ	\N	\N	\N	\N	\N	10	10	1102369344  	DIANA MARCELA FLOREZ GUTIERREZ          	39	3	1992-07-11	1	CALLE 14 1-19	3167313561	68547	1	2	0	2	252525	8 	2013-01-02	824	680000	68547	1	52	1.00	1.00	2014-01-01	0
755	1	109760938	VICTORIA ACUÑA BELTR	\N	\N	\N	\N	\N	10	10	1097609382  	VICTORIA ACUÑA BELTRAN                  	17	3	1989-08-23	1	CRA E 3-22	3134667460	68547	1	1	0	2	252525	8 	2014-03-19	825	680000	68013	1	52	1.00	1.00	2014-01-01	0
756	1	6794125	FRANCISCO MINORTA MO	\N	\N	\N	\N	\N	7 	7 	6794125     	FRANCISCO MINORTA MONTEJO               	12	3	1964-05-10	2	CRA 40 C 105-18	6772883	68276	2	6	0	2	252525	8 	2013-01-09	826	3000000	20517	0	52	0.00	1.00	2014-01-08	0
757	1	109618605	CARMEN ROSA TEJADA  	\N	\N	\N	\N	\N	0 	0 	1096186055  	CARMEN ROSA TEJADA                      	29	1	1986-08-25	1	CALLE 47 12 C 25	6203645	68081	2	5	0	3	252525	8 	2013-01-09	827	1100000	68081	0	51	1.00	1.00	2014-01-08	0
758	1	110236631	LEIDY MARIA LEAL CAM	\N	\N	\N	\N	\N	8 	8 	1102366318  	LEIDY MARIA LEAL CAMACHO                	17	3	1991-03-01	1	CALLE 9 3-32	3156469672	68547	1	5	0	2	252525	8 	2013-01-10	828	680000	68547	1	52	1.00	1.00	2014-01-09	0
759	1	109870615	YERALDIN SALAS DURAN	\N	\N	\N	\N	\N	4 	4 	1098706150  	YERALDIN SALAS DURAN                    	17	3	1991-05-29	1	CRA 73 19 A 43	3167449881	68081	2	5	0	2	252525	8 	2013-07-02	829	680000	68081	1	52	1.00	1.00	2014-01-09	0
760	1	63508027	HERMINDA CONTRERAS V	\N	\N	\N	\N	\N	0 	0 	63508027    	HERMINDA CONTRERAS VARGAS               	29	1	1976-01-18	1	DIAG. 21B No 17-121 CASA15 MANZ L	3176959119	68001	2	1	1	2	34564	8 	2013-01-14	838	1800000	68001	0	51	0.00	1.00	2014-01-13	0
761	1	109875234	MARGARETH ALEXANDRA 	\N	\N	\N	\N	\N	9 	9 	1098752349  	MARGARETH ALEXANDRA RUEDA VELASCO       	39	3	1994-03-16	1	CRA 11w-64-44 MONTERREDONDO	6417088	68001	1	1	0	2	43123	8 	2013-01-18	839	680000	68001	1	52	1.00	1.00	2014-01-17	0
762	1	108504847	ROSAURA RADA NAVARRO	\N	\N	\N	\N	\N	3 	3 	1085048477  	ROSAURA RADA NAVARRO                    	60	3	1989-04-14	1	CRA 22 N o 18-15 APTO 504	3103931412	68001	1	1	0	2	1315416	8 	2013-01-14	832	680000	68001	1	52	1.00	1.00	2014-01-13	0
763	1	109867073	OLGA YAJAIRA LIÑAN A	\N	\N	\N	\N	\N	2 	2 	1098670738  	OLGA YAJAIRA LIÑAN ALQUICHIRE           	17	3	1989-05-18	1	CRA 44 No 147D-03	3168031212	68001	1	3	0	2	65464	8 	2013-01-12	833	680000	68001	1	52	1.00	1.00	2014-01-11	0
764	1	109620182	EDWARD MAURICIO ALMA	\N	\N	\N	\N	\N	4 	4 	1096201827  	EDWARD MAURICIO ALMANZA ASCENCIO        	15	3	1989-07-14	2	CLL 50 No 35-129	6212084	68001	1	5	0	2	24345	8 	2013-02-21	834	680000	68001	1	52	1.00	1.00	2014-01-11	0
765	1	109621592	JUAN CARLOS BARON RO	\N	\N	\N	\N	\N	4 	4 	1096215920  	JUAN CARLOS BARON ROJAS                 	15	3	1992-05-18	2	DIG 74 E 35-41	6020519	68081	1	5	0	2	654	8 	2013-01-12	835	680000	68081	1	52	1.00	1.00	2014-01-11	0
766	1	7227564	LUIS EDUARDO CEPEDA 	\N	\N	\N	\N	\N	2 	2 	7227564     	LUIS EDUARDO CEPEDA  HERNANDEZ          	20	3	1969-12-10	2	CALLE 19 NO 27A-28	3134971378	68001	3	5	0	2	135	8 	2013-01-15	836	1400000	15104	1	52	1.00	1.00	2014-01-14	0
767	1	37861250	GINA VANESSA VERGARA	\N	\N	\N	\N	\N	4 	4 	37861250    	GINA VANESSA VERGARA RAMIREZ            	17	3	1981-04-09	1	CRARRERA 29 No 4-58	3144220215	68081	1	5	0	2	231	8 	2013-01-11	837	680000	68081	1	52	1.00	1.00	2014-01-10	0
768	1	109868434	CRISTHY YURLEY CAICE	\N	\N	\N	\N	\N	2 	2 	1098684344  	CRISTHY YURLEY CAICEDO                  	17	3	1990-01-26	1	CRA 59 A 146 20	6160434	68276	1	5	0	2	252525	8 	2012-11-08	798	680000	68001	1	52	1.00	1.00	2013-11-07	0
769	1	110271879	SILVIA JULIANA FIALL	\N	\N	\N	\N	\N	9 	9 	1102718799  	SILVIA JULIANA FIALLO SANDOVAL          	17	3	1990-02-02	1	CALLE 41 N° 53A BIS - 30	6204329	68081	1	5	0	2	252525	8 	2013-12-17	686	680000	68001	1	52	1.00	1.00	2012-11-30	0
770	1	109591593	NATALIA ACEVEDO AGUI	\N	\N	\N	\N	\N	0 	0 	1095915931  	NATALIA ACEVEDO AGUILAR                 	29	1	1989-01-04	1	CALLE 14 No 16-58	3173528180	68001	1	1	0	4	132136	8 	2013-04-17	840	900000	68001	1	51	1.00	1.00	2014-01-16	0
771	1	110237006	LEIDY KATHERINE MUÑO	\N	\N	\N	\N	\N	10	10	1102370065  	LEIDY KATHERINE MUÑOZ CASTELLANOS       	17	3	1992-10-25	1	CLL 1C No 8A-49 APTO 201	6551415	68001	1	1	0	2	13	8 	2013-01-18	841	680000	68001	1	52	1.00	1.00	2014-01-17	0
772	1	63530043	KELLY JOHANA NIÑO GO	\N	\N	\N	\N	\N	0 	0 	63530043    	KELLY JOHANA NIÑO GONZALEZ              	29	1	1982-03-22	1	CLL 7 No 16-06 LIMONCITO	6184770	68001	1	1	0	5	131	8 	2013-01-30	850	3700000	68001	0	51	0.00	1.00	2014-01-15	0
773	1	110237292	LINA FERNANDA MONSAL	\N	\N	\N	\N	\N	10	10	1102372925  	LINA FERNANDA MONSALVE TOSCANO          	17	3	1994-02-20	1	MANZ 0 CASA 217-523	3166419754	68001	1	1	0	2	3123132	8 	2013-02-20	857	680000	68001	0	52	1.00	1.00	2014-02-19	0
774	1	109581048	LINA ANDREA SOSA CAM	\N	\N	\N	\N	\N	2 	2 	1095810482  	LINA ANDREA SOSA CAMARGO                	17	3	1991-10-29	1	CRA 6 NO 7-24	6488828	68001	1	1	0	2	666666663265	8 	2013-02-23	858	680000	68001	1	52	1.00	1.00	2014-02-22	0
775	1	109873673	LUISA GABRIELA LEON 	\N	\N	\N	\N	\N	8 	8 	1098736737  	LUISA GABRIELA LEON DIAZ                	17	3	1993-04-23	1	MESA DE RUITOQUE- LAS COLINAS	6786358	68001	1	1	0	2	23221	8 	2013-01-18	842	680000	68001	1	52	1.00	1.00	2014-01-17	0
776	1	110236484	WILLINGTON MENESES G	\N	\N	\N	\N	\N	10	10	1102364844  	WILLINGTON MENESES GALVIZ               	10	3	1990-10-07	2	CALL 14 No 6B-19	6555876	68001	1	1	0	2	2356	8 	2013-02-23	859	700000	68001	1	52	1.00	1.00	2013-02-22	0
777	1	109864989	CARLOS ANDRES QUESAD	\N	\N	\N	\N	\N	10	10	1098649891  	CARLOS ANDRES QUESADA MONTOYA           	43	3	1988-03-01	2	CRA 13 No 7-57 SAN RAFAEL	6557162	68001	2	1	0	2	21454456	8 	2013-02-21	860	680000	68001	0	52	1.00	1.00	2014-02-20	0
778	1	37619881	DIANA MARCELA RUEDA 	\N	\N	\N	\N	\N	10	10	37619881    	DIANA MARCELA RUEDA MALAGON             	17	3	1984-12-04	1	CLL 1C-No 8A-81	6557049	68001	1	1	0	2	32	9 	2013-02-16	861	680000	68001	0	52	1.00	1.00	2014-02-15	0
779	1	109865456	LILIBETH MELO MORALE	\N	\N	\N	\N	\N	7 	7 	1098654562  	LILIBETH MELO MORALES                   	17	3	1988-05-26	1	CRA. 7 N° 66-50	3142898611	68001	2	1	1	2	202025	8 	2012-03-21	715	566700	68001	1	52	1.00	1.00	2013-03-20	0
780	1	110235965	JUAN CARLOS VERA CHA	\N	\N	\N	\N	\N	10	10	1102359659  	JUAN CARLOS VERA CHANAGA                	15	3	1989-04-06	2	CRA 11 NO 3-39	6564533	68001	1	1	0	2	23	8 	2013-02-07	851	680000	68001	1	52	1.00	1.00	2014-02-06	0
781	1	109863725	EDGAR ANDRES ARDILA 	\N	\N	\N	\N	\N	7 	7 	1098637258  	EDGAR ANDRES ARDILA NUÑEZ               	15	3	1986-09-18	2	CLL 114 No 45-02	6481218	68001	1	1	0	2	5131	8 	2013-02-12	852	680000	68001	1	52	1.00	1.00	2014-02-11	0
782	1	103057532	JUNIOR ANDRES CHACON	\N	\N	\N	\N	\N	1 	1 	1030575326  	JUNIOR ANDRES CHACON CANO               	15	3	1990-06-17	2	CLL 48 No 8-39 CARDALES	3203281379	68081	1	1	0	2	431	8 	2013-02-07	853	680000	68081	1	52	1.00	1.00	2014-02-06	0
783	1	110236938	JHON EDINSON CARRENO	\N	\N	\N	\N	\N	7 	7 	1102369381  	JHON EDINSON CARRENO MORALES            	33	3	1992-10-08	2	CALLE 12 No 4-15	6556129	68001	1	1	0	2	213212	8 	2013-11-07	854	770000	68001	0	52	1.00	1.00	2014-02-04	0
784	1	91480148	ALEXANDER RIBERO LOP	\N	\N	\N	\N	\N	3 	3 	91480148    	ALEXANDER RIBERO LOPEZ                  	102	3	1975-10-08	2	CRQA 6 No 13-18	6551389	68001	2	1	0	3	232	8 	2013-02-06	855	1550000	68001	1	52	0.00	1.00	2014-02-05	0
785	1	109620733	MARLON YESID JARAMIL	\N	\N	\N	\N	\N	1 	1 	1096207333  	MARLON YESID JARAMILLO LOPEZ            	15	3	1990-09-02	2	CALLE 74 No 34C-17 CIUDADELA PIATON	3134464275	68001	1	1	0	2	1346531	8 	2013-02-23	862	680000	68001	1	52	1.00	1.00	2014-02-22	0
786	1	109870928	OLGA CECILIAN SEPULV	\N	\N	\N	\N	\N	2 	2 	1098709281  	OLGA CECILIAN SEPULVEDA PINEDA          	17	3	1991-08-18	1	VGFDGR	56325312	68001	2	1	0	5	213145	8 	2013-02-26	863	680000	68001	1	52	1.00	1.00	2014-02-25	0
787	1	110237277	WILLIAM FERNEY RUEDA	\N	\N	\N	\N	\N	10	10	1102372778  	WILLIAM FERNEY RUEDA ORTIZ              	15	3	1994-01-10	2	GGDFGF	413636	68001	2	1	0	5	131	8 	2014-06-27	864	680000	68001	1	52	1.00	1.00	2014-02-26	0
788	1	109875096	MARTIN EDUARDO LOZAN	\N	\N	\N	\N	\N	3 	3 	1098750962  	MARTIN EDUARDO LOZANO MUÑOZ             	10	3	1993-12-09	2	CRA 41 nO 59-59	6416220	68001	2	1	0	5	221	2 	2013-03-08	865	800000	68001	0	52	1.00	1.00	0201-03-07	0
789	1	109620540	NILSON TORRES SALGUE	\N	\N	\N	\N	\N	1 	1 	1096205408  	NILSON TORRES SALGUERO                  	15	3	1990-03-08	2	CALLE 49 No 54-14 VILLARELIS 2	3208970218	68081	2	1	0	5	0	8 	2013-03-06	866	680000	68081	1	52	1.00	1.00	2014-03-05	0
790	1	109860657	JOHANNA MARCELA PINZ	\N	\N	\N	\N	\N	7 	7 	1098606572  	JOHANNA MARCELA PINZON LOPEZ            	17	3	1985-06-28	1	CLL 28 NO 3 OCC NAPOLES	6530094	68001	2	1	0	5	323213	8 	2013-03-01	867	680000	68001	1	52	1.00	1.00	2014-03-01	0
791	1	110132092	LUZ MIREYA CALDERON 	\N	\N	\N	\N	\N	7 	7 	1101320923  	LUZ MIREYA CALDERON RAMIREZ             	39	3	1992-05-11	1	CRA 7 nO 42-41 EDIF. OVIEDO	6422134	68001	1	1	0	2	132131	8 	2014-08-29	868	680000	68001	1	52	1.00	1.00	2014-03-01	0
792	1	109937014	YESSICA MARCELA FORE	\N	\N	\N	\N	\N	1 	1 	1099370145  	YESSICA MARCELA FORERO NAVARRO          	17	3	1993-06-19	1	CALLE 48 No 11-34 EL DORADO	3157060889	68001	1	1	0	2	451536	8 	2013-03-15	869	680000	68001	1	52	1.00	1.00	2014-03-14	0
793	1	109621915	KELLY JOHANA BALLEST	\N	\N	\N	\N	\N	4 	4 	1096219159  	KELLY JOHANA BALLESTEROS GUTIERREZ      	17	3	1992-12-24	1	CRA 36B No 37B-55B ALTOS DE CAÑAVERAL	3134253328	68081	1	1	0	2	13121	8 	2013-03-15	870	680000	68081	0	52	1.00	1.00	2014-03-14	0
794	1	109619300	JAN CARLOS LIÑAN SAN	\N	\N	\N	\N	\N	4 	4 	1096193001  	JAN CARLOS LIÑAN SANCHEZ                	15	3	1987-11-24	2	CALLE 49 NO 54-41	3204122805	68081	1	3	0	2	21323	8 	2013-03-16	871	680000	68081	0	52	1.00	1.00	2014-03-15	0
795	1	91522709	DAVID GOYENECHE RAMI	\N	\N	\N	\N	\N	0 	0 	91522709    	DAVID GOYENECHE RAMIREZ                 	29	3	1983-09-23	2	CARRERA 28A No 67-37 LA SALLE	3003735306	68001	1	1	0	5	131331	8 	2013-04-08	872	3500000	68001	1	52	0.00	1.00	2014-04-08	0
796	1	110237089	LEIDY KATERIN GOMEZ 	\N	\N	\N	\N	\N	10	10	1102370890  	LEIDY KATERIN GOMEZ ORDUZ               	17	3	1993-04-04	1	CALLE 2 nO 8-37 VILLALUZ	6544262	68001	1	1	0	2	323121	8 	2013-04-26	880	680000	68001	0	52	1.00	1.00	2014-04-25	0
797	1	109580643	CARLOS EDUARDO SANCH	\N	\N	\N	\N	\N	2 	2 	1095806431  	CARLOS EDUARDO SANCHEZ HERNANDEZ        	15	3	1990-10-11	1	BLOQUE 13-4 APTO 301 BUCARICA	3118069434	68001	1	1	0	2	21312	8 	2013-04-23	881	680000	68001	1	52	1.00	1.00	2014-04-22	0
798	1	109579118	MONICA MARCELA DIAZ 	\N	\N	\N	\N	\N	2 	2 	1095791180  	MONICA MARCELA DIAZ MARTINEZ            	17	3	1992-03-10	1	CALLE 22B No 7A-51 MONTEBLANCO	6485727	68001	2	1	0	5	2131231	8 	2013-04-18	882	680000	68001	1	52	1.00	1.00	2014-04-18	0
799	1	91519228	JORGE LUIS JAIMES PA	\N	\N	\N	\N	\N	8 	8 	91519228    	JORGE LUIS JAIMES PATIÑO                	15	3	1983-05-24	2	SECTOR 4 BLOQUE 1-18 APTO 403	6720526	68001	1	7	0	2	54312	8 	2013-04-21	883	680000	68001	1	52	1.00	1.00	2014-05-10	0
800	1	109581911	ZULLY TATIANA PINZON	\N	\N	\N	\N	\N	2 	2 	1095819116  	ZULLY TATIANA PINZON GARNICA            	40	3	1994-04-25	1	BLOQ 7 -4 APTO 401	6049431	68001	1	1	0	2	1321	8 	2013-04-20	884	680000	68001	0	52	1.00	1.00	2014-04-19	0
801	1	80734086	EDUARD CABRERA CASTE	\N	\N	\N	\N	\N	3 	3 	80734086    	EDUARD CABRERA CASTELLANOS              	12	3	1982-10-10	2	LAGOS 5 ETAPA TORRE 1 APTO 503	6374739	68001	2	1	0	5	231312	8 	2013-04-17	885	2300000	68001	0	52	0.00	1.00	2014-04-10	0
802	1	109875816	LICETH KARINA TORRES	\N	\N	\N	\N	\N	9 	9 	1098758160  	LICETH KARINA TORRES CABALLERO          	17	3	1994-07-11	1	CRA 10 No 7N-40	6408793	68001	1	1	0	2	1312	8 	2013-04-26	886	680000	68001	1	52	1.00	1.00	2014-04-25	0
803	1	109862432	JEIMY LUCERO ZAMORA 	\N	\N	\N	\N	\N	7 	7 	1098624324  	JEIMY LUCERO ZAMORA RAMIREZ             	17	3	1986-10-10	1	CALLE 22 N° 24-69 ED. ARAPAIMA	6452165	68001	3	5	0	2	25255	8 	2011-12-29	694	566700	68001	1	52	1.00	1.00	2012-12-28	0
804	1	79709738	RAUL RODRIGUEZ GARCI	\N	\N	\N	\N	\N	0 	0 	79709738    	RAUL RODRIGUEZ GARCIA                   	29	1	1974-03-27	2	DIAGONAL 105 No 104E-196 TORRE 4 APTO 10	6906544	68001	2	3	0	5	321	8 	2013-04-02	873	3800000	68001	1	51	0.00	1.00	2014-05-30	0
805	1	109580093	ALEXANDER ESTRADA SA	\N	\N	\N	\N	\N	4 	4 	1095800932  	ALEXANDER ESTRADA SALAZAR               	15	3	1989-06-16	2	DG. 62 N° 46-93	3118179785	68001	2	5	1	2	2525	8 	2012-07-02	711	566700	68001	1	52	1.00	1.00	2013-03-02	0
806	1	109619338	ROGELIO ANDRES PRADA	\N	\N	\N	\N	\N	4 	4 	1096193381  	ROGELIO ANDRES PRADA VERGARA            	15	3	1987-11-15	2	CALLE 52C N° 34-139	6100206	68081	1	5	0	2	2525	8 	2012-03-16	716	680000	68081	1	52	1.00	1.00	2013-03-15	0
807	1	109592796	JHON JAIRO ROJAS VEL	\N	\N	\N	\N	\N	9 	9 	1095927966  	JHON JAIRO ROJAS VELASQUEZ              	15	3	1992-02-13	2	CALLE 11A No 18-11 RIO PRADO	6595790	68001	2	1	0	5	31213	8 	2013-04-25	887	680000	68001	0	52	1.00	1.00	2014-04-09	0
808	1	63540998	ESTEFANIA ALVIS ORTE	\N	\N	\N	\N	\N	0 	0 	63540998    	ESTEFANIA ALVIS ORTEGA                  	29	1	1986-12-01	1	1	524654	68001	2	1	0	5	2413243	8 	2013-07-02	889	860000	68001	1	51	1.00	1.00	2014-05-01	0
809	1	109861525	YENY PAOLA GOMEZ FLO	\N	\N	\N	\N	\N	0 	0 	1098615250  	YENY PAOLA GOMEZ FLOREZ                 	29	1	1985-10-01	1	CALL 52 No 23-68/ EDIF SOTO MAYO	6576066	68001	2	1	0	5	13132	8 	2013-05-02	890	1500000	68001	1	51	0.00	1.00	2014-05-01	0
810	1	109863813	JAVIER CELIX OREJARE	\N	\N	\N	\N	\N	2 	2 	1098638134  	JAVIER CELIX OREJARENA                  	20	3	1987-05-06	2	CALL 51 No 21-27 NUEVO SOTOMAYOR	3016032779	68001	2	1	0	5	258285	8 	2014-10-19	891	1550000	68001	1	52	0.00	1.00	2014-05-01	0
811	1	63555794	STELLA ANDRADE SOSA 	\N	\N	\N	\N	\N	2 	2 	63555794    	STELLA ANDRADE SOSA                     	17	3	1986-12-01	1	CALLE 147 C No 44-39 PRADOS DEL SUR	313351764	68001	2	1	0	5	213	20	2013-05-07	892	680000	68001	1	52	1.00	1.00	2014-05-07	0
812	1	109875640	LEIDY PAOLA RODRIGUE	\N	\N	\N	\N	\N	4 	4 	1098756409  	LEIDY PAOLA RODRIGUEZ CAMACHO           	17	3	1994-06-05	1	villa plata casa 42	3108593690	68001	2	1	0	5	3	13	2013-05-04	893	680000	68081	1	52	1.00	1.00	2014-05-04	0
813	1	109622812	JHOLLMAN CERVANTES D	\N	\N	\N	\N	\N	4 	4 	1096228126  	JHOLLMAN CERVANTES DURAN                	15	3	1994-06-05	2	cra 34 nO 58d-50	3163870258	68001	2	1	0	5	23213	8 	2013-05-05	894	680000	68001	1	52	1.00	1.00	2014-05-05	0
814	1	109621612	ELOISA MANTILLA ARIA	\N	\N	\N	\N	\N	1 	1 	1096216121  	ELOISA MANTILLA ARIAS                   	17	3	1992-07-08	1	CRA 36B No 75-58 LA PAZ	6113795	68081	2	1	0	5	212	8 	2013-07-04	895	680000	68081	1	52	1.00	1.00	2014-05-17	0
815	1	109760932	JERSON DAVID LOPEZ G	\N	\N	\N	\N	\N	4 	4 	1097609320  	JERSON DAVID LOPEZ GARNICA              	15	3	1989-04-14	2	CALL 29 LOTE 13 LOS COMUNEROS	31233917171	68081	2	1	0	5	23362	8 	2014-08-02	896	680000	68081	1	52	1.00	1.00	2014-05-15	0
816	1	109622324	MARLON ANDRES DIAZ R	\N	\N	\N	\N	\N	4 	4 	1096223243  	MARLON ANDRES DIAZ RODRIGUEZ            	15	3	1993-08-31	2	CARRERA 60 NO 38-30 LA ESPERANZA	3133537159	68081	1	1	0	5	322	8 	2013-05-16	897	680000	68081	1	52	1.00	1.00	2014-05-10	0
817	1	109622676	GERALDINE VANESSA CR	\N	\N	\N	\N	\N	4 	4 	1096226764  	GERALDINE VANESSA CRUZ SANGUINETTI      	17	3	1994-03-23	1	CRA 35 No 37 -46 BUIENOS AIRES	6024348	68081	1	1	0	2	1313	8 	2013-05-26	898	680000	68081	0	52	1.00	1.00	2014-05-25	0
818	1	109621266	YESSICA ANDREA RIVER	\N	\N	\N	\N	\N	4 	4 	1096212660  	YESSICA ANDREA RIVERA GONZALEZ          	17	3	1991-10-05	1	CLL 71 No 24-77 LA LIBERTAD	6027637	68081	2	1	0	5	61312	8 	2013-05-22	899	680000	68081	1	52	1.00	1.00	2014-05-10	0
819	1	109622293	ANDRES ALEXIS MARQUE	\N	\N	\N	\N	\N	4 	4 	1096222932  	ANDRES ALEXIS MARQUEZ LAGOS             	15	3	1993-07-30	2	CRA 36 76-21	3115007538	68081	1	1	0	2	252525	8 	2012-12-17	813	680000	68081	1	52	1.00	1.00	2013-12-16	0
820	1	109593853	KATHERIN VERA OSMA  	\N	\N	\N	\N	\N	0 	0 	1095938538  	KATHERIN VERA OSMA                      	29	1	1994-12-08	1	CALLE 31 No 30-15 VILLA CAROLINA	6462939	68001	1	5	0	3	5321	8 	2013-04-26	888	650000	68001	1	51	1.00	1.00	2014-04-25	0
821	1	109869706	HEIDY CAROLINA VARGA	\N	\N	\N	\N	\N	9 	9 	1098697064  	HEIDY CAROLINA VARGAS                   	17	3	1990-07-30	1	CALLE 64C No 81 CIUDAD BOLIVAR	6410349	68001	2	1	0	5	2133213	8 	2013-06-08	900	680000	68001	1	52	1.00	1.00	2014-06-07	0
822	1	110235458	LUZ EDILMA ORTIZ ORT	\N	\N	\N	\N	\N	10	10	1102354586  	LUZ EDILMA ORTIZ ORTIZ                  	17	3	1987-11-24	1	DIAG. 7 TRANV 1N-03 LA ARGENTINA	3164033615	68001	2	1	0	5	2332352	8 	2013-06-12	901	680000	68001	0	52	1.00	1.00	2014-06-01	0
823	1	109868637	YULI CAROLINA BOTIA 	\N	\N	\N	\N	\N	9 	9 	1098686379  	YULI CAROLINA BOTIA HERRERA             	17	3	1989-05-26	1	CALLE 15 No 18-23 PAISAJES DEL NORTE	3153607361	68001	2	1	0	2	13222	8 	2013-06-12	902	680000	68001	1	52	1.00	1.00	2014-06-11	0
824	1	109416574	ENNY YURLEY LUQUE RU	\N	\N	\N	\N	\N	4 	4 	1094165749  	ENNY YURLEY LUQUE RUEDA                 	39	3	1993-12-09	1	1	3134442022	68081	2	1	0	2	332223	8 	2013-06-09	903	680000	68081	0	52	1.00	1.00	2014-06-08	0
825	1	109872016	ANA TERESA HERNANDEZ	\N	\N	\N	\N	\N	2 	2 	1098720164  	ANA TERESA HERNANDEZ                    	17	3	1992-04-12	1	CRA 6AN No 11-127 SANTA ANA	6393039	68001	2	1	0	5	23132	8 	2013-06-16	904	680000	68001	1	52	1.00	1.00	2014-05-10	0
826	1	91222098	HERNANDO DULCEY ORDU	\N	\N	\N	\N	\N	0 	0 	91222098    	HERNANDO DULCEY ORDUZ                   	29	1	1962-02-26	2	cra 30 nO 20-47 apto 301	6994592	68001	2	1	0	5	52143	8 	2014-08-08	905	3800000	68001	1	51	0.00	1.00	2014-05-10	0
827	1	5338778	CARLOS ANDRES GALVIS	\N	\N	\N	\N	\N	0 	0 	5338778     	CARLOS ANDRES GALVIS ROJAS              	29	3	1984-10-23	2	CRA 12C-No 103C-31 SAN TA MARIA	6370612	68001	2	1	0	5	2232	2 	2014-04-21	906	2000000	68001	1	52	0.00	1.00	2014-05-10	0
828	1	103968749	ARISLEYDA JIMENEZ SE	\N	\N	\N	\N	\N	1 	1 	1039687496  	ARISLEYDA JIMENEZ SERNA                 	17	3	1988-05-15	1	1	1	68081	2	1	0	5	232232	8 	2013-06-28	911	680000	68081	1	52	1.00	1.00	2014-05-10	0
829	1	110237075	JUAN DIEGO RAMIREZ R	\N	\N	\N	\N	\N	10	10	1102370751  	JUAN DIEGO RAMIREZ RODRIGUEZ            	15	3	1993-03-23	2	CARRERA 4C No 1C-22 CAMPO VERDE	3175554766	68001	2	1	0	5	1321	8 	2013-07-04	912	680000	68001	0	52	1.00	1.00	2014-05-10	0
830	1	109593820	SILVIA JULIANA PINIL	\N	\N	\N	\N	\N	12	12	1095938209  	SILVIA JULIANA PINILLA SILVA            	17	3	1994-10-15	1	CRA 22B No 19-51 PORTAL CAMPESTRE	6596216	68001	2	1	0	5	23231	8 	2013-07-09	913	680000	68001	0	52	1.00	1.00	2014-05-10	0
831	1	109864886	YINETH DAYANA ROJAS 	\N	\N	\N	\N	\N	2 	2 	1098648863  	YINETH DAYANA ROJAS ROJAS               	17	3	1987-09-26	1	CARRERA 2E NO 32-150	6052493	68001	2	1	0	5	12005	51	2013-07-20	914	680000	68001	1	52	1.00	1.00	2014-05-01	0
832	1	109870058	OSCAR IVAN BARAJAS R	\N	\N	\N	\N	\N	8 	8 	1098700580  	OSCAR IVAN BARAJAS RAMIREZ              	15	3	1991-02-15	2	MESA DE RUITOQUE VERESA PALMERAS	6786644	68001	1	5	0	2	46323	8 	2013-07-18	915	680000	68001	1	52	1.00	1.00	2014-05-10	0
833	1	91521255	EDWIN ALFONSO GALVIS	\N	\N	\N	\N	\N	3 	3 	91521255    	EDWIN ALFONSO GALVIS RICO               	15	3	1980-12-29	2	CALLE 30 A 33 63	6531729	68307	3	1	0	2	252525	8 	2012-11-08	799	680000	68051	1	52	1.00	1.00	2013-11-07	0
834	1	109593358	ANGIE VANESSA ORTIZ 	\N	\N	\N	\N	\N	3 	3 	1095933580  	ANGIE VANESSA ORTIZ PRADA               	17	3	1993-08-22	1	CALLE 14 12 S 16	3176503408	68307	3	5	0	2	252525	8 	2012-11-09	800	680000	68001	1	52	1.00	1.00	2013-11-08	0
835	1	110272044	YUDY ANDREA LLANES L	\N	\N	\N	\N	\N	10	10	1102720444  	YUDY ANDREA LLANES LOPEZ                	17	3	1991-10-04	1	CRA 4 DIG 4 A 10	3143454154	68547	1	5	0	2	252525	8 	2012-12-19	814	680000	68689	0	52	1.00	1.00	2013-12-18	0
836	1	109581535	SILVIA JULIANA RINCO	\N	\N	\N	\N	\N	9 	9 	1095815354  	SILVIA JULIANA RINCON PEÑA              	104	3	1993-04-04	1	CRA 13 7-38	3178871884	68276	1	5	0	2	252525	8 	2013-07-02	815	680000	68001	1	52	1.00	1.00	2013-12-17	0
837	1	72289586	HERNANDO RAFAEL BARI	\N	\N	\N	\N	\N	1 	1 	72289586    	HERNANDO RAFAEL BARIOS ALEMAN           	15	3	1982-07-07	2	TRANV 44 No 51C-25	3182657910	68081	1	1	0	2	56436	8 	2013-01-25	843	680000	68081	1	52	1.00	1.00	2014-01-24	0
838	1	63467463	ROSALBA SANCHEZ AGUI	\N	\N	\N	\N	\N	1 	1 	63467463    	ROSALBA SANCHEZ AGUILAR                 	17	3	1976-02-27	1	TRAV 46 NO 46-45	6103958	68081	1	1	0	2	5463	8 	2013-01-25	844	680000	68081	1	52	1.00	1.00	2014-01-24	0
839	1	109621248	CRISTIAN LONDOÑO MON	\N	\N	\N	\N	\N	4 	4 	1096212485  	CRISTIAN LONDOÑO MONCADA                	15	3	1991-12-19	1	CLL 34 No 34C -04 PRIMERO DE MAYO	3142458347	68001	1	1	0	2	536210	8 	2013-01-23	845	680000	68001	1	52	1.00	1.00	2014-01-22	0
840	1	109622912	YALITZA JOHANA MORA 	\N	\N	\N	\N	\N	4 	4 	1096229123  	YALITZA JOHANA MORA ALBIS               	40	3	1994-07-07	1	CRA 17A NO 43-40 BUENOS AIRES	6223448	68081	1	1	0	2	563	8 	2013-01-23	846	680000	68081	0	52	1.00	1.00	2014-01-22	0
841	1	110234968	ADRIANA ARENAS CORDE	\N	\N	\N	\N	\N	2 	2 	1102349683  	ADRIANA ARENAS CORDERO                  	16	3	1986-05-08	1	CRA 4 No 16-33 HOYO GRANDE	3177605469	68001	1	1	0	2	252525	8 	2013-01-25	847	840000	68001	0	52	1.00	1.00	2014-01-24	0
842	1	72298456	EDWIN ALBERTO ESCOBA	\N	\N	\N	\N	\N	7 	7 	72298456    	EDWIN ALBERTO ESCOBAR CASTILLO          	15	3	1985-12-03	2	BARRIO ALVAREZ	3172905403	68001	1	5	0	2	2525	8 	2011-12-19	691	566700	68001	1	52	1.00	1.00	2012-12-18	0
843	1	110236951	ANGY LICETH CARO FUE	\N	\N	\N	\N	\N	13	13	1102369513  	ANGY LICETH CARO FUENTES                	17	3	1992-08-10	1	CALLE 15A No 3WA-80 PORTAL DE BELEN	3156770646	68001	2	1	0	2	41321	8 	2014-09-20	916	680000	68001	1	52	1.00	1.00	2014-05-10	0
844	1	109874568	LORENA RANGEL CHAPAR	\N	\N	\N	\N	\N	3 	3 	1098745687  	LORENA RANGEL CHAPARRO                  	17	3	1993-07-25	1	CALLE 10 No 23-27 LA UNIVERSIDAD	6770372	68001	2	1	0	2	523632	8 	2014-08-29	917	680000	68001	1	52	1.00	1.00	2014-05-10	0
845	1	28484410	ANSELMA KARINA SANTA	\N	\N	\N	\N	\N	4 	4 	28484410    	ANSELMA KARINA SANTAMARIA NAVARRO       	17	3	1980-03-28	1	CALLE 26 No 64-21	3178763514	68001	2	1	0	2	4132	8 	2013-07-20	918	680000	68001	1	52	1.00	1.00	2014-05-10	0
846	1	109936903	DIANA CAROLINA DIAZ 	\N	\N	\N	\N	\N	12	12	1099369036  	DIANA CAROLINA DIAZ ESPARZA             	39	3	1992-09-19	1	CALLE 19H No 19-14 PORTAL CAMPESTRE NORT	3184800176	68001	1	5	0	2	1321	8 	2013-07-27	919	680000	68001	0	52	1.00	1.00	2014-05-10	0
847	1	43277946	MARIA JAKELINE VIVER	\N	\N	\N	\N	\N	8 	8 	43277946    	MARIA JAKELINE VIVEROS ORTIZ            	17	3	1981-03-08	1	CALLE 6 nO 4-200MZ 11	6894391	68001	1	1	0	2	3212	8 	2013-07-27	920	680000	68001	1	52	1.00	1.00	2014-05-10	0
848	1	109620199	JOHANNA PAOLA BARRER	\N	\N	\N	\N	\N	1 	1 	1096201993  	JOHANNA PAOLA BARRERA RODRIGUEZ         	17	3	1989-10-22	1	CRA 34B nO 58-76	3138714269	68001	1	5	0	2	52	32	2013-07-27	921	680000	68001	1	52	1.00	1.00	2014-05-10	0
849	1	109622135	CARLOS ERNESTO VIDES	\N	\N	\N	\N	\N	1 	1 	1096221354  	CARLOS ERNESTO VIDES PINTO              	15	3	1993-05-10	2	CALLE 26 No 61-41	3202801842	68001	1	7	0	2	21312	8 	2013-07-27	922	680000	68001	1	52	1.00	1.00	2014-05-10	0
850	1	63563365	YADIRA PEÑA RODRIGUE	\N	\N	\N	\N	\N	7 	7 	63563365    	YADIRA PEÑA RODRIGUEZ                   	17	3	1985-09-04	1	YADIRA PEÑA RODRIGUEZ	6408675	68001	2	1	0	5	14123	1 	2013-08-01	923	680000	68081	0	52	1.00	1.00	2014-05-10	0
851	1	110089059	MARTHA LILIANA GONZA	\N	\N	\N	\N	\N	9 	9 	1100890599  	MARTHA LILIANA GONZALEZ GOMEZ           	20	3	1988-11-29	1	CALLE 23 nO 28-45	6780481	68001	2	1	0	5	14545	8 	2013-08-12	924	1700000	68001	0	52	0.00	1.00	2014-05-10	0
852	1	91540567	OSCAR JAVIER CELIS A	\N	\N	\N	\N	\N	0 	0 	91540567    	OSCAR JAVIER CELIS ASCENCIO             	29	3	1985-06-29	1	CRA 29 NO 93-31	6313840	68001	2	1	0	5	1441323	8 	2013-08-08	925	2500000	68001	0	52	0.00	1.00	2014-05-10	0
853	1	110236058	NAYIBE GOMEZ CALA   	\N	\N	\N	\N	\N	2 	2 	1102360588  	NAYIBE GOMEZ CALA                       	17	3	1989-05-27	1	CARRERA 18 No 61-09 LA TRINIDAD	3005496423	68001	2	1	0	5	213	8 	2013-08-06	926	680000	68001	1	52	1.00	1.00	2014-05-10	0
854	1	109761001	JENNY CAMACHO HERNAN	\N	\N	\N	\N	\N	4 	4 	1097610012  	JENNY CAMACHO HERNANDEZ                 	17	3	1991-02-07	1	1	3132433125	68081	2	1	0	5	2132	8 	2013-08-02	927	680000	68081	1	52	1.00	1.00	2014-05-10	0
855	1	110237332	DANIA GRACIELA HERNA	\N	\N	\N	\N	\N	10	10	1102373326  	DANIA GRACIELA HERNANDEZ MELON          	40	3	1994-02-17	1	CALLE 6 nO 14-28 SAN RAFAEL	3153275817	68001	2	1	0	5	21323	8 	2013-08-13	928	680000	68001	0	52	1.00	1.00	2014-05-10	0
856	1	108522725	DALGY MARGARITA SIER	\N	\N	\N	\N	\N	3 	3 	1085227259  	DALGY MARGARITA SIERRA MARQUEZ          	17	3	1990-03-06	1	CALLE 19 No 24-55 SAN FRANCISCO	3167121045	68001	2	1	0	5	11335	8 	2015-01-03	929	680000	68001	1	52	1.00	1.00	2014-05-10	0
857	1	63552118	PRISCILLA GUARIN    	\N	\N	\N	\N	\N	4 	4 	63552118    	PRISCILLA GUARIN                        	17	3	1984-06-16	1	CARRERA 34 No 34-41	3004730438	68001	2	1	0	5	1231	8 	2013-08-24	930	680000	68001	0	52	1.00	1.00	2014-05-10	0
858	1	109865448	FABIAN ANDRES GARCIA	\N	\N	\N	\N	\N	4 	4 	1098654489  	FABIAN ANDRES GARCIA VERGARA            	15	3	1988-03-23	2	CARRERA 36 E No 58-43 BARRIO ALCAZAR	3106975971	68001	1	1	0	2	1311	8 	2014-07-02	931	680000	68001	1	52	1.00	1.00	2014-05-10	0
859	1	109593169	SERGIO NICOLAS GOMEZ	\N	\N	\N	\N	\N	2 	2 	1095931690  	SERGIO NICOLAS GOMEZ GARCIA             	15	3	1993-02-16	2	CARRERA 22 NO 19-68 PORTAL CAMPESTRE	6805955	68001	2	1	0	2	65436	8 	2013-08-16	932	680000	68001	1	52	1.00	1.00	2014-05-10	0
860	1	109618596	GABRIELA OVIEDO GONZ	\N	\N	\N	\N	\N	4 	4 	1096185968  	GABRIELA OVIEDO GONZALEZ                	17	3	1986-06-04	1	DIAGONAL 63 No 46-15 EL 20 DE AGOSTO	6219357	68001	2	1	0	2	13123	8 	2013-08-22	933	680000	68001	1	52	1.00	1.00	2014-05-10	0
861	1	63551057	JUDITH GOMEZ SANDOVA	\N	\N	\N	\N	\N	2 	2 	63551057    	JUDITH GOMEZ SANDOVAL                   	17	3	1984-06-12	1	calle 76 nO 20-08	3183416299	68001	1	1	0	2	12312	25	2013-08-22	934	680000	68001	0	52	1.00	1.00	2014-05-10	0
862	1	109620200	JORGE LEONARDO PRADA	\N	\N	\N	\N	\N	1 	1 	1096202002  	JORGE LEONARDO PRADA VERGARA            	15	3	1989-10-14	1	CALLE 52  no 34C-139 CHAPINERO	6025631	68001	2	1	0	2	2123	8 	2013-08-23	935	680000	68001	1	52	1.00	1.00	2014-05-10	0
863	1	109869812	SILVIA PATRICIA DUAR	\N	\N	\N	\N	\N	7 	7 	1098698123  	SILVIA PATRICIA DUARTE DUARTE           	17	3	1990-11-12	1	CALLE 57A No 43w-52 LOS ESTORAQUES	3212226555	68001	3	1	0	2	1312	8 	2013-09-01	936	680000	68001	1	52	1.00	1.00	2014-05-10	0
864	1	109582264	JHON FREDY BENAVIDES	\N	\N	\N	\N	\N	9 	9 	1095822646  	JHON FREDY BENAVIDES TORRES             	15	3	1995-01-16	2	URBANIZACION PLAZA SAN MARCOS - RM	3174676859	68001	1	1	0	2	589500	40	2013-09-01	937	680000	68001	1	52	1.00	1.00	2014-05-10	0
865	1	110050240	DORIS EDILIA RUIZ CH	\N	\N	\N	\N	\N	3 	3 	1100502400  	DORIS EDILIA RUIZ CHIA                  	17	3	1989-02-26	1	CALLE 14 NO 21-31 SAN FRANCISCO	6710083	68001	2	1	0	1	231232	8 	2013-09-08	938	680000	68001	1	52	1.00	1.00	2014-05-10	0
866	1	109581855	PAOLA ANDREA DAVILA 	\N	\N	\N	\N	\N	2 	2 	1095818554  	PAOLA ANDREA DAVILA URIBE               	17	3	1994-01-03	1	CALLE 123 No 47-28 ZAPAMANGA	6493610	68001	2	1	0	2	45213	8 	2013-09-08	939	680000	68001	1	52	1.00	1.00	2014-05-10	0
867	1	37862124	EDUVIGES LINETT VESG	\N	\N	\N	\N	\N	7 	7 	37862124    	EDUVIGES LINETT VESGA GALEANO           	18	3	1991-06-27	1	CALLE 2B NO 16A-38	3163069445	68001	1	1	0	4	13123	26	2013-09-26	950	1200000	68001	0	52	1.00	1.00	2014-05-10	0
868	1	109873285	DENIA CENITH ALVAREZ	\N	\N	\N	\N	\N	7 	7 	1098732853  	DENIA CENITH ALVAREZ RIVERA             	17	3	1993-01-04	1	CALLE 68 No 6-66 BUCARAMANGA	318872270	68001	1	1	0	2	123	40	2013-10-19	953	680000	68001	1	52	1.00	1.00	2014-05-10	0
869	1	109580602	YANIT LIZET VEGA PAT	\N	\N	\N	\N	\N	8 	8 	1095806029  	YANIT LIZET VEGA PATIÑO                 	17	3	1990-07-08	1	MESA DE RUITOQUE VEREDA LA ESPERANZA	6786219	68001	2	1	0	2	2232	8 	2013-10-21	954	680000	68001	1	52	1.00	1.00	2014-05-10	0
870	1	109580735	PAOLA JIMENA SANCHEZ	\N	\N	\N	\N	\N	0 	0 	1095807359  	PAOLA JIMENA SANCHEZ TOBON              	29	1	1990-12-07	1	BLOQUE 10-9 APTO 302 BUCARICA	6045854	68001	1	7	0	3	13232	8 	2013-10-15	955	1100000	68001	0	51	1.00	1.00	2014-05-10	0
871	1	109864903	CARLOS ANDRES AYALA 	\N	\N	\N	\N	\N	12	12	1098649030  	CARLOS ANDRES AYALA DELGADO             	15	3	1988-01-26	2	CALLE 28 No 28-20 LA SALLE	6576640	68001	1	7	0	2	321221321	8 	2013-10-25	957	680000	68001	1	52	1.00	1.00	2014-05-10	0
872	1	37751149	MARIA JULIANA MOYA G	\N	\N	\N	\N	\N	0 	0 	37751149    	MARIA JULIANA MOYA GIRALDO              	29	1	2013-10-23	1	ALTOS DEL JARDIN CS 37	6439823	68001	1	7	0	4	11321	8 	2015-01-03	956	2300000	68001	0	51	0.00	1.00	2014-05-10	0
873	1	109581862	JOHAN JARWIN JARAMIL	\N	\N	\N	\N	\N	2 	2 	1095818629  	JOHAN JARWIN JARAMILLO JIMENEZ          	15	3	1994-03-06	2	FCSDGH	544635	68001	1	7	0	2	41362	8 	2013-10-29	959	680000	68001	0	52	1.00	1.00	2014-05-10	0
874	1	110237663	JHON FREDY VELOZA VI	\N	\N	\N	\N	\N	13	13	1102376637  	JHON FREDY VELOZA VILLAMIZAR            	15	3	1995-03-20	2	hyrtfhty	5223	68001	2	1	0	5	321	32	2013-11-08	960	680000	68001	1	52	1.00	1.00	2014-05-10	0
875	1	109581835	ASTRID KARYNA MARTIN	\N	\N	\N	\N	\N	2 	2 	1095818357  	ASTRID KARYNA MARTINEZ SANCHEZ          	17	3	1993-11-19	1	CALLE 200A N° 19-17	3186354845	68001	1	5	2	2	252526	8 	2012-06-13	744	680000	68001	1	52	1.00	1.00	2013-06-12	0
876	1	110237581	JULIETH VANESSAN CAB	\N	\N	\N	\N	\N	10	10	1102375812  	JULIETH VANESSAN CABRERA JAIMES         	17	3	1994-12-27	1	CALLE 2 CW91	6546217	68547	1	5	0	2	3566	8 	2013-01-25	848	680000	68547	1	52	1.00	1.00	2014-01-24	0
877	1	110237421	WENDY MELISSA LOPEZ 	\N	\N	\N	\N	\N	10	10	1102374213  	WENDY MELISSA LOPEZ MANRIQUE            	17	3	1994-05-25	1	CALLE 11 10-74	3157714890	68547	1	5	0	2	252525	8 	2013-01-25	849	680000	68001	1	52	1.00	1.00	2014-01-24	0
878	1	109867157	YULI MARCELA PINZON 	\N	\N	\N	\N	\N	7 	7 	1098671577  	YULI MARCELA PINZON                     	17	3	1989-05-17	1	CLL 21 No 28-50 apto 502	3163096986	68001	2	1	0	5	2556	23	2013-06-26	907	680000	68001	1	52	1.00	1.00	2014-05-10	0
879	1	109592041	FREDY SOCHA OVIEDO  	\N	\N	\N	\N	\N	2 	2 	1095920418  	FREDY SOCHA OVIEDO                      	15	3	1990-01-17	1	calle 104 No 40a-58 san bernardo	6773755	68001	2	1	0	5	132132	8 	2013-06-26	908	680000	68001	1	52	1.00	1.00	2014-05-10	0
880	1	13872902	SERGIO LEONARDO PORR	\N	\N	\N	\N	\N	9 	9 	13872902    	SERGIO LEONARDO PORRAS CALDERON         	33	3	1981-06-06	1	SECTOR D TORRE 6 APTO 503	6389080	68001	2	1	0	5	1321	8 	2013-06-25	909	840000	68001	0	52	1.00	1.00	2014-05-10	0
881	1	110234821	DIEGO ARMANGO BASTO 	\N	\N	\N	\N	\N	13	13	1102348211  	DIEGO ARMANGO BASTO NAVAS               	15	3	1985-11-16	2	,g,g}rtyu	2263	68001	2	1	0	5	12	25	2013-11-08	961	680000	68001	1	52	1.00	1.00	2014-05-10	0
882	1	13720403	GABRIEL CAMELO MANCE	\N	\N	\N	\N	\N	10	10	13720403    	GABRIEL CAMELO MANCERA                  	15	3	1979-06-24	2	rfewter	513	68001	2	1	0	1	232	8 	2015-02-19	962	680000	68001	0	52	1.00	1.00	2014-05-10	0
883	1	63475898	MONICA TORRES RINCON	\N	\N	\N	\N	\N	10	10	63475898    	MONICA TORRES RINCON                    	17	3	1973-08-27	1	csdf.sdkfe	11414	68001	2	1	0	1	5413	8 	2015-02-19	963	680000	68001	0	52	1.00	1.00	2014-05-10	0
884	1	13927357	CIRO ANTONIO PINTO M	\N	\N	\N	\N	\N	10	10	13927357    	CIRO ANTONIO PINTO MORENO               	33	3	1974-09-14	2	<z	6584	68001	2	1	0	2	531	8 	2015-02-19	964	770000	68001	0	52	1.00	1.00	2014-05-10	0
885	1	63316458	LUZ ESTHER CAMARGO A	\N	\N	\N	\N	\N	0 	0 	63316458    	LUZ ESTHER CAMARGO AVELLANEDA           	29	1	1965-06-17	1	mxcvxcv	68521	68001	2	1	0	2	2222	5 	2013-11-08	965	1500000	68001	0	51	0.00	1.00	2014-05-10	0
886	1	110088990	YURBY OCHOA GONGALEZ	\N	\N	\N	\N	\N	10	10	1100889901  	YURBY OCHOA GONGALEZ                    	39	3	1988-07-03	1	vdfdghd	493	68001	2	1	0	2	13213	40	2013-11-08	966	680000	68001	0	52	1.00	1.00	2014-05-10	0
887	1	110237134	JESSICA PAOLA FLOREZ	\N	\N	\N	\N	\N	13	13	1102371340  	JESSICA PAOLA FLOREZ OVIEDO             	17	3	1993-06-17	1	dvgdfgh	6555	68001	2	1	0	2	2333	8 	2013-11-08	967	680000	68001	1	52	1.00	1.00	2014-05-10	0
888	1	110236876	YESSICA PAOLA CAMACH	\N	\N	\N	\N	\N	10	10	1102368768  	YESSICA PAOLA CAMACHO DURAN             	17	3	1992-03-15	1	dfddfgg	5558936	68001	2	2	0	2	1213	8 	2013-11-14	968	680000	68001	1	52	1.00	1.00	2014-05-10	0
889	1	109872466	JERSON LEANDRO VILLA	\N	\N	\N	\N	\N	9 	9 	1098724661  	JERSON LEANDRO VILLAMIZAR MALDONADO     	15	3	1992-08-01	2	fgdh	47257	68001	2	1	0	2	21632	8 	2013-11-14	969	680000	68001	1	52	1.00	1.00	2014-05-10	0
890	1	109876244	SANDRID LORENA PEIND	\N	\N	\N	\N	\N	10	10	1098762448  	SANDRID LORENA PEINDO QUESADA           	17	3	1994-11-10	1	132	35555	68001	2	1	0	2	52555	8 	2013-11-14	970	680000	68001	0	52	1.00	1.00	2014-05-10	0
891	1	91530564	OSCAR MAURICIO DIAZ 	\N	\N	\N	\N	\N	3 	3 	91530564    	OSCAR MAURICIO DIAZ GUZMAN              	34	3	1984-07-17	2	xcvcx	6544	68001	2	1	0	2	25558	8 	2013-11-13	971	1250000	68001	1	52	0.00	1.00	2014-05-10	0
894	1	103968550	AURA MARCELA MARIN L	\N	\N	\N	\N	\N	4 	4 	1039685508  	AURA MARCELA MARIN LOPERA               	17	3	1988-07-03	1	CARREA 15B No 53-33	3136038575	68001	2	1	0	2	6346	8 	2013-11-16	978	680000	68001	1	52	1.00	1.00	2014-05-10	0
895	1	109864325	MARIA FERNANDA GAMBO	\N	\N	\N	\N	\N	9 	9 	1098643251  	MARIA FERNANDA GAMBOA CAICEDO           	16	3	1987-06-22	1	bngfh	53265	68001	2	1	0	2	52163	8 	2013-11-10	974	840000	68001	0	52	1.00	1.00	2014-05-10	0
896	1	63454411	LEIDY JOHANNA HERNAN	\N	\N	\N	\N	\N	2 	2 	63454411    	LEIDY JOHANNA HERNANDEZ PIÑA            	17	3	1985-11-15	1	ghfjh	55558	68001	2	1	0	4	52653	8 	2013-11-06	975	680000	68001	0	52	1.00	1.00	2014-05-10	0
897	1	110236008	JUAN JOSE LEON ROA  	\N	\N	\N	\N	\N	8 	8 	1102360084  	JUAN JOSE LEON ROA                      	15	3	1989-02-26	2	hfghg	55478	68001	2	1	0	5	2558	8 	2013-11-06	976	680000	68001	1	52	1.00	1.00	2014-05-01	0
898	1	109593843	LAURA LIZZETH MERLO 	\N	\N	\N	\N	\N	12	12	1095938432  	LAURA LIZZETH MERLO PEDROZA             	17	3	1994-10-12	2	dfsgdfg	54136	68001	2	1	0	5	558	8 	2014-07-16	977	680000	68001	0	52	1.00	1.00	2014-05-10	0
899	1	109867702	CARLOS MAURICIO DIAZ	\N	\N	\N	\N	\N	12	12	1098677029  	CARLOS MAURICIO DIAZ MEJIA              	20	3	1989-10-03	2	CALLE 10B-26-16 ARENALES II ETAPA	3164065183	68001	2	1	0	2	220	40	2013-11-18	979	1700000	68001	0	52	0.00	1.00	2014-05-10	0
900	1	109869214	VIVIANA VILLAMIZAR M	\N	\N	\N	\N	\N	4 	4 	1098692147  	VIVIANA VILLAMIZAR MEJIA                	17	3	1990-07-19	1	1	1	68001	2	1	0	2	236310	8 	2013-11-16	980	680000	68001	1	52	1.00	1.00	2014-05-10	0
901	1	108516742	JOSE MANUEL CASTRO L	\N	\N	\N	\N	\N	4 	4 	1085167421  	JOSE MANUEL CASTRO LENGUA               	15	3	1988-05-16	2	1	1	68081	2	1	0	2	2323	25	2014-07-02	981	680000	68081	1	52	1.00	1.00	2014-05-10	0
902	1	109619966	EUGENIO POLO JIMENEZ	\N	\N	\N	\N	\N	1 	1 	1096199666  	EUGENIO POLO JIMENEZ                    	15	3	1988-12-15	2	1	1	68081	2	1	0	2	32223	40	2013-11-20	982	680000	68081	1	52	1.00	1.00	2014-05-10	0
906	1	109581259	JESUS ALBERTO PARRA 	\N	\N	\N	\N	\N	12	12	1095812599  	JESUS ALBERTO PARRA LANDAZABAL          	14	3	1992-06-27	2	1	1	68081	1	2	0	2	55854	8 	2013-11-21	985	680000	68001	0	52	1.00	1.00	2014-05-10	0
907	1	37949489	LILIAM ROCIO VARGAS 	\N	\N	\N	\N	\N	2 	2 	37949489    	LILIAM ROCIO VARGAS BAREÑO              	17	3	1984-08-22	1	1	1	68001	2	1	0	5	223223	8 	2013-11-21	986	680000	68001	1	52	1.00	1.00	2014-05-10	0
908	1	109592417	JENNIFER ANDREA PINT	\N	\N	\N	\N	\N	9 	9 	1095924172  	JENNIFER ANDREA PINTO JEREZ             	16	3	1989-08-31	1	1	1	68001	2	1	0	5	1135	8 	2014-07-04	987	840000	68001	0	52	1.00	1.00	2014-05-10	0
909	1	109620108	LEIDY JOHANNA CAMARG	\N	\N	\N	\N	\N	4 	4 	1096201088  	LEIDY JOHANNA CAMARGO CASTRILLON        	17	3	1989-08-21	1	1	1	68001	1	1	0	2	456	8 	2014-01-03	988	680000	68001	1	52	1.00	1.00	2014-05-10	0
910	1	109871708	DAYANA CAROLINA CHAR	\N	\N	\N	\N	\N	9 	9 	1098717087  	DAYANA CAROLINA CHARRY AGUANCHA         	11	3	1992-01-19	1	1	1	68001	2	1	0	2	56556	8 	2014-12-17	989	680000	68001	0	52	1.00	1.00	2014-05-10	0
911	1	109876545	JUAN SEBASTIAN LEGUI	\N	\N	\N	\N	\N	7 	7 	1098765450  	JUAN SEBASTIAN LEGUIZAMO CRISTANCHO     	15	3	1995-01-25	2	1	1	68001	2	1	0	2	66655	8 	2013-11-26	991	680000	68001	1	52	1.00	1.00	2014-05-10	0
912	1	109868507	LISSETH DANIELA CUBI	\N	\N	\N	\N	\N	9 	9 	1098685078  	LISSETH DANIELA CUBIDES ARENAS          	17	3	1990-04-07	1	1	1	68001	2	1	0	5	1678841	8 	2013-11-26	992	680000	68001	1	52	1.00	1.00	2014-05-10	0
913	1	109593031	GLORIA ANGELICA HERN	\N	\N	\N	\N	\N	0 	0 	1095930318  	GLORIA ANGELICA HERNANDEZ GUARIN        	29	1	1992-10-05	1	CARRERA 21B No 22-82	6822891	68001	1	1	0	3	212332	8 	2014-07-03	958	1100000	68001	0	51	1.00	1.00	2014-05-10	0
914	1	63553581	SANDRA MILENA CRISTA	\N	\N	\N	\N	\N	12	12	63553581    	SANDRA MILENA CRISTANCHO BARRERA        	17	3	1984-08-06	1	CALLE 11No 10A -13 TORRE 16 APTO 201	6408871	68001	2	1	2	2	2312341	8 	2013-12-01	993	680000	68001	1	52	1.00	1.00	2014-05-10	0
915	1	63557673	MAYERLI JOHANA JIMEN	\N	\N	\N	\N	\N	12	12	63557673    	MAYERLI JOHANA JIMENEZ                  	17	3	1984-09-14	1	carrer a22 No 10b -19	3174851260	68001	2	1	0	2	2112	5 	2013-12-01	994	680000	68001	0	52	1.00	1.00	2014-05-10	0
916	1	109619703	YENERITZA ARIAS     	\N	\N	\N	\N	\N	4 	4 	1096197032  	YENERITZA ARIAS                         	17	3	1988-06-15	1	CASA 47  COLINAS DEL SEMINARIO	3208454158	68081	1	1	0	2	2525	8 	2013-01-02	740	680000	68081	1	52	1.00	1.00	2013-05-27	0
917	1	109620081	KARINA FRUTO ANGULO 	\N	\N	\N	\N	\N	4 	4 	1096200811  	KARINA FRUTO ANGULO                     	17	3	1989-01-30	1	LOTE 52 MZ 08	3144515381	68081	1	1	0	2	212321	8 	2011-11-01	856	680000	68081	1	52	1.00	1.00	2014-02-01	0
918	1	109580407	SILVIA CONSUELO COMB	\N	\N	\N	\N	\N	4 	4 	1095804073  	SILVIA CONSUELO COMBITA ARDILA          	17	3	1990-01-23	1	CRA. 15 N° 47-65	6020241	68001	1	4	0	2	252525	8 	2013-02-03	761	680000	68001	1	52	1.00	1.00	2013-08-08	0
919	1	63531250	ANDREA JULIANA GONZA	\N	\N	\N	\N	\N	9 	9 	63531250    	ANDREA JULIANA GONZALEZ                 	17	3	1992-07-25	1	CALLE 57 No 3W-77 PISO 3	6441794	68001	3	1	0	2	25233	8 	2013-12-01	995	680000	68001	1	52	1.00	1.00	2014-05-10	0
920	1	109866092	HEIDY CAMILA BALAGUE	\N	\N	\N	\N	\N	2 	2 	1098660929  	HEIDY CAMILA BALAGUERA GUERRERO         	17	3	1988-09-18	1	CALLE 57 No 15-135	6491780	68001	2	1	0	2	21223	8 	2013-12-04	996	680000	68001	1	52	1.00	1.00	2014-05-10	0
921	1	109876029	YERLY KATHERINE LEAL	\N	\N	\N	\N	\N	9 	9 	1098760297  	YERLY KATHERINE LEAL FLOREZ             	17	3	1994-09-11	1	CALLE 104 No 7A -06	6958844	68001	2	1	0	2	2323	8 	2013-12-01	997	680000	68001	1	52	1.00	1.00	2014-05-10	0
922	1	91519963	CHARLY GARCIA ALVARA	\N	\N	\N	\N	\N	3 	3 	91519963    	CHARLY GARCIA ALVARADO                  	15	3	1981-12-06	2	CALLE 19 No 19-56	3152057893	68001	2	1	0	5	12362	8 	2013-12-01	998	680000	68001	1	52	1.00	1.00	2014-05-10	0
923	1	109580493	DIEGO DUEÑAS PINZON 	\N	\N	\N	\N	\N	2 	2 	1095804932  	DIEGO DUEÑAS PINZON                     	15	3	1990-05-07	2	CALLE 14 B No 15-50	3134889937	68001	2	1	0	2	1341	8 	2014-01-19	999	680000	68001	1	52	1.00	1.00	2014-05-10	0
924	1	109618319	RONALD DELGADO SILVA	\N	\N	\N	\N	\N	9 	9 	1096183191  	RONALD DELGADO SILVA                    	15	3	1986-05-02	2	CARRERA 18 No 30A -08 MAZ C CASA 7	6991380	68001	2	1	0	5	2323636	8 	2013-12-06	1000	680000	68001	1	52	1.00	1.00	2014-05-10	0
925	1	109864990	OSCAR HERNANDO BARAJ	\N	\N	\N	\N	\N	2 	2 	1098649907  	OSCAR HERNANDO BARAJAS SANCHEZ          	15	3	1987-03-02	2	CARRERA 8 No 10-37	3154048423	68001	1	1	0	2	132	5 	2014-02-02	1001	680000	68001	1	52	1.00	1.00	2014-05-10	0
926	1	109874190	OSCAR FERNANDO ORTIZ	\N	\N	\N	\N	\N	3 	3 	1098741908  	OSCAR FERNANDO ORTIZ PRADA              	15	3	1993-08-09	2	DIAGO 14 No 56-22 TORR 1 APTO 703	6040617	68001	1	1	0	2	5213	8 	2013-12-10	1002	680000	68001	1	52	1.00	1.00	2014-05-10	0
927	1	109876925	JOAN SEBASTIAN ORTIZ	\N	\N	\N	\N	\N	9 	9 	1098769257  	JOAN SEBASTIAN ORTIZ PRADA              	14	3	1995-05-18	2	diagonal 14 nO 56-22	6040617	68001	2	1	0	4	1121	26	2014-07-02	1003	740000	68001	0	52	1.00	1.00	2014-05-10	0
928	1	109871413	ERIKA TATIANA RAMIRE	\N	\N	\N	\N	\N	12	12	1098714136  	ERIKA TATIANA RAMIREZ COBOS             	17	3	1991-11-27	1	calle 103g nO 10-67	6372573	68001	1	1	0	2	1312	8 	2013-12-01	1004	680000	68001	1	52	1.00	1.00	2014-05-10	0
929	1	109869776	GINA LUZ CERVANTES B	\N	\N	\N	\N	\N	8 	8 	1098697761  	GINA LUZ CERVANTES BRIEVA               	17	3	1990-11-25	1	CALLE 148 No 44-04	3177413624	68001	2	1	0	2	132	8 	2013-12-04	1005	680000	68001	1	52	1.00	1.00	2014-05-10	0
930	1	109619945	JOHANY BELLO PLATA  	\N	\N	\N	\N	\N	1 	1 	1096199456  	JOHANY BELLO PLATA                      	15	3	1988-12-14	2	CALLE 60 No 37-05	6024241	68081	2	1	0	5	52413	8 	2013-12-17	1009	680000	68081	1	52	1.00	1.00	2014-05-10	0
932	1	109865081	GENNY JOHANA ABRIL T	\N	\N	\N	\N	\N	7 	7 	1098650812  	GENNY JOHANA ABRIL TORRES               	17	3	1988-03-19	1	1	1	68001	2	1	0	5	32	40	2013-12-27	1011	680000	68001	1	52	1.00	1.00	2014-05-10	0
933	1	63530401	DIANA MILENA DUARTE 	\N	\N	\N	\N	\N	2 	2 	63530401    	DIANA MILENA DUARTE PEREZ               	17	3	1982-04-25	1	1	1	68001	2	1	0	5	213	8 	2013-12-27	1012	680000	68001	1	52	1.00	1.00	2014-05-10	0
934	1	109870181	JOHN FREDDY BLANCO R	\N	\N	\N	\N	\N	7 	7 	1098701815  	JOHN FREDDY BLANCO RUIZ                 	15	3	1991-03-14	2	1	1	68001	2	1	0	5	32123	26	2013-12-28	1013	680000	68001	1	52	1.00	1.00	2014-05-10	0
935	1	109871315	YULY ANDREA QUINTERO	\N	\N	\N	\N	\N	10	10	1098713151  	YULY ANDREA QUINTERO TORO               	17	3	1991-11-05	1	1	1	68001	2	1	0	5	213	5 	2014-10-04	1014	680000	68001	1	52	1.00	1.00	2014-05-10	0
936	1	110236203	FREDY ALEXANDER PALO	\N	\N	\N	\N	\N	10	10	1102362034  	FREDY ALEXANDER PALOMINO MORENO         	15	3	1989-09-17	2	1	4	68001	2	1	0	5	213	8 	2013-12-29	1015	680000	68001	1	52	1.00	1.00	2014-05-10	0
937	1	109876234	ANA PATRICIA CANTOR 	\N	\N	\N	\N	\N	7 	7 	1098762341  	ANA PATRICIA CANTOR MOSQUERA            	17	3	1994-08-15	1	CALLE 18 No 19-49 SAN FRANCISCO	3114440056	68001	2	1	0	2	24132	8 	2014-01-03	1016	680000	68001	1	52	1.00	1.00	2014-05-10	0
938	1	109424877	NELCY ALEXANDRA CARR	\N	\N	\N	\N	\N	7 	7 	1094248773  	NELCY ALEXANDRA CARRILLO DUARTE         	17	3	1989-11-05	1	CALLE 20 no 31-51 PISO 2 SAN ALONSO	6451251	68001	1	7	0	2	132123	8 	2014-01-05	1017	680000	68001	0	52	1.00	1.00	2014-05-10	0
939	1	63561024	ZAIRA HERNANDEZ MART	\N	\N	\N	\N	\N	9 	9 	63561024    	ZAIRA HERNANDEZ MARTINEZ                	17	3	1985-06-03	1	1	1	68001	2	1	0	5	123112	8 	2014-01-15	1022	680000	68001	1	52	1.00	1.00	2014-05-10	0
940	1	109264535	JOSE BERNARDO GELVEZ	\N	\N	\N	\N	\N	12	12	1092645351  	JOSE BERNARDO GELVEZ CONTRERAS          	15	3	2014-02-01	2	CARRERA 11 No 29-13 LA CUMBRE	6581377	68001	2	1	0	5	4312	8 	2014-02-01	1040	680000	68001	1	52	1.00	1.00	2014-05-10	0
941	1	109861547	JULIAN YESID MORENO 	\N	\N	\N	\N	\N	8 	8 	1098615476  	JULIAN YESID MORENO GONZALEZ            	15	3	1986-05-18	2	CARRERA 6A No 58-80 PISO 5	6798223	68001	2	1	0	2	1322	8 	2014-03-05	1055	680000	68001	1	52	1.00	1.00	2014-05-10	0
942	1	109580679	HAIVER YESID JAIMES 	\N	\N	\N	\N	\N	8 	8 	1095806790  	HAIVER YESID JAIMES SILVA               	15	3	1990-10-28	1	1	1	68001	2	1	0	2	131321	8 	2004-05-10	1041	680000	68001	1	52	1.00	1.00	2014-05-10	0
943	1	110236307	LEYDI ANDREA BARRERA	\N	\N	\N	\N	\N	8 	8 	1102363073  	LEYDI ANDREA BARRERA TOLOZA             	17	3	1990-03-16	1	1	1	68001	2	1	0	5	13232	8 	2014-10-18	1042	680000	68001	1	52	1.00	1.00	2014-05-10	0
944	1	109622451	HAROLD ANDRES ROJAS 	\N	\N	\N	\N	\N	4 	4 	1096224511  	HAROLD ANDRES ROJAS ALVAREZ             	15	3	1993-10-23	2	TRANSV 45 No 60-54	3123514590	68001	2	1	0	5	14323	26	2014-02-02	1043	680000	68081	1	52	1.00	1.00	2014-05-10	0
945	1	109621068	MARIA TERESA CAMPO G	\N	\N	\N	\N	\N	1 	1 	1096210682  	MARIA TERESA CAMPO GOMEZ                	17	3	1989-10-01	1	1	1	68001	2	1	0	5	4545	8 	2014-02-08	1044	680000	68001	1	52	1.00	1.00	2014-05-10	0
946	1	109872052	JONATAN DAVID BALLES	\N	\N	\N	\N	\N	9 	9 	1098720528  	JONATAN DAVID BALLESTEROS SANCHEZ       	15	3	1991-10-21	1	1	6410345	68001	2	1	0	5	13223	8 	2014-02-12	1045	680000	68001	1	52	1.00	1.00	2014-05-10	0
947	1	109621915	JOHANA PAOLA AGUIRRE	\N	\N	\N	\N	\N	1 	1 	1096219153  	JOHANA PAOLA AGUIRRE                    	17	3	1992-11-22	1	1	1	68001	2	1	0	2	12323	8 	2014-02-01	1046	680000	68001	1	52	1.00	1.00	2004-05-10	0
948	1	109694878	FREDY ORLANDO VEGA B	\N	\N	\N	\N	\N	7 	7 	1096948786  	FREDY ORLANDO VEGA BARRIOS              	15	3	1988-03-06	2	1	1	68001	2	1	0	5	23123	26	2014-02-05	1047	680000	68001	1	52	1.00	1.00	2014-05-10	0
949	1	13871033	JHON FREDY SOTO VELA	\N	\N	\N	\N	\N	9 	9 	13871033    	JHON FREDY SOTO VELANDIA                	15	3	2014-02-06	2	1	1	68001	2	1	0	5	2232	8 	2014-02-06	1048	680000	68001	0	52	1.00	1.00	2014-05-10	0
950	1	109868760	GLORIA YAMILE CONTRE	\N	\N	\N	\N	\N	8 	8 	1098687608  	GLORIA YAMILE CONTRERAS ESTEBAN         	17	3	1990-05-20	1	1	6421915	68001	2	1	0	2	41333333323	8 	2014-03-02	1056	680000	68001	1	52	1.00	1.00	2014-05-10	0
951	1	109621596	YULIS MARCELA GIL MA	\N	\N	\N	\N	\N	4 	4 	1096215964  	YULIS MARCELA GIL MARTINEZ              	17	3	1992-04-30	1	FD,FMDG,	31275115511	68001	2	1	0	2	121214	8 	2014-03-06	1057	680000	68001	1	52	1.00	1.00	2014-05-10	0
952	1	109622436	WENDY YULIZA ZABALA 	\N	\N	\N	\N	\N	4 	4 	1096224365  	WENDY YULIZA ZABALA VASQUEZ             	17	3	1993-09-30	1	MANZABNA 49 LOTE 2	3138647983	68001	2	1	0	4	14653522	8 	2014-03-04	1058	680000	68001	1	52	1.00	1.00	2014-05-10	0
953	1	109581607	DIANA LIZETH AYALA A	\N	\N	\N	\N	\N	10	10	1095816074  	DIANA LIZETH AYALA ARCE                 	16	3	1993-06-25	1	CALLE 5A N° 14-88	3168906290	68001	1	6	0	2	2525	8 	2012-10-12	782	770000	68001	0	52	1.00	1.00	2013-10-11	0
954	1	110235333	FABIAN MARTINEZ JURA	\N	\N	\N	\N	\N	8 	8 	1102353333  	FABIAN MARTINEZ JURADO                  	15	3	1987-07-23	2	1	1	68001	2	1	0	5	1323	8 	2014-01-14	1018	680000	68001	1	52	1.00	1.00	2014-05-10	0
955	1	109593594	KAREN JULIETH SUAREZ	\N	\N	\N	\N	\N	8 	8 	1095935948  	KAREN JULIETH SUAREZ RUEDA              	17	3	1994-03-15	1	1	1	68001	2	1	0	5	21132	8 	2014-01-14	1019	680000	68001	1	52	1.00	1.00	2014-05-10	0
956	1	63507899	MARIA YANETH MURILLO	\N	\N	\N	\N	\N	12	12	63507899    	MARIA YANETH MURILLO GALEON             	40	3	1975-11-20	1	1	1	68001	2	1	0	2	513	8 	2014-01-14	1020	680000	68001	0	52	1.00	1.00	2014-05-10	0
957	1	63545374	LUZ KARIME CANCINO G	\N	\N	\N	\N	\N	12	12	63545374    	LUZ KARIME CANCINO GAMBOA               	17	3	1983-10-06	1	1	1	68001	2	1	0	5	131	8 	2014-01-14	1021	680000	68001	1	52	1.00	1.00	2014-05-10	0
958	1	109835751	JESUS APARICIO MUÑOZ	\N	\N	\N	\N	\N	8 	8 	1098357518  	JESUS APARICIO MUÑOZ                    	15	3	1991-04-01	2	CALLE 110 nO 34A-05	6366065	68001	2	1	0	5	1322	8 	2013-06-25	910	680000	68001	1	52	1.00	1.00	2014-05-10	0
959	1	100538643	DIANA MARCELA HERRER	\N	\N	\N	\N	\N	9 	9 	1005386431  	DIANA MARCELA HERRERA GAMBOA            	17	3	1995-07-14	1	1	6770215	68001	2	1	0	5	13213	8 	2014-07-04	1060	680000	68001	0	52	1.00	1.00	2014-05-10	0
960	1	37398527	LEYDIS ANDREA LEAL J	\N	\N	\N	\N	\N	0 	0 	37398527    	LEYDIS ANDREA LEAL JOVES                	29	3	1985-02-22	1	1	3204742853	68001	2	1	0	2	21256	8 	2014-03-17	1061	770000	68001	0	51	1.00	1.00	2014-05-10	0
961	1	109621379	SINDY VANESSA MARQUE	\N	\N	\N	\N	\N	1 	1 	1096213794  	SINDY VANESSA MARQUEZ MARTINEZ          	17	3	2014-03-19	1	1	3106697819	68001	1	1	0	2	132121	8 	2014-03-20	1062	680000	68001	1	52	1.00	1.00	2014-05-10	0
962	1	109875689	LEIDY TATIANA TRUJIL	\N	\N	\N	\N	\N	7 	7 	1098756892  	LEIDY TATIANA TRUJILLO ZARATE           	17	3	1994-06-10	1	1	6946562	68001	1	1	0	5	21232	8 	2014-10-22	1063	680000	68001	1	52	1.00	1.00	2014-05-10	0
963	1	110236108	MARISOL MENDOZA MENE	\N	\N	\N	\N	\N	8 	8 	1102361083  	MARISOL MENDOZA MENESES                 	17	3	1988-05-09	1	1	3182772355	68001	2	1	0	1	524132	8 	2014-03-23	1064	680000	68001	1	52	1.00	1.00	2014-05-10	0
964	1	63539553	MARIA DEL PILAR ESTE	\N	\N	\N	\N	\N	7 	7 	63539553    	MARIA DEL PILAR ESTEBAN MONSALVE        	17	3	1983-04-15	1	1	1	68081	2	1	0	2	123121	8 	2014-10-17	1065	680000	68081	0	52	1.00	1.00	2014-05-10	0
965	1	109593291	JHON JAIRO DIAZ CALD	\N	\N	\N	\N	\N	12	12	1095932919  	JHON JAIRO DIAZ CALDERON                	107	3	2014-03-27	2	1	1	68001	2	1	0	2	423121	26	2014-03-27	1066	680000	68001	0	52	1.00	1.00	2014-05-10	0
966	1	109862344	ELKIN HORACIO CELIS 	\N	\N	\N	\N	\N	10	10	1098623448  	ELKIN HORACIO CELIS JAIMES              	15	3	1986-09-15	2	1	1	68001	2	1	0	2	4123	8 	2014-03-27	1067	680000	68001	1	52	1.00	1.00	2014-05-10	0
967	1	109581582	JHONATAN DELGADO QUI	\N	\N	\N	\N	\N	2 	2 	1095815822  	JHONATAN DELGADO QUINTERO               	15	3	1993-05-01	1	CALLE 6 No 4-87 SANTA ANA	6394336	68001	2	1	0	2	532132	8 	2014-04-03	1069	680000	68001	0	52	1.00	1.00	2014-05-10	0
968	1	109593134	DAVIDSON DIAZ CORZO 	\N	\N	\N	\N	\N	3 	3 	1095931344  	DAVIDSON DIAZ CORZO                     	15	3	1993-01-19	2	1	6531551	68001	2	1	0	5	2312321	26	2014-03-11	1059	680000	68001	1	52	1.00	1.00	2014-05-10	0
969	1	74371951	JOSE FERNANDO SANCHE	\N	\N	\N	\N	\N	1 	1 	74371951    	JOSE FERNANDO SANCHEZ HUESA             	12	3	1977-04-12	2	CARRERA 2A No 55A-14	3168266275	68001	1	5	0	2	1321213	8 	2014-04-09	1070	2300000	68001	1	52	0.00	1.00	2014-05-10	0
970	1	91495908	CESAR AUGUSTO SILVA 	\N	\N	\N	\N	\N	2 	2 	91495908    	CESAR AUGUSTO SILVA MONSALVE            	14	3	1976-12-13	2	CRA. 6C N° 1NE -53 CASA 435 MZ W	6550881	68001	1	5	2	3	25250	8 	2012-07-11	749	800000	68001	1	52	1.00	1.00	2013-07-10	0
971	1	109592204	DIEGO ALEXANDER PIMI	\N	\N	\N	\N	\N	9 	9 	1095922040  	DIEGO ALEXANDER PIMIENTO ORREGO         	15	3	1990-06-18	2	DIAGONAL 8B No 20A-19	6591297	68001	2	1	0	2	1221321	8 	2014-07-02	1075	680000	68001	1	52	1.00	1.00	2014-05-10	0
972	1	109875232	MARLON HUMBERTI NAVA	\N	\N	\N	\N	\N	10	10	1098752326  	MARLON HUMBERTI NAVARRO SACHICA         	15	3	1994-03-12	2	CALLE 1C No 7-08 VILLA NUEVA DEL CAMPO	6563160	68001	2	1	0	2	21214413	8 	2014-04-17	1076	680000	68001	1	52	1.00	1.00	2014-05-10	0
973	1	109875488	ORLANDO JOSE MARTINE	\N	\N	\N	\N	\N	10	10	1098754886  	ORLANDO JOSE MARTINEZ AVILA             	15	3	1993-12-09	2	MANZANA K CASA 10	3138731203	68001	1	1	0	2	131	8 	2014-04-17	1077	680000	68001	0	52	1.00	1.00	2004-05-10	0
974	1	91467406	HECTOR FABIO CAMACHO	\N	\N	\N	\N	\N	2 	2 	91467406    	HECTOR FABIO CAMACHO                    	34	3	1989-10-03	2	CARRERA 8W No 61-18	3164754747	68001	2	1	0	5	13212	8 	2014-04-04	1071	1700000	68001	0	52	0.00	1.00	2014-05-10	0
975	1	109621969	CLAUDIA PATRICIA HER	\N	\N	\N	\N	\N	7 	7 	1096219699  	CLAUDIA PATRICIA HERRERA MARTINEZ       	39	3	1992-12-06	1	CARRERA 23 No 5N-08	6736025	68001	2	1	0	1	215565	8 	2014-04-17	1078	680000	68001	0	52	1.00	1.00	2014-05-10	0
976	1	37549654	PATRICIA SARMIENTO S	\N	\N	\N	\N	\N	10	10	37549654    	PATRICIA SARMIENTO SILVA                	17	3	1978-01-22	1	CALLE 107 No 50-13	6770977	68001	2	1	0	2	13	8 	2014-10-04	1079	680000	68001	1	52	1.00	1.00	2014-05-10	0
977	1	109872908	PAULA ANDREA ACUÑA B	\N	\N	\N	\N	\N	7 	7 	1098729088  	PAULA ANDREA ACUÑA BELLO                	17	3	1992-10-14	1	CARRERA 18 No 10-50	3156504385	68001	2	1	0	2	45421214	8 	2014-04-24	1080	680000	68001	0	52	1.00	1.00	2014-05-10	0
978	1	109873332	JORGE IVAN OTERO HER	\N	\N	\N	\N	\N	7 	7 	1098733322  	JORGE IVAN OTERO HERNANDEZ              	15	3	1993-01-01	2	CALLE 16 NO 25-75	3172689030	68001	2	1	0	2	13230	8 	2014-04-17	1081	680000	68001	0	52	1.00	1.00	2014-05-10	0
979	1	109865593	MARLY JASMIN CORZO R	\N	\N	\N	\N	\N	0 	0 	1098655932  	MARLY JASMIN CORZO RODRIGUEZ            	29	3	1988-03-28	1	MDCDG	6908163	68001	1	1	0	5	432223	8 	2014-07-03	1082	2500000	68001	0	52	0.00	1.00	2004-05-10	0
980	1	109619991	EDWIN ALEXANDER CUEV	\N	\N	\N	\N	\N	1 	1 	1096199916  	EDWIN ALEXANDER CUEVAS GUERRERO         	15	3	1989-02-23	2	fdfdfyhytf	2112	68001	2	1	0	5	132123	8 	2014-05-05	1085	680000	68001	0	52	1.00	1.00	2004-05-10	0
981	1	105055267	YULIS ESTHER ULLOA M	\N	\N	\N	\N	\N	1 	1 	1050552676  	YULIS ESTHER ULLOA MACHADO              	17	3	1994-10-10	1	dcffcg	132	68001	1	1	0	2	12136	5 	2014-10-04	1086	680000	68001	1	52	1.00	1.00	2004-05-10	0
982	1	109619591	GLORIA STELLA HERRER	\N	\N	\N	\N	\N	1 	1 	1096195910  	GLORIA STELLA HERRERA GONZALEZ          	17	3	1988-08-05	1	,clsdfnsd	6224514	68001	2	1	0	2	21	23	2014-05-07	1087	680000	68001	1	52	1.00	1.00	2004-05-10	0
983	1	109620618	NELLY JHIVED JARAMIL	\N	\N	\N	\N	\N	1 	1 	1096206189  	NELLY JHIVED JARAMILLO LEAL             	17	3	1990-06-22	1	gfghjkhlk	6800	68001	1	1	0	2	541263	8 	2014-05-09	1088	680000	68001	1	52	1.00	1.00	2004-05-10	0
984	1	110236849	MAGALY CARRILLO RICO	\N	\N	\N	\N	\N	8 	8 	1102368490  	MAGALY CARRILLO RICO                    	17	3	1992-03-14	1	dfyui	68001	68001	1	1	0	2	13122	8 	2014-05-09	1089	680000	68001	1	52	1.00	1.00	2004-05-10	0
985	1	91527677	GEOVANNY GOMEZ OLIVE	\N	\N	\N	\N	\N	0 	0 	91527677    	GEOVANNY GOMEZ OLIVEROS                 	29	1	1984-01-16	2	1	1	68001	2	1	0	5	212323	8 	2014-02-24	1049	1100000	68001	1	51	1.00	1.00	2014-05-10	0
986	1	109865132	WILMER JOSE CARRILLO	\N	\N	\N	\N	\N	0 	0 	1098651321  	WILMER JOSE CARRILLO PEDRAZA            	29	3	1988-04-19	2	1	1	68001	2	1	0	5	212132	8 	2014-02-20	1050	1300000	68001	0	51	0.00	1.00	2004-05-10	0
987	1	109590787	MONICA VESGA RUEDA  	\N	\N	\N	\N	\N	7 	7 	1095907871  	MONICA VESGA RUEDA                      	17	3	1986-05-04	1	1	1	68001	1	1	0	2	13212	8 	2014-02-25	1051	680000	68001	1	52	1.00	1.00	2014-05-10	0
988	1	63359190	SANDRA ROCIO CARDOZO	\N	\N	\N	\N	\N	0 	0 	63359190    	SANDRA ROCIO CARDOZO GUERRERO           	29	3	1970-07-03	1	1	1	68001	2	1	0	4	1312	2 	2014-02-21	1052	2500000	68001	1	52	0.00	1.00	2014-05-10	0
989	1	52979066	MILEIVY MORENO RODRI	\N	\N	\N	\N	\N	1 	1 	52979066    	MILEIVY MORENO RODRIGUEZ                	17	3	1984-04-15	1	1	1	68081	1	1	0	2	13123	8 	2014-02-16	1053	680000	68081	1	52	1.00	1.00	2014-05-10	0
990	1	72194525	EDUARDO GARCIA ARAND	\N	\N	\N	\N	\N	0 	0 	72194525    	EDUARDO GARCIA ARANDA VERGARA           	29	3	1973-07-13	2	1	1	68001	2	1	0	5	1132	8 	2013-06-13	1054	15400000	68001	0	51	0.00	1.00	2014-05-10	0
991	1	106791370	KEYDY LINET BELLO ZA	\N	\N	\N	\N	\N	4 	4 	1067913709  	KEYDY LINET BELLO ZABALA                	17	3	1992-06-29	1	M I 174	6108185	68081	1	5	0	2	252525	8 	2012-10-26	786	680000	23001	1	52	1.00	1.00	2013-10-25	0
992	1	109582501	LUIS FERNANDO PARRA 	\N	\N	\N	\N	\N	7 	7 	1095825015  	LUIS FERNANDO PARRA SUAREZ              	107	3	1995-07-21	2	1	1	68001	2	1	0	5	22136	8 	2013-12-13	1006	680000	68001	1	52	1.00	1.00	2014-05-10	0
993	1	109871780	JOHN JAIRO MOTTA DEL	\N	\N	\N	\N	\N	9 	9 	1098717809  	JOHN JAIRO MOTTA DELGADO                	15	3	1992-02-12	2	1	1	68001	2	1	0	5	1232	8 	2013-12-13	1007	680000	68001	1	52	1.00	1.00	2014-05-10	0
994	1	109869762	NELCY MORENO ESTEBAN	\N	\N	\N	\N	\N	7 	7 	1098697621  	NELCY MORENO ESTEBAN                    	17	3	1990-12-26	1	1	1	68001	2	1	0	5	21321	8 	2013-12-12	1008	680000	68001	1	52	1.00	1.00	2014-05-10	0
995	1	109621882	JAIR ALFONSO QUINTER	\N	\N	\N	\N	\N	4 	4 	1096218827  	JAIR ALFONSO QUINTERO ROMERO            	15	3	1990-05-27	2	CARRERA 52 No 28-09 EL CASTILLO	3204037764	68081	2	1	0	2	21321	8 	2013-04-07	877	680000	68081	1	52	1.00	1.00	2014-03-01	0
996	1	110237092	JERSON GOMEZ DUARTE 	\N	\N	\N	\N	\N	10	10	1102370923  	JERSON GOMEZ DUARTE                     	15	3	1993-04-22	2	MANZANA C CASA 9 CERROS DEL MEDITERRANEO	6552427	68001	1	1	0	2	21312	8 	2013-04-05	878	680000	68001	1	52	1.00	1.00	2014-03-01	0
997	1	109869227	LIZETH CRISTINA GONZ	\N	\N	\N	\N	\N	12	12	1098692271  	LIZETH CRISTINA GONZALEZ VELAZCO        	17	3	1990-08-19	1	MCDFNFGMR	6370099	68001	2	1	0	2	1321321	8 	2014-05-14	1090	680000	68001	0	52	1.00	1.00	2004-05-10	0
998	1	109865045	KARINA SILVA MADARIA	\N	\N	\N	\N	\N	3 	3 	1098650454  	KARINA SILVA MADARIAGA                  	17	3	1987-11-14	1	MXASK	6320505	68001	2	1	0	2	31213	5 	2014-05-14	1091	680000	68001	0	52	1.00	1.00	2014-05-10	0
999	1	109828659	ALEXANDER RODRIGUEZ 	\N	\N	\N	\N	\N	3 	3 	1098286594  	ALEXANDER RODRIGUEZ CAÑAS               	15	3	1995-01-03	2	CEFDSGDÑLKS	6320505	68001	2	1	0	2	62121	8 	2014-05-01	1092	680000	68001	0	52	1.00	1.00	2004-05-10	0
1000	1	5552477	ADOLFO DUARTE GUERRE	\N	\N	\N	\N	\N	2 	2 	5552477     	ADOLFO DUARTE GUERRERO                  	23	1	1941-04-24	2	KNBK,	6370099	68001	2	1	0	5	21313	8 	2014-05-20	1093	680000	68001	0	51	1.00	1.00	2004-05-10	0
1001	1	109873622	YULY XIOMARA MORENO 	\N	\N	\N	\N	\N	0 	0 	1098736229  	YULY XIOMARA MORENO FLOREZ              	29	1	1993-03-17	1	,M .,,-UUUIUU	6370099	68001	2	1	0	2	21321	8 	2014-05-19	1094	700000	68001	1	51	1.00	1.00	2004-05-10	0
1002	1	109591697	SANDRA MARCELA DURAN	\N	\N	\N	\N	\N	7 	7 	1095916972  	SANDRA MARCELA DURAN RUA                	17	3	1988-10-20	1	CARRERA 9 No 109-07	3188361062	68001	2	1	0	2	32355	10	2014-06-01	1099	680000	68001	0	52	1.00	1.00	2004-05-10	0
1003	1	109875019	SANDRA MILENA IBAÑEZ	\N	\N	\N	\N	\N	8 	8 	1098750197  	SANDRA MILENA IBAÑEZ MARTINEZ           	17	3	1992-09-17	1	RTLGY	68001	68001	2	1	0	2	13121	8 	2014-06-01	1100	680000	68001	1	52	1.00	1.00	2004-05-10	0
1004	1	106617323	MARTHA LILIANA SARMI	\N	\N	\N	\N	\N	2 	2 	1066173237  	MARTHA LILIANA SARMIENTO ALVAREZ        	17	3	1986-08-18	1	 C  V,.XMBVX	68001	68001	2	1	0	2	13121	8 	2014-06-06	1101	680000	68001	0	52	1.00	1.00	2004-05-10	0
1005	1	37617153	OMAIRA RAMIREZ PRADA	\N	\N	\N	\N	\N	10	10	37617153    	OMAIRA RAMIREZ PRADA                    	17	3	1982-01-16	1	V.V,XC	68001	68001	2	1	0	2	1212	8 	2014-06-07	1102	680000	68001	0	52	1.00	1.00	2004-05-10	0
1006	1	109868488	LIBER FRANK URIBE VA	\N	\N	\N	\N	\N	7 	7 	1098684888  	LIBER FRANK URIBE VARGAS                	15	3	1990-02-10	1	DVDVMDS	3155223519	68001	2	1	0	4	1312	8 	2014-06-01	1103	680000	68001	0	52	1.00	1.00	2004-05-10	0
1007	1	111677877	ALIX MIREYA ACOSTA R	\N	\N	\N	\N	\N	1 	1 	1116778777  	ALIX MIREYA ACOSTA RODRIGUEZ            	17	3	1987-06-04	1	MNNKN	6224515	68081	2	1	0	5	21323	8 	2014-07-04	1104	680000	68081	0	52	1.00	1.00	2004-05-10	0
1008	1	100018511	JONATHAN DAVID MONTE	\N	\N	\N	\N	\N	9 	9 	1000185113  	JONATHAN DAVID MONTERO CUDRIS           	15	3	1994-12-18	2	MNDKJ	622355	68001	2	1	0	2	1312	8 	2014-06-06	1105	680000	68001	1	52	1.00	1.00	2004-05-10	0
1009	1	110039290	LEIDY MARGARITA SALA	\N	\N	\N	\N	\N	4 	4 	1100392903  	LEIDY MARGARITA SALAS QUIROZ            	17	3	1986-08-31	1	DFSMF,SD	6203547	68001	1	1	0	1	11323	8 	2014-06-01	1106	680000	68081	0	52	1.00	1.00	2004-05-10	0
1010	1	106557812	ALVARO IVAN CAMARGO 	\N	\N	\N	\N	\N	7 	7 	1065578120  	ALVARO IVAN CAMARGO CARRILLO            	44	3	1987-01-01	2	BL.Ñ{Ñ]}	6370099	68001	1	1	0	5	2132	23	2014-06-16	1107	800000	68001	1	52	1.00	1.00	2004-05-10	0
1011	1	110237168	MARLEY VERA TOBON   	\N	\N	\N	\N	\N	10	10	1102371686  	MARLEY VERA TOBON                       	17	3	1993-07-16	1	SF,VDSF,	6370099	68001	2	1	0	2	213223	23	2014-07-06	1109	680000	68001	1	52	1.00	1.00	2014-05-10	0
1012	1	109622165	JOSE VICENTE VASQUEZ	\N	\N	\N	\N	\N	4 	4 	1096221650  	JOSE VICENTE VASQUEZ FIALLO             	15	3	1993-05-29	1	 MML,Ñ	6370099	68001	1	1	0	2	132	23	2014-06-26	1110	680000	68001	0	52	1.00	1.00	2004-05-10	0
1013	1	66839628	PATRICIA FERNANDEZ C	\N	\N	\N	\N	\N	0 	0 	66839628    	PATRICIA FERNANDEZ CRUZ                 	29	1	1972-07-23	1	CRA 37 112-52 ZAPAMANGA 2 ETAPA	6312587	68001	3	5	2	2	2122112	23	2014-07-04	1111	680000	68001	0	51	1.00	1.00	2014-05-10	0
1014	1	110237805	YURLEIDY CECILIA BEC	\N	\N	\N	\N	\N	10	10	1102378050  	YURLEIDY CECILIA BECERRA NOVA           	17	3	1995-07-20	1	CLL 24A 1-37 LOS CISNES	6541606	68001	1	5	0	2	236578	23	2014-07-04	1112	680000	68001	0	52	1.00	1.00	2014-05-10	0
1015	1	110271880	ALVARO JAVIER GUALDR	\N	\N	\N	\N	\N	4 	4 	1102718807  	ALVARO JAVIER GUALDRON DIAZ             	15	3	1990-01-11	1	CRA 15B 55D-37 PUEBLO NUEVO	3212484203	68001	1	5	0	2	236578	23	2014-07-08	1113	680000	68001	1	52	1.00	1.00	2014-05-10	0
1016	1	63307246	GLORIA STELLA VARGAS	\N	\N	\N	\N	\N	0 	0 	63307246    	GLORIA STELLA VARGAS                    	29	3	1963-09-21	1	XCMKMSFG	6370099	68001	1	1	0	5	2213	8 	2014-05-05	1083	680000	68001	1	51	1.00	1.00	2004-05-10	0
1017	1	110237142	DAVID LEONARDO PEDRA	\N	\N	\N	\N	\N	8 	8 	1102371425  	DAVID LEONARDO PEDRAZA BARRAGAN         	15	3	1993-07-02	2	MKFKSDMFÑS	556456	68001	2	1	0	1	13232	8 	2014-05-09	1084	680000	68001	1	52	1.00	1.00	2004-05-10	0
1018	1	109869179	YUDY MARCELA DIAZ DO	\N	\N	\N	\N	\N	0 	0 	1098691794  	YUDY MARCELA DIAZ DOMINGUEZ             	29	1	1990-08-12	1	CRA 22 A 109 40	6515794	68001	1	1	0	3	252525	8 	2013-01-11	830	1100000	68001	0	51	1.00	1.00	2014-01-10	0
1019	1	91186267	GUSTAVO ADOLFO GUTIE	\N	\N	\N	\N	\N	12	12	91186267    	GUSTAVO ADOLFO GUTIERREZ OVIEDO         	15	3	1985-01-05	2	1	6468818	68001	2	1	0	2	1321	40	2014-03-28	1068	680000	68001	0	52	1.00	1.00	2014-05-10	0
1020	1	109872835	CINDY PAOLA VILLAMIZ	\N	\N	\N	\N	\N	7 	7 	1098728351  	CINDY PAOLA VILLAMIZAR MEJIA            	17	3	1992-10-03	1	MCLK,CZ	314363226	68001	1	1	0	2	15151	8 	2014-05-23	1095	680000	68001	1	52	1.00	1.00	2014-05-10	0
1021	1	109876694	YURLEIS LILIANA PARD	\N	\N	\N	\N	\N	2 	2 	1098766947  	YURLEIS LILIANA PARDO AVELLANEDA        	17	3	1995-03-19	1	XKNASCSAMC	6381801	68001	2	1	0	5	2312	40	2014-05-23	1096	680000	68001	0	52	1.00	1.00	2004-05-10	0
1022	1	109878250	JENNY YUBELI CARRILL	\N	\N	\N	\N	\N	12	12	1098782507  	JENNY YUBELI CARRILLO PORTILLA          	39	3	1996-01-23	1	c,safsdgmdf	6370099	68001	2	1	0	2	3212313	8 	2015-01-02	1097	680000	68001	0	52	1.00	1.00	2004-05-10	0
1023	1	13724459	OMAR RODRIGO BECERRA	\N	\N	\N	\N	\N	2 	2 	13724459    	OMAR RODRIGO BECERRA DUEÑAS             	10	3	1979-08-29	2	1	1	68001	2	1	0	5	13213	8 	2014-04-13	1074	740000	68001	0	52	1.00	1.00	2016-05-10	0
1024	1	110236003	JENNY VALERO DURTE  	\N	\N	\N	\N	\N	10	10	1102360030  	JENNY VALERO DURTE                      	17	3	1989-05-19	1	CALLE 4A No 6-32 CENTRO	3175476176	68001	1	1	0	2	13223	8 	2013-09-24	941	680000	68001	1	52	1.00	1.00	2014-05-10	0
1025	1	109580586	DANIEL EDUARDO CALA 	\N	\N	\N	\N	\N	10	10	1095805863  	DANIEL EDUARDO CALA SOLER               	15	3	1990-07-03	1	CALLE 1D BIS MANZ H CASA 38	6550853	68001	1	1	0	2	43123	51	2013-09-18	942	680000	68001	1	52	1.00	1.00	2014-05-10	0
1026	1	63531798	CAROLINA GOMEZ CAMAC	\N	\N	\N	\N	\N	0 	0 	63531798    	CAROLINA GOMEZ CAMACHO                  	29	3	1982-08-12	1	CARRERA 3A No 16-29 SANTA ANA	6797908	68001	2	1	0	5	132	25	2013-09-16	943	1000000	68001	1	51	1.00	1.00	2014-05-10	0
1027	1	109620780	BRILLY MARLESBY BAUT	\N	\N	\N	\N	\N	1 	1 	1096207802  	BRILLY MARLESBY BAUTISTA TORRES         	17	3	1990-09-18	1	CALLE 47 LOTE 29 DORADO	3003736816	68001	2	1	0	2	4132	8 	2013-09-19	944	680000	68001	1	52	1.00	1.00	2014-05-10	0
1028	1	109622196	BRAYAN MANUEL SILVA 	\N	\N	\N	\N	\N	1 	1 	1096221967  	BRAYAN MANUEL SILVA SIMANCA             	10	3	1993-05-16	1	CARRERA 21 NO 38-20	3203239043	68081	1	1	0	2	131226	8 	2015-02-19	945	740000	68081	0	52	1.00	1.00	2014-05-10	0
1029	1	109620627	NAFFY YESENIA BASTOS	\N	\N	\N	\N	\N	1 	1 	1096206271  	NAFFY YESENIA BASTOS SUAREZ             	17	3	1990-04-19	1	CALLE 47 LOTE 48	6220811	68081	3	1	0	2	1323	8 	2013-09-19	946	680000	68081	1	52	1.00	1.00	2014-05-10	0
1030	1	109863031	YULIETH MONTOYA RODR	\N	\N	\N	\N	\N	10	10	1098630315  	YULIETH MONTOYA RODRIGUEZ               	20	3	1987-01-22	1	CARRERA 13W No 60BIS 71 APTO 201	6417886	68001	1	1	0	4	213213	8 	2013-09-23	947	1700000	68001	0	52	0.00	1.00	2014-05-10	0
1031	1	109623106	JENNY PAOLA HERNANDE	\N	\N	\N	\N	\N	1 	1 	1096231067  	JENNY PAOLA HERNANDEZ HURTADO           	17	3	1994-12-26	1	CASA 15 BOSQUES DE LA CIRA	6021386	68081	3	1	0	2	2132	8 	2013-09-19	948	680000	68081	1	52	1.00	1.00	2014-05-10	0
1032	1	91352253	YEISON ARMANDO VIOLA	\N	\N	\N	\N	\N	10	10	91352253    	YEISON ARMANDO VIOLA GAVIRIA            	15	3	1980-07-23	2	1	6314	68001	1	1	0	2	32323	8 	2014-07-03	1072	680000	68001	0	52	1.00	1.00	2004-05-10	0
1033	1	109875752	JUAN CAMILO TARAZONA	\N	\N	\N	\N	\N	7 	7 	1098757527  	JUAN CAMILO TARAZONA MONTESINO          	10	3	1994-06-18	1	1	1	68001	2	1	0	2	354254	8 	2014-04-01	1073	740000	68001	0	52	1.00	1.00	2004-05-10	0
1034	1	110237176	EDUARD DAVID DIAZ BE	\N	\N	\N	\N	\N	10	10	1102371769  	EDUARD DAVID DIAZ BENAVIDES             	15	3	1993-08-13	2	1	1	68001	2	1	0	5	1362	8 	2013-09-26	949	680000	68001	1	52	1.00	1.00	2014-05-10	0
1035	1	109870243	ESTEFANY JIVETH GUAR	\N	\N	\N	\N	\N	2 	2 	1098702438  	ESTEFANY JIVETH GUARNIZO ORTIZ          	17	3	1991-04-02	1	1	1	68001	2	1	0	2	132	8 	2014-07-12	1114	680000	68001	0	52	1.00	1.00	2004-05-10	0
1036	1	109695613	LINA KATHERINE PADIL	\N	\N	\N	\N	\N	9 	9 	1096956132  	LINA KATHERINE PADILLA NIÑO             	17	3	1995-06-23	1	1	1	68001	2	1	0	2	1230	23	2014-07-12	1115	680000	68001	1	52	1.00	1.00	2004-05-10	0
1037	1	109592149	LUIS ELIAS HERNANDEZ	\N	\N	\N	\N	\N	12	12	1095921497  	LUIS ELIAS HERNANDEZ FLOREZ             	15	3	1990-04-06	1	1	1	68001	2	1	0	5	23	23	2014-07-02	1116	680000	68001	0	52	1.00	1.00	2004-05-10	0
1038	1	110236208	SANDRA PAOLA JAIMES 	\N	\N	\N	\N	\N	0 	0 	1102362089  	SANDRA PAOLA JAIMES JAIMES              	29	1	1989-10-29	1	1	1	68001	2	1	0	3	1312	8 	2014-07-07	1117	1100000	68001	0	51	1.00	1.00	2004-05-10	0
1039	1	109863762	OSCAR MAURICIO PENAG	\N	\N	\N	\N	\N	7 	7 	1098637627  	OSCAR MAURICIO PENAGOS BOLIVAR          	10	3	1987-06-13	1	1	1	68001	1	1	0	2	1322	23	2014-07-10	1118	700000	68001	1	52	1.00	1.00	2004-05-10	0
1040	1	109865234	ZULEYMA ORTEGA BLANC	\N	\N	\N	\N	\N	9 	9 	1098652345  	ZULEYMA ORTEGA BLANCO                   	17	3	1987-04-02	1	1	1	68001	2	1	0	5	213	23	2014-07-08	1119	680000	68001	1	52	1.00	1.00	2004-05-10	0
1041	1	109874261	CLARISA ALEJANDRA GA	\N	\N	\N	\N	\N	8 	8 	1098742610  	CLARISA ALEJANDRA GAMBOA CAICEDO        	17	3	1991-12-01	1	1	1	68001	2	1	0	2	213	23	2014-07-06	1120	680000	68001	0	52	1.00	1.00	2004-05-10	0
1042	1	109580199	MARGARET ROXANA TORR	\N	\N	\N	\N	\N	2 	2 	1095801991  	MARGARET ROXANA TORRES TRUJILLO         	17	3	1988-02-17	2	CALLE 54 No 13-02 EL REPOSO	6492190	68001	2	1	0	5	13121	23	2014-07-29	1123	680000	68001	0	52	1.00	1.00	2004-05-10	0
1043	1	109592379	JERLY MILENA GOMEZ H	\N	\N	\N	\N	\N	0 	0 	1095923792  	JERLY MILENA GOMEZ HUERFANO             	29	1	1990-11-12	1	1	1	68001	2	1	0	5	2132	23	2014-07-28	1124	1100000	68001	0	51	1.00	1.00	2004-05-10	0
1044	1	109875957	EIMAR FERNANDO CEPED	\N	\N	\N	\N	\N	7 	7 	1098759570  	EIMAR FERNANDO CEPEDA HERNANDEZ         	15	3	1994-09-05	1	1	1	68001	1	1	0	2	33	23	2014-07-18	1125	680000	68001	0	52	1.00	1.00	2004-05-10	0
1045	1	109875643	DEYBI ALEXANDER MEDI	\N	\N	\N	\N	\N	9 	9 	1098756435  	DEYBI ALEXANDER MEDINA REATIGUI         	37	3	1994-06-14	1	CALLE 61 AN No 2W-13 APTO 401	1	68001	2	1	0	5	13	23	2014-07-26	1126	680000	68001	0	52	1.00	1.00	2004-05-10	0
1046	1	37617103	DEISY MIREYA OVALLE 	\N	\N	\N	\N	\N	10	10	37617103    	DEISY MIREYA OVALLE BLANCO              	17	3	1982-01-31	1	1	1	68001	2	1	2	5	12123221	23	2014-07-26	1127	680000	68001	0	52	1.00	1.00	2004-05-10	0
1047	1	961227037	JORGE DAVID DELGADO 	\N	\N	\N	\N	\N	0 	0 	96122703743 	JORGE DAVID DELGADO CRUZ                	29	3	1996-12-27	1	1	1	68001	2	1	0	5	21352	8 	2014-07-18	1128	1800000	68001	0	51	0.00	1.00	2004-05-10	0
1048	1	109873540	GELVER ALONSO ARENIS	\N	\N	\N	\N	\N	7 	7 	1098735403  	GELVER ALONSO ARENIS QUIROGA            	15	3	1993-03-20	2	1	23121	68001	1	1	0	2	123132	8 	2014-07-19	1129	680000	68001	0	52	1.00	1.00	2004-05-10	0
1049	1	110254893	KATHERINE LISSETH AP	\N	\N	\N	\N	\N	7 	7 	1102548938  	KATHERINE LISSETH APARICIO CARREÑO      	17	3	1990-06-22	1	1	1	68001	2	1	0	1	2123	23	2014-07-22	1130	680000	68001	1	52	1.00	1.00	2004-05-10	0
1050	1	109582257	LUISANGELA CARDENAS 	\N	\N	\N	\N	\N	9 	9 	1095822576  	LUISANGELA CARDENAS HERNANDEZ           	17	3	1994-12-24	1	1	1	68001	2	1	0	2	21321	23	2014-07-22	1134	680000	68001	1	52	1.00	1.00	2004-05-10	0
1051	1	109863328	SONIA LUCIA MURILLO 	\N	\N	\N	\N	\N	4 	4 	1098633280  	SONIA LUCIA MURILLO RUEDA               	17	3	1987-01-29	1	1	1	68001	2	1	0	2	1231	23	2014-07-28	1135	680000	68001	0	52	1.00	1.00	2004-05-10	0
1052	1	109867785	LADIS TATIANA MENESE	\N	\N	\N	\N	\N	12	12	1098677855  	LADIS TATIANA MENESES                   	17	3	1989-10-16	1	1	1	68001	2	1	2	2	321212	23	2014-07-23	1136	680000	68001	0	52	1.00	1.00	2004-05-10	0
1053	1	110236249	LUDWING YESID BARRER	\N	\N	\N	\N	\N	10	10	1102362494  	LUDWING YESID BARRERA RAMIREZ           	43	3	1990-01-04	2	1	1	68001	2	1	0	2	121322	23	2014-07-13	1121	680000	68001	0	52	1.00	1.00	2014-05-10	0
1054	1	109036817	FREDDY ALONSO DELGAD	\N	\N	\N	\N	\N	9 	9 	1090368177  	FREDDY ALONSO DELGADO OMAÑA             	15	3	1986-05-03	1	1	1	68001	2	1	0	5	2132	8 	2014-07-13	1122	680000	68001	1	52	1.00	1.00	2004-05-10	0
1055	1	109579380	FABIAN LANDINEZ GARC	\N	\N	\N	\N	\N	12	12	1095793808  	FABIAN LANDINEZ GARCIA                  	15	3	1987-05-22	1	1	1	68001	1	1	0	2	123	23	2014-07-29	1137	680000	68001	1	52	1.00	1.00	2004-05-10	0
1056	1	110089374	LISETH KATHERINE ROJ	\N	\N	\N	\N	\N	2 	2 	1100893742  	LISETH KATHERINE ROJAS GONZALEZ         	39	3	1993-02-05	1	1	1	68001	2	1	0	2	31	23	2014-07-29	1138	680000	68001	0	52	1.00	1.00	2004-05-10	0
1057	1	109695285	MAYRA ALEJANDRA FERN	\N	\N	\N	\N	\N	2 	2 	1096952857  	MAYRA ALEJANDRA FERNANDEZ LOPEZ         	17	3	1991-12-07	1	BLOQUE 9 TORRE 12-1 APTO 401	3212183429	68276	1	2	0	3	1234	23	2014-08-07	1139	680000	68001	1	52	1.00	1.00	2004-05-10	0
1058	1	109874189	LEIDY JOHANNA RAMIRE	\N	\N	\N	\N	\N	7 	7 	1098741898  	LEIDY JOHANNA RAMIREZ QUINTERO          	17	3	1993-05-25	1	CALLE 27N No 9A-39	6732989	68001	1	5	0	2	123456	23	2014-08-07	1140	680000	68001	0	52	1.00	1.00	2004-05-10	0
1059	1	109592699	LAURA MARCELA MARIÑO	\N	\N	\N	\N	\N	12	12	1095926994  	LAURA MARCELA MARIÑO AVILA              	17	3	1991-09-01	1	DIAGONAL 8B No 21-30	6594944	68307	3	1	1	2	456789	23	2014-08-04	1141	680000	68307	0	52	1.00	1.00	2004-05-10	0
1060	1	109869330	MARIA MERCEDES ACEVE	\N	\N	\N	\N	\N	0 	0 	1098693309  	MARIA MERCEDES ACEVEDO ARIZA            	29	1	1990-09-23	1	CRA 39 No 46-132	6575047	68001	1	2	0	4	57896	23	2014-08-01	1142	1800000	68001	0	51	0.00	1.00	2004-05-10	0
1061	1	109620299	ESPERANZA ZUÑIGA SIL	\N	\N	\N	\N	\N	4 	4 	1096202991  	ESPERANZA ZUÑIGA SILVA                  	17	3	1990-01-09	1	CARRERA 59 No 25-57	3173898774	68081	1	5	0	2	45678	23	2014-08-14	1143	680000	68081	1	52	1.00	1.00	2004-05-10	0
1062	1	39581604	ANGELICA PATRICIA SA	\N	\N	\N	\N	\N	8 	8 	39581604    	ANGELICA PATRICIA SANCHEZ SANJUAN       	17	3	1982-12-16	1	CALLE 103 No 51-45 ARRAYANES 1A ETAPA	6819587	68276	2	5	0	2	12458	23	2014-08-15	1144	680000	20228	1	52	1.00	1.00	2004-05-10	0
1063	1	109869903	YENNY CATALINA SALAZ	\N	\N	\N	\N	\N	4 	4 	1098699030  	YENNY CATALINA SALAZAR SOLANO           	17	3	1990-12-23	1	CARRERA 36F No 49-59 MIRAFLORES	3123258999	68081	3	5	0	2	789456	23	2014-08-16	1145	680000	68001	0	52	1.00	1.00	2004-05-10	0
1064	1	109865527	DIANA PAOLA LIZCANO 	\N	\N	\N	\N	\N	10	10	1098655276  	DIANA PAOLA LIZCANO PORTILLA            	17	3	1988-07-13	1	CALLE 1E No 4B-3 CAMPO VERDE	6652554	68547	2	5	2	2	78946	23	2014-09-07	1147	680000	68001	0	52	1.00	1.00	2004-05-10	0
1065	1	37707967	SANDRA MILENA MARTIN	\N	\N	\N	\N	\N	7 	7 	37707967    	SANDRA MILENA MARTINEZ SANTOS           	17	3	1983-02-05	1	CALLE 22 No 22-64 ALARCON	6918448	68001	1	5	2	2	328965	23	2014-09-06	1148	680000	68167	1	52	1.00	1.00	2004-05-10	0
1066	1	110237659	ANDERSON LEONARDO PR	\N	\N	\N	\N	\N	10	10	1102376597  	ANDERSON LEONARDO PRADA BARRERA         	15	3	1995-03-18	2	CARRERA 4 No 7N-34 DIVINO NIÑO	6891810	68547	1	5	0	2	45389	23	2014-09-02	1149	680000	68682	1	52	1.00	1.00	2004-05-10	0
1067	1	63558542	DIANA CAROLINA BENIT	\N	\N	\N	\N	\N	9 	9 	63558542    	DIANA CAROLINA BENITEZ MORA             	17	3	1984-11-08	1	CALLE 28A No 29-28	3188681087	68307	2	1	2	2	456892	23	2014-09-11	1150	680000	68001	0	52	1.00	1.00	2004-05-10	0
1068	1	24716630	DIANA YISET TRIANA C	\N	\N	\N	\N	\N	9 	9 	24716630    	DIANA YISET TRIANA CASTRO               	17	3	1982-09-14	1	CALLE 16 No 23-23	3212936826	68001	2	6	0	2	357896	23	2014-09-11	1151	680000	17380	1	52	1.00	1.00	2004-05-10	0
1069	1	91354492	OSCAR FERNANDO JAIME	\N	\N	\N	\N	\N	10	10	91354492    	OSCAR FERNANDO JAIMES BADILLO           	15	3	1983-01-02	2	OSCAR FERNANDO JAIMES BADILLO	3183480313	68547	1	2	0	2	345697	23	2014-09-12	1154	680000	68755	0	52	1.00	1.00	2004-05-10	0
1070	1	37580319	SANDRA LILIANA ACUÑA	\N	\N	\N	\N	\N	1 	1 	37580319    	SANDRA LILIANA ACUÑA QUIÑONEZ           	17	3	1984-09-11	1	TRANSVERSAL 42A No 56A-10	3214867004	68081	1	5	0	2	345698	23	2014-09-12	1155	680000	68081	0	52	1.00	1.00	2004-05-10	0
1071	1	91515672	LEONARDO FABIO SARMI	\N	\N	\N	\N	\N	3 	3 	91515672    	LEONARDO FABIO SARMIENTO BLANCO         	20	3	1983-01-19	1	CALLE 31 No 11W-53 SANTANDER	6523785	68001	2	1	0	1	5323	8 	2014-09-23	1156	1300000	68001	1	51	0.00	1.00	2004-05-10	0
1072	1	109623135	LINEY PARADA MEJIA  	\N	\N	\N	\N	\N	4 	4 	1096231350  	LINEY PARADA MEJIA                      	17	3	1994-12-23	1	LINEY PRADA MEJIA	6022250	68001	2	1	0	2	13123	8 	2014-09-24	1157	680000	68001	0	52	1.00	1.00	2004-05-10	0
1073	1	109593515	GINNA ALEXANDRA RENG	\N	\N	\N	\N	\N	9 	9 	1095935152  	GINNA ALEXANDRA RENGIFO RUEDA           	17	3	1994-01-20	1	1	3115150160	68001	2	1	0	5	11321	8 	2014-01-27	1023	680000	68001	1	52	1.00	1.00	2014-05-10	0
1074	1	109874261	GUILLERMO RINCON FOR	\N	\N	\N	\N	\N	7 	7 	1098742616  	GUILLERMO RINCON FORERO                 	15	3	1993-04-22	1	1	6575347	68001	2	1	0	5	12312	8 	2014-01-21	1024	680000	68001	1	52	1.00	1.00	2014-05-10	0
1075	1	63534274	DIANA CAROLINA BLANC	\N	\N	\N	\N	\N	12	12	63534274    	DIANA CAROLINA BLANCO MANCILLA          	17	3	2014-01-22	1	1	6461642	68001	2	1	0	5	212312	31	2014-07-03	1025	680000	68001	1	52	1.00	1.00	2014-05-10	0
1076	1	100545159	TATIANA LOZANO GUALD	\N	\N	\N	\N	\N	2 	2 	1005451599  	TATIANA LOZANO GUALDRON                 	17	3	1994-12-02	1	1	64167676	68001	2	1	0	5	1231321	8 	2014-01-25	1026	680000	68001	0	52	1.00	1.00	2014-05-10	0
1077	1	109875875	KAREN VIVIANA BETTIN	\N	\N	\N	\N	\N	4 	4 	1098758756  	KAREN VIVIANA BETTIN SERRANO            	17	3	1994-08-16	1	CARRERA 35D No 74-69	3165356418	68081	1	1	0	2	1312	8 	2014-09-24	1158	680000	68081	1	52	1.00	1.00	2004-05-10	0
1078	1	109621563	JEIMMY CAICEDO ACEVE	\N	\N	\N	\N	\N	1 	1 	1096215637  	JEIMMY CAICEDO ACEVEDO                  	17	3	1991-12-07	1	CALLE 19 No 77-16 CAMPO HERMOSO	3108021986	68001	1	4	0	2	23323	8 	2014-09-26	1159	680000	68001	1	52	1.00	1.00	2004-05-10	0
1079	1	63548494	DEASSY YISEDTH TARAZ	\N	\N	\N	\N	\N	9 	9 	63548494    	DEASSY YISEDTH TARAZONA SUAREZ          	42	3	1984-04-13	1	CRA 25 # 4 - 17 INDEPENDENCIA	3168452978	68001	2	5	0	2	234508	23	2014-10-01	1160	680000	68001	1	72	1.00	1.00	2004-05-10	0
1080	1	101008010	CRISTIAN DAVID ROLON	\N	\N	\N	\N	\N	9 	9 	1010080104  	CRISTIAN DAVID ROLON RODRIGUEZ          	15	3	1990-11-11	2	TORRE 3 INT 1 APTO 501 METROPOLIS	3106658343	68001	1	1	0	2	281520	23	2014-10-04	1161	680000	68001	0	52	1.00	1.00	2004-05-10	0
1081	1	109622831	SILVIA MARIA GOMEZ B	\N	\N	\N	\N	\N	0 	0 	1096228316  	SILVIA MARIA GOMEZ BECERRA              	29	1	1994-05-19	1	CLL 26 # 51 - 15	3008168358	68081	1	5	0	3	285023	23	2014-10-07	1162	900000	68081	0	51	1.00	1.00	2004-05-10	0
1082	1	28359769	MILENA JANETH VILLAB	\N	\N	\N	\N	\N	3 	3 	28359769    	MILENA JANETH VILLABONA RIOS            	17	3	1982-06-02	1	CLL 21 # 21 - 75 APTO 201 SAN FRANCISCO	3153474758	68001	1	1	0	2	152018	23	2014-10-01	1163	680000	5647 	0	52	1.00	1.00	2004-05-10	0
1083	1	37557488	ADRIANA MILENA DURAN	\N	\N	\N	\N	\N	0 	0 	37557488    	ADRIANA MILENA DURAN DURAN              	29	1	1978-04-27	1	CLL 55 # 1 - 94 TORRE 1 APTO 301	6414666	68001	2	1	0	4	1245017	23	2014-09-29	1164	1000000	68276	0	51	1.00	1.00	2004-05-10	0
1084	1	109582202	* LEIDY KATERIN DAZA	\N	\N	\N	\N	\N	2 	2 	1095822022  	* LEIDY KATERIN DAZA ARENAS             	17	3	1994-12-01	1	CRA 6 # 9 - 31 PRIMAVERA I	6485157	68001	2	5	0	2	1502581	23	2014-10-16	1166	680000	68276	0	52	1.00	1.00	2004-05-10	0
1085	1	109873544	MARTIN ARLEY DOMINGU	\N	\N	\N	\N	\N	7 	7 	1098735441  	MARTIN ARLEY DOMINGUEZ VARGAS           	15	3	1993-02-14	2	CRA 6 # 28 - 48 TORRE 4 APTO 702 GIRARDO	3004294012	68001	1	1	0	2	15028411	23	2014-10-17	1167	680000	68001	0	52	1.00	1.00	2004-05-10	0
1086	1	100533611	DIANA MARCELA LIZCAN	\N	\N	\N	\N	\N	9 	9 	1005336114  	DIANA MARCELA LIZCANO CASTELLANOS       	17	3	1995-03-27	1	CRA 2 MZ D CASA 3	3153896945	68001	1	5	0	2	210514561	23	2014-10-16	1168	680000	68001	0	52	1.00	1.00	2004-05-10	0
1087	1	109870736	MARLON FABRICIO PALM	\N	\N	\N	\N	\N	3 	3 	1098707364  	MARLON FABRICIO PALMA SERRANO           	15	3	1991-06-20	2	CRA 40 # 10 - 08 BARRIO EL DIVISO	3173202451	68001	1	5	0	2	254813681	23	2014-10-16	1169	680000	68001	0	52	1.00	1.00	2004-05-10	0
1088	1	109593690	JHONNATAN JAVIER AHU	\N	\N	\N	\N	\N	9 	9 	1095936908  	JHONNATAN JAVIER AHUMADA CARDENAS       	15	3	1994-06-19	2	CRA 19A No 19A-08 CASTILLA REAL 1	3155384520	68307	1	5	0	2	789435	23	2014-08-27	1146	680000	68307	0	52	1.00	1.00	2004-05-10	0
1089	1	109620752	YISBED DUARTE DURAN 	\N	\N	\N	\N	\N	1 	1 	1096207526  	YISBED DUARTE DURAN                     	17	3	1990-07-07	1	CALLE 48 No 9-19 CARDALES	3146131005	68081	1	1	0	2	6532	8 	2013-07-04	874	680000	68081	1	52	1.00	1.00	2014-03-01	0
1090	1	109877027	JOHAN SEBASTIAN RUED	\N	\N	\N	\N	\N	9 	9 	1098770276  	JOHAN SEBASTIAN RUEDA GALVIS            	15	3	1995-05-16	2	CLL 64 3 4W - 39 BARRIO LOS HEROES	3173141573	68001	1	5	0	2	1546181681	23	2014-10-16	1170	680000	68001	0	52	1.00	1.00	2004-05-10	0
1091	1	109876297	* GEIMY CATERINE PAR	\N	\N	\N	\N	\N	2 	2 	1098762972  	* GEIMY CATERINE PAREDES FLOREZ         	17	3	1994-11-29	1	CRA 7 # 6 - 44 BARRIO SANTANA	3186970830	68276	1	5	0	2	851916181	23	2014-10-16	1171	680000	68001	0	52	1.00	1.00	2004-05-10	0
1092	1	37841383	* RUTH ALEXANDRA DIA	\N	\N	\N	\N	\N	2 	2 	37841383    	* RUTH ALEXANDRA DIAZ ESPINOSA          	17	3	1980-10-30	1	CRA 29 # 22 - 15 BARRIO GALLINERAL	3158672942	68307	1	5	0	2	1281392	23	2014-10-16	1172	680000	68001	0	52	1.00	1.00	2004-05-10	0
1093	1	110235592	YEISON ANDRES VELASQ	\N	\N	\N	\N	\N	10	10	1102355922  	YEISON ANDRES VELASQUEZ                 	15	3	1988-05-04	2	CRA 19 # 7 - 44 BARRIO LA COLINA	6558360	68547	4	5	0	2	2561814	23	2014-10-16	1173	680000	68001	0	52	1.00	1.00	2004-05-10	0
1094	1	100743927	YUNEIDIS ALZATE DUAR	\N	\N	\N	\N	\N	1 	1 	1007439278  	YUNEIDIS ALZATE DUARTE                  	17	3	1995-07-22	1	CRA 45B # 59A - 55 APTO 201 BARRIO 9 ABR	3187863957	68081	1	5	0	2	129429716	23	2014-10-18	1174	680000	13670	0	52	1.00	1.00	2004-05-10	0
1095	1	109619877	MARIA ALEJANDRA PLAT	\N	\N	\N	\N	\N	1 	1 	1096198771  	MARIA ALEJANDRA PLATA MACIAS            	17	3	1988-01-19	1	CALL 40 # 48 - 20 MINAS DEL PARAISO	3162714104	68081	1	1	0	2	11982932941	23	2014-10-25	1175	680000	68081	0	52	1.00	1.00	2004-05-10	0
1096	1	109861015	OMAR JAVIER SARMIENT	\N	\N	\N	\N	\N	2 	2 	1098610150  	OMAR JAVIER SARMIENTO RINCON            	12	3	1985-09-10	2	CALLE 106 34-33	3178862825	68001	3	5	0	2	252525	8 	2013-09-04	805	2000000	68001	1	52	0.00	1.00	2013-11-25	0
1097	1	109874877	MARIA FERNANDA SUARE	\N	\N	\N	\N	\N	7 	7 	1098748771  	MARIA FERNANDA SUAREZ HERNANDEZ         	17	3	2014-12-29	1	CALLE 18N # 8-29 TEJAR 1	6406522	68001	1	2	0	2	1181294	23	2014-10-27	1176	680000	68001	0	52	1.00	1.00	2004-05-10	0
1098	1	91527748	MOISES ESPINOSA CARD	\N	\N	\N	\N	\N	7 	7 	91527748    	MOISES ESPINOSA CARDENAS                	15	3	1984-04-06	2	CALLE 8 No 29-84 PUERTO RICO	3173041236	68001	2	2	2	2	258964	23	2014-10-11	1165	680000	68255	1	52	1.00	1.00	2004-05-10	0
1099	1	109592125	LEIDY CAROLINA PEÑAT	\N	\N	\N	\N	\N	0 	0 	1095921258  	LEIDY CAROLINA PEÑATE SERRANO           	29	1	1990-03-24	1	CRA 19B # 10B - 31 VILLAS DE SAN JUAN	3143713621	68307	1	5	0	2	156813941	23	2014-10-27	1177	1100000	8001 	0	51	1.00	1.00	2004-05-10	0
1100	1	74184465	ROBINSON RUEDA VARGA	\N	\N	\N	\N	\N	0 	0 	74184465    	ROBINSON RUEDA VARGAS                   	29	1	1978-08-06	1	CLL 20 # 65 - 53 BUENAVISTA	3014005356	68001	1	5	0	2	16781671	23	2014-10-27	1178	1500000	68689	0	51	0.00	1.00	2004-05-10	0
1101	1	109580546	CRISTIAN CAMILO LOPE	\N	\N	\N	\N	\N	7 	7 	1095805466  	CRISTIAN CAMILO LOPEZ GIL               	15	3	1990-06-20	2	CALLE 27A # 4E - 14 LA CUMBRE	3165519910	68276	1	2	0	2	19428427	23	2014-10-28	1179	680000	68001	0	52	1.00	1.00	2004-05-10	0
1102	1	109878001	BRYGITH DANIELA ALVA	\N	\N	\N	\N	\N	9 	9 	1098780011  	BRYGITH DANIELA ALVAREZ JAIMES          	17	3	1996-01-23	1	CALLE 21N No 20 - 41 MZ 40 CASA 3 VILLA	3174451976	68001	1	1	0	2	184394681	23	2014-11-02	1180	680000	68001	0	52	1.00	1.00	2004-05-10	0
1103	1	109871571	MARYURI LIZETH MANTI	\N	\N	\N	\N	\N	9 	9 	1098715719  	MARYURI LIZETH MANTILLA VERGEL          	17	3	1991-07-30	1	AV LOS BUCAROS 3-05 SAMANES VI REAL DE M	6417401	68001	1	2	0	2	181456181	23	2014-11-05	1181	680000	68001	1	52	1.00	1.00	2004-05-10	0
1104	1	106240137	LEINY JOHANA CALDERO	\N	\N	\N	\N	\N	1 	1 	1062401374  	LEINY JOHANA CALDERON LEON              	17	3	1994-05-30	1	CARRERA 35 No 37A - 46 SANTA BARBARA	6105636	68081	1	1	0	2	1845942	23	2014-11-01	1182	680000	20750	1	52	1.00	1.00	2004-05-10	0
1105	1	110089411	ROSA MARIA MUÑOZ CAÑ	\N	\N	\N	\N	\N	7 	7 	1100894116  	ROSA MARIA MUÑOZ CAÑO                   	17	3	1993-10-05	1	CARRERA 26 No 17-33 SAN FRANCISCO	3176947678	68001	1	1	0	2	198194294	23	2014-11-01	1183	680000	68615	0	52	1.00	1.00	2004-05-10	0
1106	1	109591139	DIANA PATRICIA BECER	\N	\N	\N	\N	\N	9 	9 	1095911398  	DIANA PATRICIA BECERRA SUAREZ           	17	3	1987-09-02	1	CALLE 42 No 16-18 RINCON DE GIRON	3155413794	68307	1	5	0	2	18145684	23	2014-11-01	1184	680000	68307	0	52	1.00	1.00	2004-05-10	0
1107	1	63354097	ELISA PINZON ESTUPIÑ	\N	\N	\N	\N	\N	0 	0 	63354097    	ELISA PINZON ESTUPIÑAN                  	29	1	1969-12-09	1	CALLE 88 No 24-49 DIAMANTE II	6360450	68001	2	7	0	4	1984529841	23	2014-11-04	1185	3700000	54223	0	51	0.00	1.00	2004-05-10	0
1108	1	107638265	CARLOS ANDRES ABADIA	\N	\N	\N	\N	\N	1 	1 	1076382654  	CARLOS ANDRES ABADIA ARRIAGA            	15	3	1989-05-16	2	CARRERA 57 No 18 - 25 BUENA VISTA	3144023663	68081	1	2	0	2	19161914	23	2014-11-16	1187	680000	27787	0	52	1.00	1.00	2004-05-10	0
1109	1	37843738	KELTY YULEISSY TORRE	\N	\N	\N	\N	\N	4 	4 	37843738    	KELTY YULEISSY TORRES                   	17	3	1980-11-26	1	CARRERA 32 No 32 - 16 TRES UNIDOS	3175856418	68081	1	5	0	2	191964812	23	2014-11-16	1188	680000	68689	0	52	1.00	1.00	2004-05-10	0
1110	1	109861381	MANUEL ARMANDO SANDO	\N	\N	\N	\N	\N	2 	2 	1098613812  	MANUEL ARMANDO SANDOVAL MARTINEZ        	15	3	1986-05-09	2	CARRERA 7A No 8-15	6480969	68001	1	5	0	2	6458963	23	2014-09-12	1152	680000	68001	0	52	1.00	1.00	2004-05-10	0
1111	1	109876811	WILLIAM JAVIER FRANC	\N	\N	\N	\N	\N	10	10	1098768110  	WILLIAM JAVIER FRANCO LOPEZ             	15	3	1995-04-12	2	CARRERA 6A MZA T CASA 376	6563853	68547	3	1	1	2	325864	23	2014-09-12	1153	680000	68001	0	52	1.00	1.00	2004-05-10	0
1112	1	109865815	GUSTAVO ADOLFO TARAZ	\N	\N	\N	\N	\N	9 	9 	1098658155  	GUSTAVO ADOLFO TARAZONA PARRA           	11	3	1988-09-07	2	CALLE 27 CN No 11A-28 ALTOS DEL KENNEDY	3176934097	68001	2	1	0	5	413626	8 	2013-09-12	940	680000	68001	0	52	1.00	1.00	2014-05-10	0
1113	1	110237066	DIANA LIZETH DELGADO	\N	\N	\N	\N	\N	10	10	1102370665  	DIANA LIZETH DELGADO CIFUENTES          	17	3	1993-02-02	1	CALLE 21A No 1 - 19 LOS CISNES	3184934551	68547	1	1	0	2	298139411	23	2014-11-20	1189	680000	68547	0	52	1.00	1.00	2004-05-10	0
1114	1	91505913	JAIME ALEJANDRO SANC	\N	\N	\N	\N	\N	8 	8 	91505913    	JAIME ALEJANDRO SANCHEZ ALMEYDA         	15	3	1981-04-05	2	CALLE 2A No 11 - 49 VILLANUEVA	3175222633	68001	1	1	0	2	13139164	23	2014-11-16	1190	680000	68001	0	52	1.00	1.00	2004-05-10	0
1115	1	109582838	YULIETH STEFANNY PER	\N	\N	\N	\N	\N	4 	4 	1095828384  	YULIETH STEFANNY PEREZ RIVERA           	17	3	1996-04-04	1	CARRERA 53 NO 03-53	3123945325	68081	1	6	0	2	56879313	23	2014-12-01	1195	680000	68001	1	52	1.00	1.00	2004-05-10	0
1116	1	109620806	MARION ROMERO MENDOZ	\N	\N	\N	\N	\N	1 	1 	1096208064  	MARION ROMERO MENDOZA                   	17	3	1990-11-11	1	CARRERA 47 No 37-08	3165241884	68081	1	1	0	2	456781313	23	2014-12-01	1196	680000	68081	0	52	1.00	1.00	2004-05-10	0
1117	1	109579421	NESTOR DANIEL JAIMES	\N	\N	\N	\N	\N	2 	2 	1095794214  	NESTOR DANIEL JAIMES CALA               	15	3	1987-11-30	2	CALLE 9 No 4-58	3172784703	68001	1	1	0	2	3456892	23	2014-12-01	1197	680000	68001	0	52	1.00	1.00	2004-05-10	0
1118	1	110235205	DAMARIS PINTO PALACI	\N	\N	\N	\N	\N	10	10	1102352055  	DAMARIS PINTO PALACIOS                  	17	3	1987-03-02	1	CALLE 10 No 3-06	3118918119	68547	1	5	0	2	567894	23	2014-12-01	1198	680000	68547	0	52	1.00	1.00	2004-05-10	0
1119	1	109876239	YESICA KATERINE FERN	\N	\N	\N	\N	\N	9 	9 	1098762396  	YESICA KATERINE FERNANDEZ MUÑOZ         	17	3	1994-11-09	1	CALLE 104 E No 13-49	3184324499	68001	1	2	0	2	453558432	23	2014-12-01	1199	680000	68001	0	52	1.00	1.00	2004-05-10	0
1120	1	109582770	* KAREN BIBIANA MEDI	\N	\N	\N	\N	\N	8 	8 	1095827704  	* KAREN BIBIANA MEDINA MENDOZA          	17	3	1996-02-13	1	CARRERA 5 No 15-36 APTO 302	3172147079	68276	1	1	0	2	326487984	23	2014-12-01	1200	680000	68001	1	52	1.00	1.00	2004-05-10	0
1121	1	109862873	JUAN LUIS AYALA VANE	\N	\N	\N	\N	\N	2 	2 	1098628732  	JUAN LUIS AYALA VANEGAS                 	15	3	1987-01-08	2	CALLE 30A No 23-10	3173092112	68276	1	5	0	2	45369875	23	2014-12-02	1201	680000	68001	0	52	1.00	1.00	2004-05-10	0
1122	1	110236133	YILBER ALEXIS MORENO	\N	\N	\N	\N	\N	10	10	1102361338  	YILBER ALEXIS MORENO VALERO             	15	3	1989-09-19	2	CARRERA 9 No 6-26	3208076385	68547	1	1	0	2	453584453	23	2014-12-02	1202	680000	68547	0	52	1.00	1.00	2004-05-10	0
1123	1	109235823	ANDREA LISETH PALOMI	\N	\N	\N	\N	\N	8 	8 	1092358235  	ANDREA LISETH PALOMINO URIBE            	17	3	1995-03-17	1	ESTADERO REAL CAMPO ALEGRE,VEREDA	3162772439	68547	1	5	0	2	453967984	23	2014-12-03	1203	680000	68001	1	52	1.00	1.00	2004-05-10	0
1124	1	109620197	VIVIANA MARCELA LAND	\N	\N	\N	\N	\N	4 	4 	1096201972  	VIVIANA MARCELA LANDAZABAL JAIMES       	17	3	1989-01-13	1	CALLE 34 No 27 - 09 CINCUENTENARIO	3208944331	68081	1	1	0	2	194139429	23	2014-11-27	1194	680000	68081	0	52	1.00	1.00	2004-05-10	0
1125	1	111855748	NASLY CAROLINA GONZA	\N	\N	\N	\N	\N	7 	7 	1118557484  	NASLY CAROLINA GONZALEZ CUERVO          	17	3	1994-04-15	1	CARRERA 19 No 45-39	3108841500	68001	1	5	0	2	4561432156	23	2014-12-03	1204	680000	68001	0	52	1.00	1.00	2004-05-10	0
1126	1	63529645	* LEIDY BIBIANA WALT	\N	\N	\N	\N	\N	9 	9 	63529645    	* LEIDY BIBIANA WALTEROS ASCANIO        	17	3	1982-02-20	1	CALLE 14 No 12-39 PISO 2	3204718104	68307	1	1	0	2	456431321	23	2014-12-05	1205	680000	68001	0	52	1.00	1.00	2004-05-10	0
1127	1	109868227	* JANNNETH JOHANNA C	\N	\N	\N	\N	\N	10	10	1098682273  	* JANNNETH JOHANNA CRISTANCHO MORENO    	17	3	1989-10-27	1	CALLE 14A No 5-58	3165140535	68547	1	5	0	2	45434683	23	2014-12-07	1206	680000	68001	0	52	1.00	1.00	2004-05-10	0
1128	1	37551007	KAREN BIBIANA ZARATE	\N	\N	\N	\N	\N	8 	8 	37551007    	KAREN BIBIANA ZARATE PATIÑO             	17	3	1984-02-16	1	AVENIDA CANEYES,CASA 93	6590504	68307	1	5	0	2	41231564	23	2014-12-07	1207	680000	68895	0	52	1.00	1.00	2004-05-10	0
1129	1	109872373	ERIKA JAZMIN DIAZ ME	\N	\N	\N	\N	\N	7 	7 	1098723732  	ERIKA JAZMIN DIAZ MEJIA                 	17	3	1991-06-27	1	CARRERA 17B NO 1C-04	3174863961	68001	1	5	0	2	11961616	23	2014-12-11	1208	680000	68001	0	52	1.00	1.00	2004-05-10	0
1130	1	109869624	YURY ANDREA ARCINIEG	\N	\N	\N	\N	\N	3 	3 	1098696249  	YURY ANDREA ARCINIEGAS ACUÑA            	17	3	1990-08-03	1	CALLE 1B No 17H - 11 TRANSICION II	6404667	68001	1	7	0	2	1919186191	23	2014-12-16	1209	680000	68001	0	52	1.00	1.00	2004-05-10	0
1131	1	110120853	SEBASTIAN PEREZ ARDI	\N	\N	\N	\N	\N	7 	7 	1101208530  	SEBASTIAN PEREZ ARDILA                  	15	3	1996-02-17	2	CARRERA 24 No 8AN - 38 ESPERANZA I	3184645033	68001	1	6	0	2	191918156	23	2014-12-16	1210	680000	68406	0	52	1.00	1.00	2004-05-10	0
1132	1	109621676	FABIAN ANDRES JARAMI	\N	\N	\N	\N	\N	1 	1 	1096216761  	FABIAN ANDRES JARAMILLO GALE            	15	3	1992-07-23	2	CARRERA 31A No 29 - 75 CINCUENTENARIO	3143897541	68081	1	5	0	3	191619181	23	2014-12-15	1211	680000	68081	0	52	1.00	1.00	2004-05-10	0
1133	1	109868627	LUIS CARLOS RINCON V	\N	\N	\N	\N	\N	8 	8 	1098686279  	LUIS CARLOS RINCON VALERO               	15	3	1990-03-18	2	CARRERA 12 No 49 - 12 VILLALUZ	3016547110	68276	3	5	0	2	191391618	23	2014-12-23	1212	680000	68001	1	52	1.00	1.00	2004-05-10	0
1134	1	37577216	MARIA ERIKA SUAREZ A	\N	\N	\N	\N	\N	1 	1 	37577216    	MARIA ERIKA SUAREZ ACUÑA                	17	3	1983-09-24	1	CALLE 76B No 24a - 13 20 DE ENERO III ET	3004200055	68081	1	1	0	2	1919191	23	2015-01-10	1213	680000	68081	1	52	1.00	1.00	2004-05-10	0
1135	1	63529511	* CAROLINA RODRIGUEZ	\N	\N	\N	\N	\N	8 	8 	63529511    	* CAROLINA RODRIGUEZ GONZALEZ           	17	3	1982-05-13	1	CALLE 1B BIS No 18-40 SAN FCO DE LA CUES	3158750324	68547	1	2	0	2	19161912	23	2014-12-23	1214	680000	68001	0	52	1.00	1.00	2004-05-10	0
1136	1	109871211	YUDY BEATRIZ ORTIZ R	\N	\N	\N	\N	\N	8 	8 	1098712113  	YUDY BEATRIZ ORTIZ ROMERO               	17	3	1991-10-21	1	DIAGONAL 59 No 134-79 EL CARMEN	3187694273	68276	1	1	0	2	191369185	23	2015-01-10	1217	680000	68276	0	52	1.00	1.00	2004-05-10	0
1137	1	109875173	* LAURA LIZETH FONSE	\N	\N	\N	\N	\N	9 	9 	1098751732  	* LAURA LIZETH FONSECA ESPARZA          	17	3	1993-12-09	1	CALLE 13A No 15-12 VILLAMPIS	6598523	68307	1	5	0	2	19196181	23	2014-12-27	1216	680000	68001	0	52	1.00	1.00	2004-05-10	0
1138	1	63560005	NATALY JOHANA CAMARG	\N	\N	\N	\N	\N	8 	8 	63560005    	NATALY JOHANA CAMARGO BENAVIDES         	17	3	1985-03-22	1	CRA 8B No 109-19 LA ESPAÑA	3182218891	68001	1	1	0	2	191681671	23	2015-01-10	1218	680000	68001	0	52	1.00	1.00	2004-05-10	0
1139	1	100556315	LILIANA PLATA SILVA 	\N	\N	\N	\N	\N	2 	2 	1005563154  	LILIANA PLATA SILVA                     	17	3	1992-06-18	1	CALLE 8A No 4 - 21 CARACOLI	6480969	68276	1	3	0	2	191671681	23	2015-01-16	1222	680000	68689	0	52	1.00	1.00	2004-05-10	0
1140	1	109871530	KAREN ALEXANDRA BERN	\N	\N	\N	\N	\N	9 	9 	1098715309  	KAREN ALEXANDRA BERNAL CHANAGA          	17	3	1991-12-27	1	1	31639994428	68001	2	1	0	2	1313	8 	2014-01-29	1027	680000	68001	1	52	1.00	1.00	2014-05-10	0
1141	1	63528255	SINDY BIBIANA SARMIE	\N	\N	\N	\N	\N	8 	8 	63528255    	SINDY BIBIANA SARMIENTO CELIS           	20	3	1982-04-26	1	1	6918142	68001	2	1	0	5	1312	8 	2014-01-29	1028	1500000	68001	0	52	0.00	1.00	2014-05-10	0
1142	1	63513837	CLAUDIA YANETH PEREZ	\N	\N	\N	\N	\N	8 	8 	63513837    	CLAUDIA YANETH PEREZ JAIMES             	17	3	1976-07-03	1	1	6902483	68001	2	1	0	2	23221	8 	2014-01-18	1029	680000	68001	1	52	1.00	1.00	2014-05-10	0
1143	1	109876580	LORENA ANDREA ESTUPI	\N	\N	\N	\N	\N	9 	9 	1098765807  	LORENA ANDREA ESTUPIÑAN                 	39	3	1995-01-23	1	1	3182610666	68001	2	1	0	5	2323	8 	2014-01-23	1030	680000	68001	0	52	1.00	1.00	2014-05-10	0
1144	1	109424710	EDINSON ALBERTO OTER	\N	\N	\N	\N	\N	4 	4 	1094247105  	EDINSON ALBERTO OTERO AVILA             	15	3	1989-02-02	1	1	6105364	68081	2	1	0	5	12123	8 	2014-07-08	1031	680000	68081	1	52	1.00	1.00	2014-05-10	0
1145	1	109876529	NEYLYN ASHELEY CELIS	\N	\N	\N	\N	\N	9 	9 	1098765290  	NEYLYN ASHELEY CELIS ORTEGA             	17	3	1995-02-06	1	1	6731607	68001	2	1	0	5	123123	8 	2014-01-22	1032	680000	68001	0	52	1.00	1.00	2014-05-10	0
1146	1	109621256	HUGO ALBERTO CASTRO 	\N	\N	\N	\N	\N	1 	1 	1096212562  	HUGO ALBERTO CASTRO CADENA              	15	3	1991-07-23	1	1	1	68001	1	1	0	2	131	23	2014-07-16	1131	680000	68001	0	52	1.00	1.00	2004-05-10	0
1147	1	109865422	YENNY SOFIA URIBE VA	\N	\N	\N	\N	\N	3 	3 	1098654220  	YENNY SOFIA URIBE VARGAS                	17	3	1987-12-03	1	1	1	68001	2	1	0	5	12312	23	2014-07-23	1132	680000	68001	1	52	1.00	1.00	2004-05-10	0
1148	1	109622431	YORLEN MARITZA VILLA	\N	\N	\N	\N	\N	1 	1 	1096224314  	YORLEN MARITZA VILLA MATUTE             	17	3	1993-10-30	1	1	1	68001	2	1	0	2	21	23	2014-09-03	1133	680000	68001	1	52	1.00	1.00	2004-05-10	0
1149	1	109872496	JAVIER GONZALO RODRI	\N	\N	\N	\N	\N	8 	8 	1098724962  	JAVIER GONZALO RODRIGUEZ RODRIGUEZ      	15	3	1992-08-05	2	CALLE 2B No 10-17 PRADOS DE VILLANUEVA	6999856	68547	1	5	0	2	191391961	23	2015-01-06	1219	680000	68001	0	52	1.00	1.00	2004-05-10	0
1150	1	109593709	* WENDY DANAYA PICO 	\N	\N	\N	\N	\N	9 	9 	1095937096  	* WENDY DANAYA PICO AVELLANEDA          	17	3	1994-07-17	1	CALLE 19 No 18-04 GUYACANES	3106661230	68307	1	5	0	2	1916819	23	2015-01-03	1220	680000	68276	0	52	1.00	1.00	2004-05-10	0
1151	1	109878289	* JANETH SUSANA ARDI	\N	\N	\N	\N	\N	9 	9 	1098782898  	* JANETH SUSANA ARDILA GALVIS           	17	3	1996-04-14	1	CALLE 54 No 1W - 47 BALCON REAL	3152430076	68001	1	6	0	2	19191915	23	2015-01-03	1221	680000	68001	0	52	1.00	1.00	2004-05-10	0
1152	1	109874015	* ANGELA MILENA ROJA	\N	\N	\N	\N	\N	7 	7 	1098740154  	* ANGELA MILENA ROJAS FLOREZ            	17	3	1993-07-07	1	CALLE 8 No 40-33 EL DIVISO	6359719	68001	1	5	0	2	181381	23	2015-01-25	1223	680000	68001	0	52	1.00	1.00	2004-05-10	0
1153	1	109582161	* KAROL DAYANA GOMEZ	\N	\N	\N	\N	\N	9 	9 	1095821619  	* KAROL DAYANA GOMEZ REY                	17	3	1994-11-20	1	SECTOR 5 MANZANA F CASA 85 CRISTAL BAJO	6362441	68001	1	5	0	2	196196158	23	2015-02-20	1237	680000	68001	0	52	1.00	1.00	2004-05-10	0
1154	1	109870774	JENIFFER TATIANA ROM	\N	\N	\N	\N	\N	9 	9 	1098707742  	JENIFFER TATIANA ROMERO LEON            	39	3	1991-05-08	1	CARRERA 18A No 5-57 LA TRINIDAD	6186422	68276	3	5	0	2	19164152	23	2015-02-20	1238	680000	68001	0	52	1.00	1.00	2004-05-10	0
1155	1	37551245	LUZ DARY PRADA      	\N	\N	\N	\N	\N	8 	8 	37551245    	LUZ DARY PRADA                          	17	3	1984-05-15	1	CALLE 35 No 16A- 36 RINCON DE GIRON	31356699811	68307	3	4	0	2	19816181	23	2015-02-19	1239	680000	68307	0	52	1.00	1.00	2004-05-10	0
1156	1	109865899	YEIMI CATERINE CAMAC	\N	\N	\N	\N	\N	10	10	1098658994  	YEIMI CATERINE CAMACHO GIRMALDOS        	17	1	1988-08-01	1	CRA 16 No 14-65 CASA 787 MZ W MOLINO DEL	3174578505	68547	3	2	0	2	191911	23	2015-02-18	1240	680000	68001	0	52	1.00	1.00	2004-05-10	0
1157	1	109878528	* ESTEFANY CARDENAS 	\N	\N	\N	\N	\N	12	12	1098785286  	* ESTEFANY CARDENAS COTE                	17	3	1996-05-05	1	DIAGONAL 11 No 15-99 VILLAMPIS	3152714479	68307	1	5	0	2	181381	23	2015-02-17	1241	680000	68001	0	52	1.00	1.00	2004-05-10	0
1158	1	109864909	YENNY ANDREA CAPACHO	\N	\N	\N	\N	\N	7 	7 	1098649093  	YENNY ANDREA CAPACHO LONDOÑO            	17	3	1986-08-16	1	CARRERA 17 No 6-42 TORRE 1 APTO 405 VILL	6893446	68001	1	1	0	2	1813981	23	2015-02-16	1242	680000	68001	0	52	1.00	1.00	2004-05-10	0
1159	1	109871931	* JESSICA CAROLINA O	\N	\N	\N	\N	\N	7 	7 	1098719313  	* JESSICA CAROLINA ORTIZ PEÑALOZA       	17	3	1992-03-17	1	CARRERA 23 No 35-35 APTO 202 ANTONIA SAN	3124274288	68001	3	5	0	2	198181	23	2015-02-23	1243	680000	54223	0	52	1.00	1.00	2004-05-10	0
1160	1	37512990	MIREYA CALDERON RIOS	\N	\N	\N	\N	\N	0 	0 	37512990    	MIREYA CALDERON RIOS                    	29	1	1977-04-10	1	CALLE 60 No 8W CONJ RESID FUNDADRES III	3184872567	68001	3	5	0	3	191678194	23	2015-02-12	1224	2100000	68001	0	51	0.00	1.00	2004-05-10	0
1161	1	109868989	KAROL JULIETH SUAREZ	\N	\N	\N	\N	\N	0 	0 	1098689892  	KAROL JULIETH SUAREZ FLETCHER           	29	1	1990-07-05	1	CARRERA 18 CASA 77 CIUDAD BOLIVAR	3002170243	68001	1	7	0	4	19619198	23	2015-02-12	1225	1300000	68001	0	51	0.00	1.00	2004-05-10	0
1162	1	109623350	HEYDI JHOANA AYALA M	\N	\N	\N	\N	\N	1 	1 	1096233506  	HEYDI JHOANA AYALA MORENO               	17	3	1995-06-02	1	VEREDA EL PROGRESO - CENTRO ECOPETROL	3163137665	68081	1	1	0	2	1916781	23	2015-02-11	1226	680000	68081	0	52	1.00	1.00	2004-05-10	0
1163	1	109581538	RUBEN DARIO CASTAÑED	\N	\N	\N	\N	\N	12	12	1095815384  	RUBEN DARIO CASTAÑEDA MENDOZA           	15	3	1993-03-27	2	CALLE 58A NO 12-31 ALARES	3016807506	68276	1	6	0	2	1919618	23	2015-02-07	1227	680000	68001	0	52	1.00	1.00	2004-05-10	0
1164	1	109622921	MARIANA SEPULVEDA MA	\N	\N	\N	\N	\N	4 	4 	1096229211  	MARIANA SEPULVEDA MARIN                 	17	3	1994-08-15	1	DIAGONAL 63 No 49-85 BOSTON	3203868867	68081	1	1	0	2	1819174	23	2015-02-06	1228	680000	68081	0	52	1.00	1.00	2004-05-10	0
1165	1	109593130	* LUSNEIDA QUINTERO 	\N	\N	\N	\N	\N	12	12	1095931300  	* LUSNEIDA QUINTERO ROSO                	17	3	1993-01-07	1	CALLE 42 No 14-10 RINCON DE GIRON	6462416	68307	3	5	0	2	18165441	23	2015-02-04	1229	680000	68307	0	52	1.00	1.00	2004-05-10	0
1166	1	109623298	LINA PATRICIA BOHORQ	\N	\N	\N	\N	\N	1 	1 	1096232982  	LINA PATRICIA BOHORQUEZ MENDOZA         	17	3	1995-05-04	1	VEREDA PENJA	3123467674	68081	1	1	0	2	198181	23	2015-02-21	1244	680000	68081	0	52	1.00	1.00	2004-05-10	0
1167	1	109620903	LEYDIS CAROLINA ALCO	\N	\N	\N	\N	\N	1 	1 	1096209030  	LEYDIS CAROLINA ALCOCER NARVAEZ         	17	3	1990-12-15	1	CALLE 45 CARRERA 21 CASA 14 BUENOS AIRES	3105735381	68081	1	5	0	2	181381	23	2015-02-03	1230	680000	68575	0	52	1.00	1.00	2004-05-10	0
1168	1	63523951	* LUZ ADRIANA GONZAL	\N	\N	\N	\N	\N	12	12	63523951    	* LUZ ADRIANA GONZALEZ BARRERA          	17	3	1981-06-09	1	CARRERA 24 No 19-21 PORTAL CAMPESTRE	6590058	68307	1	7	0	2	181681	23	2015-02-03	1231	680000	68001	0	52	1.00	1.00	2004-05-10	0
1169	1	109580338	LUIS ALFREDO CARDENA	\N	\N	\N	\N	\N	8 	8 	1095803385  	LUIS ALFREDO CARDENAS MONTAGUT          	15	3	1989-12-06	2	MANZANA F CASA 9 CHACARITA II	3163209583	68547	1	5	0	2	198164	23	2015-02-03	1232	680000	68001	0	52	1.00	1.00	2004-05-10	0
1170	1	52865724	* MARYURY DEL CARMEN	\N	\N	\N	\N	\N	4 	4 	52865724    	* MARYURY DEL CARMEN SALDAÑA VIRGUEZ    	17	3	1981-10-12	1	CALLE 52 No 18-71 URIBE URIBE	3114927729	68081	2	5	0	2	5498164	23	2015-02-01	1233	680000	20011	0	52	1.00	1.00	2004-05-10	0
1171	1	109866344	* SILVIA MARCELA GON	\N	\N	\N	\N	\N	4 	4 	1098663449  	* SILVIA MARCELA GONZALEZ FORERO        	17	3	1988-12-21	2	CALLE 33A No 43-38 LA PLANADA DEL CERRO	3183567482	68081	3	5	0	2	2581681	23	2015-02-01	1234	680000	68276	0	52	1.00	1.00	2004-05-10	0
1172	1	109591623	DIANA PATRICIA LEON 	\N	\N	\N	\N	\N	3 	3 	1095916236  	DIANA PATRICIA LEON BARBA               	17	3	1988-09-09	1	CALLE 104G No 7-18 PISO 3 PORVENIR	3045978545	68001	1	5	0	2	181681	23	2015-02-01	1235	680000	68001	0	52	1.00	1.00	2004-05-10	0
1173	1	109622047	CARLOS MANUEL ACERO 	\N	\N	\N	\N	\N	4 	4 	1096220477  	CARLOS MANUEL ACERO ARCINIEGAS          	15	3	1992-12-25	2	CALLE 34A No 27-14 CINCUENTENARIO	3138104680	68081	1	1	0	2	18191	23	2015-02-01	1236	680000	68081	0	52	1.00	1.00	2004-05-10	0
1174	1	13513863	RICARDO RUEDA TOBO  	\N	\N	\N	\N	\N	0 	0 	13513863    	RICARDO RUEDA TOBO                      	29	1	1977-11-18	2	CALLE 21 No 2-61 PASEO REAL	6389559	68547	3	5	0	2	1491681	23	2015-02-25	1245	1300000	68001	0	51	0.00	1.00	2004-05-10	0
1175	1	109873000	NELSON DAVID MEZA MA	\N	\N	\N	\N	\N	12	12	1098730003  	NELSON DAVID MEZA MASQUEZ               	15	1	1992-11-15	2	CALLE 63 No 1-76 PARQUE REAL T 3 APT 233	3158354111	68001	1	1	0	2	1816181	23	2015-02-25	1246	680000	68001	0	52	1.00	1.00	2004-05-10	0
1176	1	60397919	* ANGELA MARIA VEGA 	\N	\N	\N	\N	\N	8 	8 	60397919    	* ANGELA MARIA VEGA CONTRERAS           	17	3	1979-08-14	1	CARRERA 0W No 6BN - 66 PARAISO II	6491402	68547	1	5	0	2	19619191	23	2014-12-19	1215	680000	54223	0	52	1.00	1.00	2004-05-10	0
1177	1	109621629	YOJAY YALITZA GOMEZ 	\N	\N	\N	\N	\N	1 	1 	1096216294  	YOJAY YALITZA GOMEZ RODRIGUEZ           	17	3	1990-05-23	1	MANZ 35 CASA 463 SAN SILVESTRE	3107513983	68081	2	1	0	5	231321	8 	2013-04-09	875	680000	68081	1	52	1.00	1.00	2014-03-01	0
1178	1	109580727	IVON TATIANA ROJAS V	\N	\N	\N	\N	\N	2 	2 	1095807277  	IVON TATIANA ROJAS VILLAMIZAR           	39	4	1990-10-07	1	CONJUNTO RESIDENCIAL SECTOR 19 BUCARICA	6487947	68001	1	1	0	2	13210	8 	2014-07-04	876	680000	68001	0	52	1.00	1.00	2014-04-01	0
1179	1	109878129	YENNY CAROLINA SOLAN	\N	\N	\N	\N	\N	9 	9 	1098781291  	YENNY CAROLINA SOLANO MARQUEZ           	17	3	1996-02-06	1	WDFEGRT	682545	68001	1	1	0	2	1121	23	2014-06-19	1108	680000	68001	0	52	1.00	1.00	2004-05-10	0
1180	1	101604312	MONICA HERREÑO LANDI	\N	\N	\N	\N	\N	10	10	1016043121  	MONICA HERREÑO LANDINEZ                 	43	3	1992-11-02	1	CRA 13 No 8-43 SAN RAFAEL-PTA	3202963423	68001	2	1	0	2	223	3 	2013-04-11	879	680000	68001	1	52	1.00	1.00	2014-03-01	0
1181	1	109594326	* KAREN DAYANA RUBIA	\N	\N	\N	\N	\N	9 	9 	1095943269  	* KAREN DAYANA RUBIANO RANGEL           	17	3	1996-02-18	1	CARRERA 18 No 1n - 46 SAN CARLOS	3123280811	68547	1	5	0	2	1913913	23	2014-11-26	1191	680000	68001	0	52	1.00	1.00	2004-05-10	0
1182	1	109582425	* SAIDA LILIANA ACER	\N	\N	\N	\N	\N	2 	2 	1095824256  	* SAIDA LILIANA ACERO VILLAMIZAR        	17	3	1995-05-12	1	CALLE 15 No 11 - 06 LOS ROSALES	6398215	68276	1	5	0	2	191684296	23	2014-11-26	1192	680000	68001	0	52	1.00	1.00	2004-05-10	0
1183	1	105677693	* MAIRA ALEJANDRA PI	\N	\N	\N	\N	\N	9 	9 	1056776933  	* MAIRA ALEJANDRA PINEDA SOLER          	17	3	1991-10-25	1	CARRERA 2da AW No 62 - 09 MUTIS	6835636	68001	1	6	0	2	19832926	23	2014-11-26	1193	680000	15572	0	52	1.00	1.00	2004-05-10	0
1184	1	63369216	LIBIA STELLA SARMIEN	\N	\N	\N	\N	\N	0 	0 	63369216    	LIBIA STELLA SARMIENTO VESGA            	29	1	1972-05-08	1	CALLE 106 No 23a - 44 PROVENZA	6364196	68001	1	1	0	4	1615813685	23	2014-11-14	1186	5500000	68679	0	51	0.00	1.00	2004-05-10	0
1185	1	109622791	LISETH ALEJANDRA GUT	\N	\N	\N	\N	\N	4 	4 	1096227917  	LISETH ALEJANDRA GUTIERREZ FRIAS        	17	3	1994-06-16	1	CRA 54 147 ALTOS DEL CAMPESTRE	3125734982	68575	1	5	0	2	252525	8 	2013-01-10	831	680000	68081	1	52	1.00	1.00	2014-01-09	0
1186	1	109870176	NYDIA JULIETH MORENO	\N	\N	\N	\N	\N	7 	7 	1098701764  	NYDIA JULIETH MORENO PARRA              	17	3	1990-08-26	1	CARRERA 28 CALLE 49 No 27-35	3158085507	68001	1	1	0	2	213	5 	2015-02-19	951	680000	68001	0	52	1.00	1.00	2014-05-10	0
1187	1	109580919	YASMIN GISELA RUIZ L	\N	\N	\N	\N	\N	8 	8 	1095809190  	YASMIN GISELA RUIZ LUCUARA              	17	3	1991-03-09	1	FINCA PALMIRA	6773355	68001	1	5	0	2	12321	8 	2013-10-10	952	680000	68001	1	52	1.00	1.00	2014-05-10	0
1188	1	106558717	RAFAEL JOSE REYES CH	\N	\N	\N	\N	\N	1 	1 	1065587174  	RAFAEL JOSE REYES CHINCHILLA            	15	3	1987-01-29	2	1	1	68081	2	1	0	2	13212	8 	2014-01-25	1033	680000	68081	1	52	1.00	1.00	2014-05-10	0
1189	1	109619159	ANDRES GIL ROJAS FER	\N	\N	\N	\N	\N	1 	1 	1096191596  	ANDRES GIL ROJAS FERNANDEZ              	15	3	1987-08-08	2	1	1	68001	3	1	0	4	213132	8 	2014-01-26	1034	680000	68001	0	52	1.00	1.00	2014-05-10	0
1190	1	13865465	CARLOS ALBERTO RUEDA	\N	\N	\N	\N	\N	2 	2 	13865465    	CARLOS ALBERTO RUEDA RUEDA              	15	3	1979-08-17	2	Ñ,FG,DFLGMD,	3168944178	68001	2	1	0	1	322313	8 	2014-05-27	1098	680000	68001	1	52	1.00	1.00	2004-05-10	0
1191	1	28138719	LORENA LISBEY CAMPOS	\N	\N	\N	\N	\N	7 	7 	28138719    	LORENA LISBEY CAMPOS HIGUERA            	40	3	1982-05-17	1	1	3213859934	68001	2	1	0	2	3212	8 	2014-01-27	1035	680000	68001	0	52	1.00	1.00	2014-05-10	0
1192	1	109867499	CRHISTIAN FABIAN CAL	\N	\N	\N	\N	\N	10	10	1098674994  	CRHISTIAN FABIAN CALDERON NAVARRO       	10	3	1989-08-29	1	1	1	68001	2	1	0	2	12121	8 	2014-01-29	1036	740000	68001	0	52	1.00	1.00	2014-05-10	0
1193	1	109580096	HASBLEIDY PAOLA LOZA	\N	\N	\N	\N	\N	2 	2 	1095800963  	HASBLEIDY PAOLA LOZADA JAIMES           	17	3	1989-06-04	1	1	6483790	68001	2	1	0	2	14545	8 	2014-07-04	1037	680000	68001	1	52	1.00	1.00	2014-05-10	0
1194	1	960110235	JENNY YUBELI CARRILL	\N	\N	\N	\N	\N	12	12	96011023590 	JENNY YUBELI CARRILLO PORTILLA          	39	3	2004-05-10	1	1	3178219820	68001	2	1	0	5	232	8 	2014-04-02	1038	680000	68001	1	52	1.00	1.00	2014-05-10	0
1195	1	28155761	ANGIE VANESSA REINA 	\N	\N	\N	\N	\N	9 	9 	28155761    	ANGIE VANESSA REINA CALDERON            	17	3	1982-06-25	1	1	1	68001	2	1	0	2	132323	8 	2014-01-21	1039	680000	68001	1	52	1.00	1.00	2014-05-10	0
\.


--
-- Data for Name: empleados_maes_copia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY empleados_maes_copia (id, tipodoc_id, numero_doc, nombre1, nombre2, apellido1, apellido2, contrato, estado) FROM stdin;
8	\N	898989	otro                	\N	perrito             	\N	\N	\N
48	\N	989898	okokohjhjhj         	\N	hjhjhjh             	\N	\N	\N
9	\N	98989	este                	\N	si                  	\N	\N	\N
11	\N	9898989	iuiui               	\N	ppopo               	\N	\N	\N
12	\N	45454	tyttyt              	\N	fgfgf               	\N	\N	\N
13	\N	7676767	ikiki               	\N	yhyhyh              	\N	\N	\N
14	\N	5656	tytyt               	\N	jhjh                	\N	\N	\N
15	\N	545	tyty                	\N	uiuiu               	\N	\N	\N
16	\N	5656	ikiki               	\N	lololololo          	\N	\N	\N
17	\N	989	jkjk                	\N	jkjk                	\N	\N	\N
18	\N	656	yuy                 	\N	yuyu                	\N	\N	\N
19	\N	677	yuyu                	\N	yu                  	\N	\N	\N
20	\N	6778	yuyuio              	\N	yuioioi             	\N	\N	\N
21	\N	454545	tyty                	\N	tytytytyty          	\N	\N	\N
22	\N	6767	hjyu                	\N	hjiuhj              	\N	\N	\N
23	\N	90000	uoooo               	\N	iooooo              	\N	\N	\N
24	\N	4545545	hyhy                	\N	hyhyhy              	\N	\N	\N
25	\N	\N	null                	\N	null                	\N	\N	\N
26	\N	\N	null                	\N	null                	\N	\N	\N
27	\N	\N	null                	\N	null                	\N	\N	\N
28	\N	323232	                    	\N	                    	\N	\N	\N
29	\N	\N	null                	\N	null                	\N	\N	\N
30	\N	232323	rtrtrtrtrt          	\N	fgfgfgfgfg          	\N	\N	\N
31	\N	\N	null                	\N	null                	\N	\N	\N
32	\N	2323	ewew                	\N	eweweee             	\N	\N	\N
33	\N	\N	null                	\N	null                	\N	\N	\N
34	\N	\N	null                	\N	null                	\N	\N	\N
35	\N	122222	wwwwww              	\N	rrrrrrrr            	\N	\N	\N
36	\N	233333	rwwewe              	\N	dfdfdf              	\N	\N	\N
37	\N	33333	rrrrrrr             	\N	ggggg               	\N	\N	\N
38	\N	5656	hghghgh             	\N	klklklk             	\N	\N	\N
39	\N	8899988	PASCUAL             	\N	TAL                 	\N	\N	\N
40	\N	989898989	Simon jose antonio  	\N	Bolivar Palacios    	\N	\N	\N
41	\N	90909090	General             	\N	Santander           	\N	\N	\N
42	\N	898989	Gabriel             	\N	Garcia              	\N	\N	\N
43	\N	78787878	Remedios            	\N	Buendia             	\N	\N	\N
49	\N	343434	dfdfdfd             	\N	fgfgfgfg            	\N	\N	\N
50	\N	33	dddd                	\N	wwww                	\N	\N	\N
51	\N	787878	klklk               	\N	jhjhjhj             	\N	\N	\N
7	1	1098678456	mi chinito          	alejandro           	silva               	suarez              	3	1
10	\N	989898888	tito_bambino        	\N	tito                	\N	\N	\N
52	\N	222222	aqswqss             	\N	sxsxsxsx            	\N	\N	\N
53	\N	111122	sasasa              	\N	qwqwqwq             	\N	\N	\N
44	\N	91224556	Echard              	\N	Tolle               	\N	\N	\N
45	\N	7878787	otro                	\N	tolle               	\N	\N	\N
5	1	91234567	Ramoncin            	mauricio            	silva               	maldonado           	12	1
54	\N	898989	lklklkl             	\N	i9i9i9i             	\N	\N	\N
46	\N	63323345	bar                 	\N	bara                	\N	\N	\N
55	\N	44444	ererer              	\N	erererer            	\N	\N	\N
56	\N	4545454	dfdfd               	\N	ghghghghg           	\N	\N	\N
6	1	1098234567	tito_principito     	principito          	silva               	suarez              	4	1
57	\N	4545454	kokoro              	\N	yoyo                	\N	\N	\N
58	\N	989009	kikiri              	\N	ki                  	\N	\N	\N
59	\N	8976	jijiji              	\N	jajaja              	\N	\N	\N
60	\N	987654	al                  	\N	revez               	\N	\N	\N
4	1	\N	null                	maria               	null                	rey                 	123	1
47	\N	91345232	tacatatatatatatat   	\N	tacataca            	\N	\N	\N
\.


--
-- Name: empleados_maes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('empleados_maes_id_seq', 60, true);


--
-- Name: empleados_maes_id_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('empleados_maes_id_seq1', 1195, true);


--
-- Data for Name: inventari_mv10; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY inventari_mv10 (id, id_parent, gondola, cara, consecutivo, ean, cantidad) FROM stdin;
1290	0	777	888	0	56565               	1.000
1291	0	777	888	0	656565              	1.000
1292	0	777	888	0	676767              	1.000
1293	0	33	44	0	44                  	1.000
1294	0	33	44	0	33                  	1.000
\.


--
-- Name: inventari_mv10_id_parent_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('inventari_mv10_id_parent_seq', 1, false);


--
-- Name: inventari_mv10_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('inventari_mv10_id_seq', 1294, true);


--
-- Data for Name: pending_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY pending_users (token, username, tstamp) FROM stdin;
\.


--
-- Data for Name: sesiones_de_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sesiones_de_usuarios (token, usuario, sello_de_tiempo) FROM stdin;
\.


--
-- Data for Name: tmp_inv_almacen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tmp_inv_almacen (id_referencia, descripcion_articulo, gondola, cara, rotulo, cantidad, fecha, ejecutor_conteo, usuario_proceso, fecha_proceso) FROM stdin;
44                            	\N	33	44	0	1	2015-03-30	mauricio                                	mauricio       	2015-03-30 03:40:40.69873
33                            	\N	33	44	0	1	2015-03-30	mauricio                                	mauricio       	2015-03-30 03:40:40.69873
\.


--
-- Data for Name: turnos_mv10; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY turnos_mv10 (id, turno) FROM stdin;
\.


--
-- Name: turnos_mv10_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('turnos_mv10_id_seq', 1, false);


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY usuarios (id, usuario, clave, bloqueado) FROM stdin;
1	mauricio            	toby                	f
2	zaira               	tito                	f
\.


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('usuarios_id_seq', 2, true);


--
-- Name: EMPLEADO_NIT_EMPLEADO_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "EMPLEADO"
    ADD CONSTRAINT "EMPLEADO_NIT_EMPLEADO_key" UNIQUE ("NIT_EMPLEADO");


--
-- Name: configurarinv_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY configurarinv
    ADD CONSTRAINT configurarinv_pkey PRIMARY KEY (id);


--
-- Name: empleados_maes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY empleados_maes_copia
    ADD CONSTRAINT empleados_maes_pkey PRIMARY KEY (id);


--
-- Name: empleados_maes_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY empleados_maes
    ADD CONSTRAINT empleados_maes_pkey1 PRIMARY KEY (id);


--
-- Name: inventari_mv10_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventari_mv10
    ADD CONSTRAINT inventari_mv10_pkey PRIMARY KEY (id);


--
-- Name: pending_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pending_users
    ADD CONSTRAINT pending_users_pkey PRIMARY KEY (token);


--
-- Name: sesiones_de_usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sesiones_de_usuarios
    ADD CONSTRAINT sesiones_de_usuarios_pkey PRIMARY KEY (token);


--
-- Name: usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--


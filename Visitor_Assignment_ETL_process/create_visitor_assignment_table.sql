CREATE TABLE public.visitor_info
(
  id integer NOT NULL DEFAULT nextval('visitor_info_id_seq'::regclass),
  message text,
  date_timestamp timestamp without time zone,
  CONSTRAINT visitor_info_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.visitor_info
  OWNER TO postgres;
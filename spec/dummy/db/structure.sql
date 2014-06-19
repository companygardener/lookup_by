--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: traffic; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA traffic;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    account_id integer NOT NULL,
    account text NOT NULL
);


--
-- Name: accounts_account_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_account_id_seq OWNED BY accounts.account_id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE addresses (
    address_id integer NOT NULL,
    city_id integer,
    state_id integer,
    postal_code_id integer,
    street_id integer,
    country_id integer
);


--
-- Name: addresses_address_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE addresses_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE addresses_address_id_seq OWNED BY addresses.address_id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cities (
    city_id integer NOT NULL,
    city text NOT NULL
);


--
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cities_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cities_city_id_seq OWNED BY cities.city_id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    country_id integer NOT NULL,
    country text NOT NULL
);


--
-- Name: countries_country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_country_id_seq OWNED BY countries.country_id;


--
-- Name: email_addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_addresses (
    email_address_id integer NOT NULL,
    email_address text NOT NULL
);


--
-- Name: email_addresses_email_address_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_addresses_email_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_addresses_email_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_addresses_email_address_id_seq OWNED BY email_addresses.email_address_id;


--
-- Name: ip_addresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ip_addresses (
    ip_address_id integer NOT NULL,
    ip_address inet NOT NULL
);


--
-- Name: ip_addresses_ip_address_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ip_addresses_ip_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_addresses_ip_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ip_addresses_ip_address_id_seq OWNED BY ip_addresses.ip_address_id;


--
-- Name: postal_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE postal_codes (
    postal_code_id integer NOT NULL,
    postal_code text NOT NULL
);


--
-- Name: postal_codes_postal_code_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE postal_codes_postal_code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: postal_codes_postal_code_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE postal_codes_postal_code_id_seq OWNED BY postal_codes.postal_code_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    state_id integer NOT NULL,
    state text NOT NULL
);


--
-- Name: states_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_state_id_seq OWNED BY states.state_id;


--
-- Name: statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE statuses (
    status_id smallint NOT NULL,
    status text NOT NULL
);


--
-- Name: statuses_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE statuses_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statuses_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE statuses_status_id_seq OWNED BY statuses.status_id;


--
-- Name: streets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE streets (
    street_id integer NOT NULL,
    street text NOT NULL
);


--
-- Name: streets_street_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE streets_street_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: streets_street_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE streets_street_id_seq OWNED BY streets.street_id;


--
-- Name: uncacheables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE uncacheables (
    uncacheable_id integer NOT NULL,
    uncacheable text NOT NULL
);


--
-- Name: uncacheables_uncacheable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE uncacheables_uncacheable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uncacheables_uncacheable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uncacheables_uncacheable_id_seq OWNED BY uncacheables.uncacheable_id;


--
-- Name: unfindables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE unfindables (
    unfindable_id integer NOT NULL,
    unfindable text NOT NULL
);


--
-- Name: unfindables_unfindable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unfindables_unfindable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unfindables_unfindable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unfindables_unfindable_id_seq OWNED BY unfindables.unfindable_id;


--
-- Name: user_agents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_agents (
    user_agent_id integer NOT NULL,
    user_agent text NOT NULL
);


--
-- Name: user_agents_user_agent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_agents_user_agent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_agents_user_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_agents_user_agent_id_seq OWNED BY user_agents.user_agent_id;


SET search_path = traffic, pg_catalog;

--
-- Name: paths; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE paths (
    path_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    path text NOT NULL
);


SET search_path = public, pg_catalog;

--
-- Name: account_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN account_id SET DEFAULT nextval('accounts_account_id_seq'::regclass);


--
-- Name: address_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses ALTER COLUMN address_id SET DEFAULT nextval('addresses_address_id_seq'::regclass);


--
-- Name: city_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cities ALTER COLUMN city_id SET DEFAULT nextval('cities_city_id_seq'::regclass);


--
-- Name: country_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN country_id SET DEFAULT nextval('countries_country_id_seq'::regclass);


--
-- Name: email_address_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_addresses ALTER COLUMN email_address_id SET DEFAULT nextval('email_addresses_email_address_id_seq'::regclass);


--
-- Name: ip_address_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ip_addresses ALTER COLUMN ip_address_id SET DEFAULT nextval('ip_addresses_ip_address_id_seq'::regclass);


--
-- Name: postal_code_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY postal_codes ALTER COLUMN postal_code_id SET DEFAULT nextval('postal_codes_postal_code_id_seq'::regclass);


--
-- Name: state_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN state_id SET DEFAULT nextval('states_state_id_seq'::regclass);


--
-- Name: status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY statuses ALTER COLUMN status_id SET DEFAULT nextval('statuses_status_id_seq'::regclass);


--
-- Name: street_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY streets ALTER COLUMN street_id SET DEFAULT nextval('streets_street_id_seq'::regclass);


--
-- Name: uncacheable_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY uncacheables ALTER COLUMN uncacheable_id SET DEFAULT nextval('uncacheables_uncacheable_id_seq'::regclass);


--
-- Name: unfindable_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unfindables ALTER COLUMN unfindable_id SET DEFAULT nextval('unfindables_unfindable_id_seq'::regclass);


--
-- Name: user_agent_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_agents ALTER COLUMN user_agent_id SET DEFAULT nextval('user_agents_user_agent_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (account_id);


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_addresses
    ADD CONSTRAINT email_addresses_pkey PRIMARY KEY (email_address_id);


--
-- Name: ip_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ip_addresses
    ADD CONSTRAINT ip_addresses_pkey PRIMARY KEY (ip_address_id);


--
-- Name: postal_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY postal_codes
    ADD CONSTRAINT postal_codes_pkey PRIMARY KEY (postal_code_id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (state_id);


--
-- Name: statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (status_id);


--
-- Name: streets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY streets
    ADD CONSTRAINT streets_pkey PRIMARY KEY (street_id);


--
-- Name: uncacheables_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY uncacheables
    ADD CONSTRAINT uncacheables_pkey PRIMARY KEY (uncacheable_id);


--
-- Name: unfindables_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY unfindables
    ADD CONSTRAINT unfindables_pkey PRIMARY KEY (unfindable_id);


--
-- Name: user_agents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agents_pkey PRIMARY KEY (user_agent_id);


SET search_path = traffic, pg_catalog;

--
-- Name: paths_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY paths
    ADD CONSTRAINT paths_pkey PRIMARY KEY (path_id);


SET search_path = public, pg_catalog;

--
-- Name: accounts__u_account; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX accounts__u_account ON accounts USING btree (account);


--
-- Name: cities__u_city; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cities__u_city ON cities USING btree (city);


--
-- Name: countries__u_country; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX countries__u_country ON countries USING btree (country);


--
-- Name: email_addresses__u_email_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX email_addresses__u_email_address ON email_addresses USING btree (email_address);


--
-- Name: ip_addresses__u_ip_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX ip_addresses__u_ip_address ON ip_addresses USING btree (ip_address);


--
-- Name: postal_codes__u_postal_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX postal_codes__u_postal_code ON postal_codes USING btree (postal_code);


--
-- Name: states__u_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX states__u_state ON states USING btree (state);


--
-- Name: statuses__u_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX statuses__u_status ON statuses USING btree (status);


--
-- Name: streets__u_street; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX streets__u_street ON streets USING btree (street);


--
-- Name: uncacheables__u_uncacheable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX uncacheables__u_uncacheable ON uncacheables USING btree (uncacheable);


--
-- Name: unfindables__u_unfindable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unfindables__u_unfindable ON unfindables USING btree (unfindable);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: user_agents__u_user_agent; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX user_agents__u_user_agent ON user_agents USING btree (user_agent);


SET search_path = traffic, pg_catalog;

--
-- Name: paths__u_path; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX paths__u_path ON paths USING btree (path);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20121019040009');


--
-- PostgreSQL database dump
--

\restrict ZnlXPOdS1Vx4NOHeikZTI8ehcWLPe9I8cgm27Br8jAHpBSCZdwCd2nR0tYy9Ocz

-- Dumped from database version 18.1 (Debian 18.1-1.pgdg13+2)
-- Dumped by pg_dump version 18.1 (Debian 18.1-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hll; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hll WITH SCHEMA public;


--
-- Name: EXTENSION hll; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hll IS 'type for storing hyperloglog data';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: gha_actors; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_actors (
    id bigint NOT NULL,
    login character varying(120) NOT NULL,
    name character varying(120),
    country_id character varying(2),
    sex character varying(1),
    sex_prob double precision,
    tz character varying(40),
    tz_offset integer,
    country_name text,
    age integer
);


ALTER TABLE public.gha_actors OWNER TO gha_admin;

--
-- Name: gha_actors_affiliations; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_actors_affiliations (
    actor_id bigint NOT NULL,
    company_name character varying(160) NOT NULL,
    original_company_name character varying(160) NOT NULL,
    dt_from timestamp without time zone NOT NULL,
    dt_to timestamp without time zone NOT NULL,
    source character varying(30) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.gha_actors_affiliations OWNER TO gha_admin;

--
-- Name: gha_actors_emails; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_actors_emails (
    actor_id bigint NOT NULL,
    email character varying(120) NOT NULL,
    origin smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.gha_actors_emails OWNER TO gha_admin;

--
-- Name: gha_actors_names; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_actors_names (
    actor_id bigint NOT NULL,
    name character varying(120) NOT NULL,
    origin smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.gha_actors_names OWNER TO gha_admin;

--
-- Name: gha_assets; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_assets (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    name character varying(200) NOT NULL,
    label character varying(120),
    uploader_id bigint NOT NULL,
    content_type character varying(80) NOT NULL,
    state character varying(20) NOT NULL,
    size integer NOT NULL,
    download_count integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dup_uploader_login character varying(120) NOT NULL
);


ALTER TABLE public.gha_assets OWNER TO gha_admin;

--
-- Name: gha_bot_logins; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_bot_logins (
    pattern text NOT NULL
);


ALTER TABLE public.gha_bot_logins OWNER TO gha_admin;

--
-- Name: gha_branches; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_branches (
    sha character varying(40) NOT NULL,
    event_id bigint NOT NULL,
    user_id bigint,
    repo_id bigint,
    label character varying(200) NOT NULL,
    ref character varying(200) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dupn_forkee_name character varying(160),
    dupn_user_login character varying(120)
);


ALTER TABLE public.gha_branches OWNER TO gha_admin;

--
-- Name: gha_comments; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_comments (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    commit_id character varying(40),
    original_commit_id character varying(40),
    diff_hunk text,
    "position" integer,
    original_position integer,
    path text,
    pull_request_review_id bigint,
    line integer,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dup_user_login character varying(120) NOT NULL
);


ALTER TABLE public.gha_comments OWNER TO gha_admin;

--
-- Name: gha_commits; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_commits (
    sha character varying(40) NOT NULL,
    event_id bigint NOT NULL,
    author_name character varying(160) NOT NULL,
    message text NOT NULL,
    is_distinct boolean NOT NULL,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    encrypted_email character varying(160) NOT NULL,
    author_email character varying(160) DEFAULT ''::character varying NOT NULL,
    committer_name character varying(160) DEFAULT ''::character varying NOT NULL,
    committer_email character varying(160) DEFAULT ''::character varying NOT NULL,
    author_id bigint,
    committer_id bigint,
    dup_author_login character varying(120) DEFAULT ''::character varying NOT NULL,
    dup_committer_login character varying(120) DEFAULT ''::character varying NOT NULL,
    loc_added integer,
    loc_removed integer,
    files_changed integer
);


ALTER TABLE public.gha_commits OWNER TO gha_admin;

--
-- Name: gha_commits_files; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_commits_files (
    sha character varying(40) NOT NULL,
    path text NOT NULL,
    size bigint NOT NULL,
    dt timestamp without time zone NOT NULL,
    ext text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.gha_commits_files OWNER TO gha_admin;

--
-- Name: gha_commits_roles; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_commits_roles (
    sha character varying(40) NOT NULL,
    event_id bigint NOT NULL,
    role character varying(120) NOT NULL,
    actor_id bigint,
    actor_login character varying(120) DEFAULT ''::character varying NOT NULL,
    actor_name character varying(160) DEFAULT ''::character varying NOT NULL,
    actor_email character varying(160) DEFAULT ''::character varying NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.gha_commits_roles OWNER TO gha_admin;

--
-- Name: gha_companies; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_companies (
    name character varying(160) NOT NULL
);


ALTER TABLE public.gha_companies OWNER TO gha_admin;

--
-- Name: gha_computed; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_computed (
    metric text NOT NULL,
    dt timestamp without time zone NOT NULL
);


ALTER TABLE public.gha_computed OWNER TO gha_admin;

--
-- Name: gha_countries; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_countries (
    code character varying(2) NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.gha_countries OWNER TO gha_admin;

--
-- Name: gha_events; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_events (
    id bigint NOT NULL,
    type character varying(40) NOT NULL,
    actor_id bigint NOT NULL,
    repo_id bigint NOT NULL,
    public boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    org_id bigint,
    forkee_id bigint,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_name character varying(160) NOT NULL
);


ALTER TABLE public.gha_events OWNER TO gha_admin;

--
-- Name: gha_events_commits_files; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_events_commits_files (
    sha character varying(40) NOT NULL,
    event_id bigint NOT NULL,
    path text NOT NULL,
    size bigint NOT NULL,
    dt timestamp without time zone NOT NULL,
    repo_group character varying(80),
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    ext text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.gha_events_commits_files OWNER TO gha_admin;

--
-- Name: gha_forkees; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_forkees (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    name character varying(80) NOT NULL,
    full_name character varying(200) NOT NULL,
    owner_id bigint NOT NULL,
    description text,
    fork boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pushed_at timestamp without time zone,
    homepage text,
    size integer NOT NULL,
    stargazers_count integer NOT NULL,
    has_issues boolean NOT NULL,
    has_projects boolean,
    has_downloads boolean NOT NULL,
    has_wiki boolean NOT NULL,
    has_pages boolean,
    forks integer NOT NULL,
    open_issues integer NOT NULL,
    watchers integer NOT NULL,
    default_branch character varying(200) NOT NULL,
    public boolean,
    language character varying(80),
    organization character varying(100),
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dup_owner_login character varying(120) NOT NULL
);


ALTER TABLE public.gha_forkees OWNER TO gha_admin;

--
-- Name: gha_imported_shas; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_imported_shas (
    sha text NOT NULL,
    dt timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.gha_imported_shas OWNER TO gha_admin;

--
-- Name: gha_issues; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_issues (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    assignee_id bigint,
    body text,
    closed_at timestamp without time zone,
    comments integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    locked boolean NOT NULL,
    milestone_id bigint,
    number integer NOT NULL,
    state character varying(20) NOT NULL,
    title text NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL,
    is_pull_request boolean NOT NULL,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dupn_assignee_login character varying(120),
    dup_user_login character varying(120) NOT NULL
);


ALTER TABLE public.gha_issues OWNER TO gha_admin;

--
-- Name: gha_issues_assignees; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_issues_assignees (
    issue_id bigint NOT NULL,
    event_id bigint NOT NULL,
    assignee_id bigint NOT NULL
);


ALTER TABLE public.gha_issues_assignees OWNER TO gha_admin;

--
-- Name: gha_issues_events_labels; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_issues_events_labels (
    issue_id bigint NOT NULL,
    event_id bigint NOT NULL,
    label_id bigint NOT NULL,
    label_name character varying(160) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    actor_id bigint NOT NULL,
    actor_login character varying(120) NOT NULL,
    repo_id bigint NOT NULL,
    repo_name character varying(160) NOT NULL,
    type character varying(40) NOT NULL,
    issue_number integer NOT NULL
);


ALTER TABLE public.gha_issues_events_labels OWNER TO gha_admin;

--
-- Name: gha_issues_labels; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_issues_labels (
    issue_id bigint NOT NULL,
    event_id bigint NOT NULL,
    label_id bigint NOT NULL,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dup_issue_number integer NOT NULL,
    dup_label_name character varying(160) NOT NULL
);


ALTER TABLE public.gha_issues_labels OWNER TO gha_admin;

--
-- Name: gha_issues_pull_requests; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_issues_pull_requests (
    issue_id bigint NOT NULL,
    pull_request_id bigint NOT NULL,
    number integer NOT NULL,
    repo_id bigint NOT NULL,
    repo_name character varying(160) NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.gha_issues_pull_requests OWNER TO gha_admin;

--
-- Name: gha_labels; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_labels (
    id bigint NOT NULL,
    name character varying(160) NOT NULL,
    color character varying(8) NOT NULL,
    is_default boolean
);


ALTER TABLE public.gha_labels OWNER TO gha_admin;

--
-- Name: gha_last_computed; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_last_computed (
    metric text NOT NULL,
    dt timestamp without time zone NOT NULL,
    start_dt timestamp without time zone,
    took bigint,
    took_as_str text,
    command text
);


ALTER TABLE public.gha_last_computed OWNER TO gha_admin;

--
-- Name: gha_logs; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_logs (
    id bigint NOT NULL,
    dt timestamp without time zone DEFAULT now(),
    prog character varying(32) NOT NULL,
    proj character varying(32) NOT NULL,
    run_dt timestamp without time zone NOT NULL,
    msg text
);


ALTER TABLE public.gha_logs OWNER TO gha_admin;

--
-- Name: gha_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: gha_admin
--

CREATE SEQUENCE public.gha_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gha_logs_id_seq OWNER TO gha_admin;

--
-- Name: gha_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gha_admin
--

ALTER SEQUENCE public.gha_logs_id_seq OWNED BY public.gha_logs.id;


--
-- Name: gha_milestones; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_milestones (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    closed_at timestamp without time zone,
    closed_issues integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    creator_id bigint,
    description text,
    due_on timestamp without time zone,
    number integer NOT NULL,
    open_issues integer NOT NULL,
    state character varying(20) NOT NULL,
    title character varying(200) NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dupn_creator_login character varying(120)
);


ALTER TABLE public.gha_milestones OWNER TO gha_admin;

--
-- Name: gha_orgs; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_orgs (
    id bigint NOT NULL,
    login character varying(100) NOT NULL
);


ALTER TABLE public.gha_orgs OWNER TO gha_admin;

--
-- Name: gha_pages; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_pages (
    sha character varying(40) NOT NULL,
    event_id bigint NOT NULL,
    action character varying(40) NOT NULL,
    title character varying(300) NOT NULL,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.gha_pages OWNER TO gha_admin;

--
-- Name: gha_parsed; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_parsed (
    dt timestamp without time zone NOT NULL
);


ALTER TABLE public.gha_parsed OWNER TO gha_admin;

--
-- Name: gha_payloads; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_payloads (
    event_id bigint NOT NULL,
    push_id bigint,
    size integer,
    ref character varying(200),
    head character varying(40),
    befor character varying(40),
    action character varying(40),
    issue_id bigint,
    pull_request_id bigint,
    comment_id bigint,
    ref_type character varying(20),
    master_branch character varying(200),
    description text,
    number integer,
    forkee_id bigint,
    release_id bigint,
    member_id bigint,
    commit character varying(40),
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.gha_payloads OWNER TO gha_admin;

--
-- Name: gha_postprocess_scripts; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_postprocess_scripts (
    ord integer NOT NULL,
    path text NOT NULL
);


ALTER TABLE public.gha_postprocess_scripts OWNER TO gha_admin;

--
-- Name: gha_pull_requests; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_pull_requests (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    user_id bigint NOT NULL,
    base_sha character varying(40) NOT NULL,
    head_sha character varying(40) NOT NULL,
    merged_by_id bigint,
    assignee_id bigint,
    milestone_id bigint,
    number integer NOT NULL,
    state character varying(20) NOT NULL,
    locked boolean,
    title text NOT NULL,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    closed_at timestamp without time zone,
    merged_at timestamp without time zone,
    merge_commit_sha character varying(40),
    merged boolean,
    mergeable boolean,
    rebaseable boolean,
    mergeable_state character varying(20),
    comments integer,
    review_comments integer,
    maintainer_can_modify boolean,
    commits integer,
    additions integer,
    deletions integer,
    changed_files integer,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dup_user_login character varying(120) NOT NULL,
    dupn_assignee_login character varying(120),
    dupn_merged_by_login character varying(120)
);


ALTER TABLE public.gha_pull_requests OWNER TO gha_admin;

--
-- Name: gha_pull_requests_assignees; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_pull_requests_assignees (
    pull_request_id bigint NOT NULL,
    event_id bigint NOT NULL,
    assignee_id bigint NOT NULL
);


ALTER TABLE public.gha_pull_requests_assignees OWNER TO gha_admin;

--
-- Name: gha_pull_requests_requested_reviewers; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_pull_requests_requested_reviewers (
    pull_request_id bigint NOT NULL,
    event_id bigint NOT NULL,
    requested_reviewer_id bigint CONSTRAINT gha_pull_requests_requested_revi_requested_reviewer_id_not_null NOT NULL
);


ALTER TABLE public.gha_pull_requests_requested_reviewers OWNER TO gha_admin;

--
-- Name: gha_releases; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_releases (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    tag_name character varying(200) NOT NULL,
    target_commitish character varying(200) NOT NULL,
    name character varying(200),
    draft boolean NOT NULL,
    author_id bigint NOT NULL,
    prerelease boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    published_at timestamp without time zone,
    body text,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dup_author_login character varying(120) NOT NULL
);


ALTER TABLE public.gha_releases OWNER TO gha_admin;

--
-- Name: gha_releases_assets; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_releases_assets (
    release_id bigint NOT NULL,
    event_id bigint NOT NULL,
    asset_id bigint NOT NULL
);


ALTER TABLE public.gha_releases_assets OWNER TO gha_admin;

--
-- Name: gha_repo_groups; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_repo_groups (
    id bigint NOT NULL,
    name character varying(160) NOT NULL,
    repo_group character varying(80) NOT NULL,
    org_id bigint,
    org_login character varying(100),
    alias character varying(160)
);


ALTER TABLE public.gha_repo_groups OWNER TO gha_admin;

--
-- Name: gha_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_repos (
    id bigint NOT NULL,
    name character varying(160) NOT NULL,
    org_id bigint,
    org_login character varying(100),
    repo_group character varying(80),
    alias character varying(160),
    license_key character varying(30),
    license_name character varying(160),
    license_prob double precision,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.gha_repos OWNER TO gha_admin;

--
-- Name: gha_repos_langs; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_repos_langs (
    repo_name character varying(160) NOT NULL,
    lang_name character varying(60) NOT NULL,
    lang_loc bigint NOT NULL,
    lang_perc double precision NOT NULL,
    dt timestamp without time zone DEFAULT now()
);


ALTER TABLE public.gha_repos_langs OWNER TO gha_admin;

--
-- Name: gha_reviews; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_reviews (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    commit_id character varying(40) NOT NULL,
    submitted_at timestamp without time zone NOT NULL,
    author_association text NOT NULL,
    state text NOT NULL,
    body text,
    event_id bigint NOT NULL,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL,
    dup_user_login character varying(120) NOT NULL
);


ALTER TABLE public.gha_reviews OWNER TO gha_admin;

--
-- Name: gha_skip_commits; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_skip_commits (
    sha character varying(40) NOT NULL,
    dt timestamp without time zone NOT NULL,
    reason integer NOT NULL
);


ALTER TABLE public.gha_skip_commits OWNER TO gha_admin;

--
-- Name: gha_teams; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_teams (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    name character varying(120) NOT NULL,
    slug character varying(100) NOT NULL,
    permission character varying(20) NOT NULL,
    dup_actor_id bigint NOT NULL,
    dup_actor_login character varying(120) NOT NULL,
    dup_repo_id bigint NOT NULL,
    dup_repo_name character varying(160) NOT NULL,
    dup_type character varying(40) NOT NULL,
    dup_created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.gha_teams OWNER TO gha_admin;

--
-- Name: gha_teams_repositories; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_teams_repositories (
    team_id bigint NOT NULL,
    event_id bigint NOT NULL,
    repository_id bigint NOT NULL
);


ALTER TABLE public.gha_teams_repositories OWNER TO gha_admin;

--
-- Name: gha_texts; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_texts (
    event_id bigint,
    body text,
    created_at timestamp without time zone NOT NULL,
    actor_id bigint NOT NULL,
    actor_login character varying(120) NOT NULL,
    repo_id bigint NOT NULL,
    repo_name character varying(160) NOT NULL,
    type character varying(40) NOT NULL
);


ALTER TABLE public.gha_texts OWNER TO gha_admin;

--
-- Name: gha_vars; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.gha_vars (
    name character varying(100) NOT NULL,
    value_i bigint,
    value_f double precision,
    value_s text,
    value_dt timestamp without time zone
);


ALTER TABLE public.gha_vars OWNER TO gha_admin;

--
-- Name: sannotations; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sannotations (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    title text DEFAULT ''::text NOT NULL,
    description text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.sannotations OWNER TO gha_admin;

--
-- Name: sawaiting_prs_by_sig_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sawaiting_prs_by_sig_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sawaiting_prs_by_sig_repos OWNER TO gha_admin;

--
-- Name: sawaiting_prs_by_sigd10; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sawaiting_prs_by_sigd10 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sawaiting_prs_by_sigd10 OWNER TO gha_admin;

--
-- Name: sawaiting_prs_by_sigd30; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sawaiting_prs_by_sigd30 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sawaiting_prs_by_sigd30 OWNER TO gha_admin;

--
-- Name: sawaiting_prs_by_sigd60; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sawaiting_prs_by_sigd60 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sawaiting_prs_by_sigd60 OWNER TO gha_admin;

--
-- Name: sawaiting_prs_by_sigd90; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sawaiting_prs_by_sigd90 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sawaiting_prs_by_sigd90 OWNER TO gha_admin;

--
-- Name: sawaiting_prs_by_sigy; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sawaiting_prs_by_sigy (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sawaiting_prs_by_sigy OWNER TO gha_admin;

--
-- Name: sbot_commands; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sbot_commands (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "/unassign" double precision DEFAULT 0.0 NOT NULL,
    "/uncc" double precision DEFAULT 0.0 NOT NULL,
    "/joke" double precision DEFAULT 0.0 NOT NULL,
    "/release-note-none" double precision DEFAULT 0.0 NOT NULL,
    "/area" double precision DEFAULT 0.0 NOT NULL,
    "/priority" double precision DEFAULT 0.0 NOT NULL,
    "/retest" double precision DEFAULT 0.0 NOT NULL,
    "/hold cancel" double precision DEFAULT 0.0 NOT NULL,
    "/lgtm" double precision DEFAULT 0.0 NOT NULL,
    "/remove-priority" double precision DEFAULT 0.0 NOT NULL,
    "/approve cancel" double precision DEFAULT 0.0 NOT NULL,
    "/test all" double precision DEFAULT 0.0 NOT NULL,
    "/remove-kind" double precision DEFAULT 0.0 NOT NULL,
    "/cc" double precision DEFAULT 0.0 NOT NULL,
    "/release-note" double precision DEFAULT 0.0 NOT NULL,
    "/remove-sig" double precision DEFAULT 0.0 NOT NULL,
    "/reopen" double precision DEFAULT 0.0 NOT NULL,
    "/lgtm cancel" double precision DEFAULT 0.0 NOT NULL,
    "/assign" double precision DEFAULT 0.0 NOT NULL,
    "/ok-to-test" double precision DEFAULT 0.0 NOT NULL,
    "/sig" double precision DEFAULT 0.0 NOT NULL,
    "/hold" double precision DEFAULT 0.0 NOT NULL,
    "/lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "/kind" double precision DEFAULT 0.0 NOT NULL,
    "/test" double precision DEFAULT 0.0 NOT NULL,
    "/close" double precision DEFAULT 0.0 NOT NULL,
    "/approve" double precision DEFAULT 0.0 NOT NULL,
    "/remove area" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sbot_commands OWNER TO gha_admin;

--
-- Name: sbot_commands_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sbot_commands_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "/close" double precision DEFAULT 0.0 NOT NULL,
    "/lgtm" double precision DEFAULT 0.0 NOT NULL,
    "/cc" double precision DEFAULT 0.0 NOT NULL,
    "/retest" double precision DEFAULT 0.0 NOT NULL,
    "/test all" double precision DEFAULT 0.0 NOT NULL,
    "/approve cancel" double precision DEFAULT 0.0 NOT NULL,
    "/assign" double precision DEFAULT 0.0 NOT NULL,
    "/kind" double precision DEFAULT 0.0 NOT NULL,
    "/approve" double precision DEFAULT 0.0 NOT NULL,
    "/lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "/joke" double precision DEFAULT 0.0 NOT NULL,
    "/ok-to-test" double precision DEFAULT 0.0 NOT NULL,
    "/test" double precision DEFAULT 0.0 NOT NULL,
    "/reopen" double precision DEFAULT 0.0 NOT NULL,
    "/lgtm cancel" double precision DEFAULT 0.0 NOT NULL,
    "/hold cancel" double precision DEFAULT 0.0 NOT NULL,
    "/hold" double precision DEFAULT 0.0 NOT NULL,
    "/unassign" double precision DEFAULT 0.0 NOT NULL,
    "/sig" double precision DEFAULT 0.0 NOT NULL,
    "/area" double precision DEFAULT 0.0 NOT NULL,
    "/uncc" double precision DEFAULT 0.0 NOT NULL,
    "/release-note-none" double precision DEFAULT 0.0 NOT NULL,
    "/priority" double precision DEFAULT 0.0 NOT NULL,
    "/remove-sig" double precision DEFAULT 0.0 NOT NULL,
    "/release-note" double precision DEFAULT 0.0 NOT NULL,
    "/remove-kind" double precision DEFAULT 0.0 NOT NULL,
    "/remove-priority" double precision DEFAULT 0.0 NOT NULL,
    "/remove area" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sbot_commands_repos OWNER TO gha_admin;

--
-- Name: scntrs_and_orgs; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.scntrs_and_orgs (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.scntrs_and_orgs OWNER TO gha_admin;

--
-- Name: scompany_activity; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.scompany_activity (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "Uber" double precision DEFAULT 0.0 NOT NULL,
    "Independent" double precision DEFAULT 0.0 NOT NULL,
    "Docker Inc." double precision DEFAULT 0.0 NOT NULL,
    "Walmart Inc." double precision DEFAULT 0.0 NOT NULL,
    "EPAM Systems Inc" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "Mirantis Inc." double precision DEFAULT 0.0 NOT NULL,
    "Pivotal" double precision DEFAULT 0.0 NOT NULL,
    "VMware Inc." double precision DEFAULT 0.0 NOT NULL,
    "Amadeus" double precision DEFAULT 0.0 NOT NULL,
    "Intel Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Hewlett" double precision DEFAULT 0.0 NOT NULL,
    "NetApp Inc" double precision DEFAULT 0.0 NOT NULL,
    "Mesosphere" double precision DEFAULT 0.0 NOT NULL,
    "LinkedIn Corporation" double precision DEFAULT 0.0 NOT NULL,
    "HP Inc." double precision DEFAULT 0.0 NOT NULL,
    "CloudBees Inc." double precision DEFAULT 0.0 NOT NULL,
    "Amazon" double precision DEFAULT 0.0 NOT NULL,
    "Yahoo! Inc." double precision DEFAULT 0.0 NOT NULL,
    "DaoCloud Network Technology Co. Ltd." double precision DEFAULT 0.0 NOT NULL,
    "Tencent Holdings Limited" double precision DEFAULT 0.0 NOT NULL,
    "Ubisoft" double precision DEFAULT 0.0 NOT NULL,
    "Orange SA" double precision DEFAULT 0.0 NOT NULL,
    "Alibaba Group" double precision DEFAULT 0.0 NOT NULL,
    "Cloudflare Inc" double precision DEFAULT 0.0 NOT NULL,
    "Samsung Electronics Co. Ltd." double precision DEFAULT 0.0 NOT NULL,
    "Shopify Inc." double precision DEFAULT 0.0 NOT NULL,
    "Verizon" double precision DEFAULT 0.0 NOT NULL,
    "ThoughtWorks Inc" double precision DEFAULT 0.0 NOT NULL,
    "NetEase Inc" double precision DEFAULT 0.0 NOT NULL,
    "Spotify AB" double precision DEFAULT 0.0 NOT NULL,
    "HashiCorp Inc" double precision DEFAULT 0.0 NOT NULL,
    "Red Hat Inc." double precision DEFAULT 0.0 NOT NULL,
    "Cisco Systems Inc." double precision DEFAULT 0.0 NOT NULL,
    "AT&T Services Inc." double precision DEFAULT 0.0 NOT NULL,
    "Dell Technologies" double precision DEFAULT 0.0 NOT NULL,
    "Dell EMC" double precision DEFAULT 0.0 NOT NULL,
    "eBay Inc." double precision DEFAULT 0.0 NOT NULL,
    "Microsoft Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Cloudera Inc." double precision DEFAULT 0.0 NOT NULL,
    "Apple Inc." double precision DEFAULT 0.0 NOT NULL,
    "NEC Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Google LLC" double precision DEFAULT 0.0 NOT NULL,
    "Apache" double precision DEFAULT 0.0 NOT NULL,
    "Mozilla Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Rackspace" double precision DEFAULT 0.0 NOT NULL,
    "Huawei Technologies Co. Ltd" double precision DEFAULT 0.0 NOT NULL,
    "International Business Machines Corporation" double precision DEFAULT 0.0 CONSTRAINT "scompany_activity_International Business Machines Corp_not_null" NOT NULL,
    "Canonical Ltd." double precision DEFAULT 0.0 NOT NULL,
    "CERN" double precision DEFAULT 0.0 NOT NULL,
    "DigitalOcean" double precision DEFAULT 0.0 NOT NULL,
    "Twitter Inc." double precision DEFAULT 0.0 NOT NULL,
    "Jd.Com" double precision DEFAULT 0.0 NOT NULL,
    "Oracle America Inc." double precision DEFAULT 0.0 NOT NULL,
    "SUSE LLC" double precision DEFAULT 0.0 NOT NULL,
    "Capgemini" double precision DEFAULT 0.0 NOT NULL,
    "AlaudaInc" double precision DEFAULT 0.0 NOT NULL,
    "Sysdig Inc." double precision DEFAULT 0.0 NOT NULL,
    "Fujitsu Limited" double precision DEFAULT 0.0 NOT NULL,
    "Accenture Global Solutions Limited" double precision DEFAULT 0.0 NOT NULL,
    "SAP" double precision DEFAULT 0.0 NOT NULL,
    "CNCF" double precision DEFAULT 0.0 NOT NULL,
    "Bloomberg" double precision DEFAULT 0.0 NOT NULL,
    "Weaveworks Inc." double precision DEFAULT 0.0 NOT NULL,
    "Jetstack Ltd" double precision DEFAULT 0.0 NOT NULL,
    "Mirantis" double precision DEFAULT 0.0 NOT NULL,
    "Salesforce.com Inc." double precision DEFAULT 0.0 NOT NULL,
    "Giant Swarm GmbH" double precision DEFAULT 0.0 NOT NULL,
    "Elasticsearch Inc." double precision DEFAULT 0.0 NOT NULL,
    "Meta Platforms Inc." double precision DEFAULT 0.0 NOT NULL,
    "NVIDIA Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Nokia Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Akamai Technologies Inc." double precision DEFAULT 0.0 NOT NULL,
    "Ericsson" double precision DEFAULT 0.0 NOT NULL,
    "Datadog Inc" double precision DEFAULT 0.0 NOT NULL,
    "Atos" double precision DEFAULT 0.0 NOT NULL,
    "Zalando SE" double precision DEFAULT 0.0 NOT NULL,
    "Intuit Inc." double precision DEFAULT 0.0 NOT NULL,
    "Splunk Inc." double precision DEFAULT 0.0 NOT NULL,
    "ZTE Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Isovalent" double precision DEFAULT 0.0 NOT NULL,
    "Bytedance Ltd" double precision DEFAULT 0.0 NOT NULL,
    "Tencent" double precision DEFAULT 0.0 NOT NULL,
    "YANDEX LLC" double precision DEFAULT 0.0 NOT NULL,
    "OpenStack Foundation" double precision DEFAULT 0.0 NOT NULL,
    "Kong Inc." double precision DEFAULT 0.0 NOT NULL,
    "Adobe Inc." double precision DEFAULT 0.0 NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "Capital One" double precision DEFAULT 0.0 NOT NULL,
    "Deutsche Bank AG" double precision DEFAULT 0.0 NOT NULL,
    "New Relic Inc." double precision DEFAULT 0.0 NOT NULL,
    "Kubermatic GmbH" double precision DEFAULT 0.0 NOT NULL,
    "Goldman Sachs & Co. LLC" double precision DEFAULT 0.0 NOT NULL,
    "Deutsche Telekom" double precision DEFAULT 0.0 NOT NULL,
    "Tesla Inc." double precision DEFAULT 0.0 NOT NULL,
    "Thales" double precision DEFAULT 0.0 NOT NULL,
    "Equinix Inc." double precision DEFAULT 0.0 NOT NULL,
    "OVH SAS" double precision DEFAULT 0.0 NOT NULL,
    "JPMorgan Chase" double precision DEFAULT 0.0 NOT NULL,
    "Mercedes-Benz AG" double precision DEFAULT 0.0 NOT NULL,
    "Infosys Limited" double precision DEFAULT 0.0 NOT NULL,
    "Confluent" double precision DEFAULT 0.0 NOT NULL,
    "Swisscom" double precision DEFAULT 0.0 NOT NULL,
    "MayaData Inc. (f/k/a CloudByte Inc)" double precision DEFAULT 0.0 NOT NULL,
    "Inspur Group" double precision DEFAULT 0.0 NOT NULL,
    "Grafana Labs" double precision DEFAULT 0.0 NOT NULL,
    "Flant JCS" double precision DEFAULT 0.0 NOT NULL,
    "EPAM" double precision DEFAULT 0.0 NOT NULL,
    "Solo.io" double precision DEFAULT 0.0 NOT NULL,
    "Nutanix Inc." double precision DEFAULT 0.0 NOT NULL,
    "Tata" double precision DEFAULT 0.0 NOT NULL,
    "CGI" double precision DEFAULT 0.0 NOT NULL,
    "Cognizant Technology Solutions" double precision DEFAULT 0.0 NOT NULL,
    "Infracloud Technologies INC" double precision DEFAULT 0.0 NOT NULL,
    "Bosch" double precision DEFAULT 0.0 NOT NULL,
    "D2iQ Inc. (f/k/a Mesosphere)" double precision DEFAULT 0.0 NOT NULL,
    "DXC Technology" double precision DEFAULT 0.0 NOT NULL,
    "Career Break" double precision DEFAULT 0.0 NOT NULL,
    "Deloitte" double precision DEFAULT 0.0 NOT NULL,
    "Nirmata Inc." double precision DEFAULT 0.0 NOT NULL,
    "GirlScript Foundation" double precision DEFAULT 0.0 NOT NULL,
    "Acquia Inc." double precision DEFAULT 0.0 NOT NULL,
    "Tetrate.io" double precision DEFAULT 0.0 NOT NULL,
    "Layer5" double precision DEFAULT 0.0 NOT NULL,
    "Broadcom Corporation" double precision DEFAULT 0.0 NOT NULL,
    "EDB" double precision DEFAULT 0.0 NOT NULL,
    "Spectro Cloud" double precision DEFAULT 0.0 NOT NULL,
    "Akuity Inc." double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.scompany_activity OWNER TO gha_admin;

--
-- Name: scompany_activity_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.scompany_activity_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "Jd.Com" double precision DEFAULT 0.0 NOT NULL,
    "Red Hat Inc." double precision DEFAULT 0.0 NOT NULL,
    "Cisco Systems Inc." double precision DEFAULT 0.0 NOT NULL,
    "Intel Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Yahoo! Inc." double precision DEFAULT 0.0 NOT NULL,
    "Cloudera Inc." double precision DEFAULT 0.0 NOT NULL,
    "NetApp Inc" double precision DEFAULT 0.0 NOT NULL,
    "NetEase Inc" double precision DEFAULT 0.0 NOT NULL,
    "Pivotal" double precision DEFAULT 0.0 NOT NULL,
    "Google LLC" double precision DEFAULT 0.0 NOT NULL,
    "Apache" double precision DEFAULT 0.0 NOT NULL,
    "Amadeus" double precision DEFAULT 0.0 NOT NULL,
    "Ubisoft" double precision DEFAULT 0.0 NOT NULL,
    "Docker Inc." double precision DEFAULT 0.0 NOT NULL,
    "Capgemini" double precision DEFAULT 0.0 NOT NULL,
    "Independent" double precision DEFAULT 0.0 NOT NULL,
    "Microsoft Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Rackspace" double precision DEFAULT 0.0 NOT NULL,
    "CERN" double precision DEFAULT 0.0 NOT NULL,
    "ThoughtWorks Inc" double precision DEFAULT 0.0 NOT NULL,
    "Oracle America Inc." double precision DEFAULT 0.0 NOT NULL,
    "International Business Machines Corporation" double precision DEFAULT 0.0 CONSTRAINT "scompany_activity_repos_International Business Machine_not_null" NOT NULL,
    "VMware Inc." double precision DEFAULT 0.0 NOT NULL,
    "eBay Inc." double precision DEFAULT 0.0 NOT NULL,
    "Uber" double precision DEFAULT 0.0 NOT NULL,
    "Mesosphere" double precision DEFAULT 0.0 NOT NULL,
    "Cloudflare Inc" double precision DEFAULT 0.0 NOT NULL,
    "Amazon" double precision DEFAULT 0.0 NOT NULL,
    "Canonical Ltd." double precision DEFAULT 0.0 NOT NULL,
    "EPAM Systems Inc" double precision DEFAULT 0.0 NOT NULL,
    "LinkedIn Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Huawei Technologies Co. Ltd" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "Alibaba Group" double precision DEFAULT 0.0 NOT NULL,
    "Sysdig Inc." double precision DEFAULT 0.0 NOT NULL,
    "CloudBees Inc." double precision DEFAULT 0.0 NOT NULL,
    "Tencent Holdings Limited" double precision DEFAULT 0.0 NOT NULL,
    "DaoCloud Network Technology Co. Ltd." double precision DEFAULT 0.0 CONSTRAINT "scompany_activity_repos_DaoCloud Network Technology Co_not_null" NOT NULL,
    "Apple Inc." double precision DEFAULT 0.0 NOT NULL,
    "SUSE LLC" double precision DEFAULT 0.0 NOT NULL,
    "AlaudaInc" double precision DEFAULT 0.0 NOT NULL,
    "Fujitsu Limited" double precision DEFAULT 0.0 NOT NULL,
    "Akamai Technologies Inc." double precision DEFAULT 0.0 NOT NULL,
    "Nokia Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Walmart Inc." double precision DEFAULT 0.0 NOT NULL,
    "Spotify AB" double precision DEFAULT 0.0 NOT NULL,
    "Mirantis Inc." double precision DEFAULT 0.0 NOT NULL,
    "CNCF" double precision DEFAULT 0.0 NOT NULL,
    "SAP" double precision DEFAULT 0.0 NOT NULL,
    "Bloomberg" double precision DEFAULT 0.0 NOT NULL,
    "DigitalOcean" double precision DEFAULT 0.0 NOT NULL,
    "NVIDIA Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Accenture Global Solutions Limited" double precision DEFAULT 0.0 CONSTRAINT "scompany_activity_repos_Accenture Global Solutions Lim_not_null" NOT NULL,
    "Weaveworks Inc." double precision DEFAULT 0.0 NOT NULL,
    "HP Inc." double precision DEFAULT 0.0 NOT NULL,
    "Mozilla Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Orange SA" double precision DEFAULT 0.0 NOT NULL,
    "HashiCorp Inc" double precision DEFAULT 0.0 NOT NULL,
    "Meta Platforms Inc." double precision DEFAULT 0.0 NOT NULL,
    "Salesforce.com Inc." double precision DEFAULT 0.0 NOT NULL,
    "Shopify Inc." double precision DEFAULT 0.0 NOT NULL,
    "AT&T Services Inc." double precision DEFAULT 0.0 NOT NULL,
    "Intuit Inc." double precision DEFAULT 0.0 NOT NULL,
    "Giant Swarm GmbH" double precision DEFAULT 0.0 NOT NULL,
    "ZTE Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Jetstack Ltd" double precision DEFAULT 0.0 NOT NULL,
    "OpenStack Foundation" double precision DEFAULT 0.0 NOT NULL,
    "Mirantis" double precision DEFAULT 0.0 NOT NULL,
    "Deutsche Bank AG" double precision DEFAULT 0.0 NOT NULL,
    "Dell Technologies" double precision DEFAULT 0.0 NOT NULL,
    "Elasticsearch Inc." double precision DEFAULT 0.0 NOT NULL,
    "Bytedance Ltd" double precision DEFAULT 0.0 NOT NULL,
    "Capital One" double precision DEFAULT 0.0 NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "Verizon" double precision DEFAULT 0.0 NOT NULL,
    "Zalando SE" double precision DEFAULT 0.0 NOT NULL,
    "Goldman Sachs & Co. LLC" double precision DEFAULT 0.0 NOT NULL,
    "Deutsche Telekom" double precision DEFAULT 0.0 NOT NULL,
    "Kubermatic GmbH" double precision DEFAULT 0.0 NOT NULL,
    "Hewlett" double precision DEFAULT 0.0 NOT NULL,
    "NEC Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Tesla Inc." double precision DEFAULT 0.0 NOT NULL,
    "Samsung Electronics Co. Ltd." double precision DEFAULT 0.0 NOT NULL,
    "MayaData Inc. (f/k/a CloudByte Inc)" double precision DEFAULT 0.0 CONSTRAINT "scompany_activity_repos_MayaData Inc. (f/k/a CloudByte_not_null" NOT NULL,
    "Isovalent" double precision DEFAULT 0.0 NOT NULL,
    "Confluent" double precision DEFAULT 0.0 NOT NULL,
    "JPMorgan Chase" double precision DEFAULT 0.0 NOT NULL,
    "Solo.io" double precision DEFAULT 0.0 NOT NULL,
    "Thales" double precision DEFAULT 0.0 NOT NULL,
    "Tencent" double precision DEFAULT 0.0 NOT NULL,
    "Twitter Inc." double precision DEFAULT 0.0 NOT NULL,
    "Splunk Inc." double precision DEFAULT 0.0 NOT NULL,
    "YANDEX LLC" double precision DEFAULT 0.0 NOT NULL,
    "Dell EMC" double precision DEFAULT 0.0 NOT NULL,
    "Inspur Group" double precision DEFAULT 0.0 NOT NULL,
    "Ericsson" double precision DEFAULT 0.0 NOT NULL,
    "Atos" double precision DEFAULT 0.0 NOT NULL,
    "Datadog Inc" double precision DEFAULT 0.0 NOT NULL,
    "Nutanix Inc." double precision DEFAULT 0.0 NOT NULL,
    "Adobe Inc." double precision DEFAULT 0.0 NOT NULL,
    "New Relic Inc." double precision DEFAULT 0.0 NOT NULL,
    "OVH SAS" double precision DEFAULT 0.0 NOT NULL,
    "Kong Inc." double precision DEFAULT 0.0 NOT NULL,
    "Infosys Limited" double precision DEFAULT 0.0 NOT NULL,
    "Mercedes-Benz AG" double precision DEFAULT 0.0 NOT NULL,
    "Swisscom" double precision DEFAULT 0.0 NOT NULL,
    "Tata" double precision DEFAULT 0.0 NOT NULL,
    "Equinix Inc." double precision DEFAULT 0.0 NOT NULL,
    "Grafana Labs" double precision DEFAULT 0.0 NOT NULL,
    "Flant JCS" double precision DEFAULT 0.0 NOT NULL,
    "EPAM" double precision DEFAULT 0.0 NOT NULL,
    "Cognizant Technology Solutions" double precision DEFAULT 0.0 NOT NULL,
    "D2iQ Inc. (f/k/a Mesosphere)" double precision DEFAULT 0.0 NOT NULL,
    "CGI" double precision DEFAULT 0.0 NOT NULL,
    "Bosch" double precision DEFAULT 0.0 NOT NULL,
    "Career Break" double precision DEFAULT 0.0 NOT NULL,
    "Infracloud Technologies INC" double precision DEFAULT 0.0 NOT NULL,
    "DXC Technology" double precision DEFAULT 0.0 NOT NULL,
    "Deloitte" double precision DEFAULT 0.0 NOT NULL,
    "Acquia Inc." double precision DEFAULT 0.0 NOT NULL,
    "Nirmata Inc." double precision DEFAULT 0.0 NOT NULL,
    "GirlScript Foundation" double precision DEFAULT 0.0 NOT NULL,
    "Tetrate.io" double precision DEFAULT 0.0 NOT NULL,
    "Broadcom Corporation" double precision DEFAULT 0.0 NOT NULL,
    "Layer5" double precision DEFAULT 0.0 NOT NULL,
    "EDB" double precision DEFAULT 0.0 NOT NULL,
    "Spectro Cloud" double precision DEFAULT 0.0 NOT NULL,
    "Akuity Inc." double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.scompany_activity_repos OWNER TO gha_admin;

--
-- Name: scompany_prs_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.scompany_prs_repos (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    name text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.scompany_prs_repos OWNER TO gha_admin;

--
-- Name: scountries; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.scountries (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "France" double precision DEFAULT 0.0 NOT NULL,
    "Poland" double precision DEFAULT 0.0 NOT NULL,
    "United States" double precision DEFAULT 0.0 NOT NULL,
    "Brazil" double precision DEFAULT 0.0 NOT NULL,
    "Nicaragua" double precision DEFAULT 0.0 NOT NULL,
    "United Kingdom" double precision DEFAULT 0.0 NOT NULL,
    "Argentina" double precision DEFAULT 0.0 NOT NULL,
    "China" double precision DEFAULT 0.0 NOT NULL,
    "Japan" double precision DEFAULT 0.0 NOT NULL,
    "Germany" double precision DEFAULT 0.0 NOT NULL,
    "Slovenia" double precision DEFAULT 0.0 NOT NULL,
    "Belgium" double precision DEFAULT 0.0 NOT NULL,
    "Hong Kong" double precision DEFAULT 0.0 NOT NULL,
    "Israel" double precision DEFAULT 0.0 NOT NULL,
    "Tanzania United Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Netherlands" double precision DEFAULT 0.0 NOT NULL,
    "India" double precision DEFAULT 0.0 NOT NULL,
    "Romania" double precision DEFAULT 0.0 NOT NULL,
    "Bolivia Plurinational State of" double precision DEFAULT 0.0 NOT NULL,
    "Russian Federation" double precision DEFAULT 0.0 NOT NULL,
    "Viet Nam" double precision DEFAULT 0.0 NOT NULL,
    "Switzerland" double precision DEFAULT 0.0 NOT NULL,
    "Pakistan" double precision DEFAULT 0.0 NOT NULL,
    "Syrian Arab Republic" double precision DEFAULT 0.0 NOT NULL,
    "Sweden" double precision DEFAULT 0.0 NOT NULL,
    "Thailand" double precision DEFAULT 0.0 NOT NULL,
    "Panama" double precision DEFAULT 0.0 NOT NULL,
    "Saudi Arabia" double precision DEFAULT 0.0 NOT NULL,
    "Belarus" double precision DEFAULT 0.0 NOT NULL,
    "Norway" double precision DEFAULT 0.0 NOT NULL,
    "New Caledonia" double precision DEFAULT 0.0 NOT NULL,
    "Spain" double precision DEFAULT 0.0 NOT NULL,
    "Greece" double precision DEFAULT 0.0 NOT NULL,
    "New Zealand" double precision DEFAULT 0.0 NOT NULL,
    "Ireland" double precision DEFAULT 0.0 NOT NULL,
    "Eritrea" double precision DEFAULT 0.0 NOT NULL,
    "Uruguay" double precision DEFAULT 0.0 NOT NULL,
    "Slovakia" double precision DEFAULT 0.0 NOT NULL,
    "Portugal" double precision DEFAULT 0.0 NOT NULL,
    "Italy" double precision DEFAULT 0.0 NOT NULL,
    "Denmark" double precision DEFAULT 0.0 NOT NULL,
    "Sri Lanka" double precision DEFAULT 0.0 NOT NULL,
    "South Africa" double precision DEFAULT 0.0 NOT NULL,
    "Iran Islamic Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Czech Republic" double precision DEFAULT 0.0 NOT NULL,
    "Ukraine" double precision DEFAULT 0.0 NOT NULL,
    "United Arab Emirates" double precision DEFAULT 0.0 NOT NULL,
    "Indonesia" double precision DEFAULT 0.0 NOT NULL,
    "Guatemala" double precision DEFAULT 0.0 NOT NULL,
    "Albania" double precision DEFAULT 0.0 NOT NULL,
    "Saint Lucia" double precision DEFAULT 0.0 NOT NULL,
    "Australia" double precision DEFAULT 0.0 NOT NULL,
    "Nigeria" double precision DEFAULT 0.0 NOT NULL,
    "Singapore" double precision DEFAULT 0.0 NOT NULL,
    "Georgia" double precision DEFAULT 0.0 NOT NULL,
    "Nepal" double precision DEFAULT 0.0 NOT NULL,
    "Philippines" double precision DEFAULT 0.0 NOT NULL,
    "Venezuela Bolivarian Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Colombia" double precision DEFAULT 0.0 NOT NULL,
    "Turkey" double precision DEFAULT 0.0 NOT NULL,
    "Algeria" double precision DEFAULT 0.0 NOT NULL,
    "Korea Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Mexico" double precision DEFAULT 0.0 NOT NULL,
    "Luxembourg" double precision DEFAULT 0.0 NOT NULL,
    "Malaysia" double precision DEFAULT 0.0 NOT NULL,
    "Bangladesh" double precision DEFAULT 0.0 NOT NULL,
    "Estonia" double precision DEFAULT 0.0 NOT NULL,
    "Austria" double precision DEFAULT 0.0 NOT NULL,
    "Finland" double precision DEFAULT 0.0 NOT NULL,
    "Hungary" double precision DEFAULT 0.0 NOT NULL,
    "Bulgaria" double precision DEFAULT 0.0 NOT NULL,
    "Kazakhstan" double precision DEFAULT 0.0 NOT NULL,
    "Canada" double precision DEFAULT 0.0 NOT NULL,
    "Bosnia and Herzegovina" double precision DEFAULT 0.0 NOT NULL,
    "Chile" double precision DEFAULT 0.0 NOT NULL,
    "Croatia" double precision DEFAULT 0.0 NOT NULL,
    "Lithuania" double precision DEFAULT 0.0 NOT NULL,
    "Iceland" double precision DEFAULT 0.0 NOT NULL,
    "Taiwan Province of China" double precision DEFAULT 0.0 NOT NULL,
    "Kenya" double precision DEFAULT 0.0 NOT NULL,
    "Niger" double precision DEFAULT 0.0 NOT NULL,
    "Afghanistan" double precision DEFAULT 0.0 NOT NULL,
    "Cyprus" double precision DEFAULT 0.0 NOT NULL,
    "Congo the Democratic Republic of the" double precision DEFAULT 0.0 NOT NULL,
    "Mauritius" double precision DEFAULT 0.0 NOT NULL,
    "Myanmar" double precision DEFAULT 0.0 NOT NULL,
    "Latvia" double precision DEFAULT 0.0 NOT NULL,
    "El Salvador" double precision DEFAULT 0.0 NOT NULL,
    "Andorra" double precision DEFAULT 0.0 NOT NULL,
    "Uganda" double precision DEFAULT 0.0 NOT NULL,
    "Egypt" double precision DEFAULT 0.0 NOT NULL,
    "Cambodia" double precision DEFAULT 0.0 NOT NULL,
    "Armenia" double precision DEFAULT 0.0 NOT NULL,
    "Malta" double precision DEFAULT 0.0 NOT NULL,
    "Peru" double precision DEFAULT 0.0 NOT NULL,
    "Tunisia" double precision DEFAULT 0.0 NOT NULL,
    "Benin" double precision DEFAULT 0.0 NOT NULL,
    "Paraguay" double precision DEFAULT 0.0 NOT NULL,
    "Moldova Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Ghana" double precision DEFAULT 0.0 NOT NULL,
    "Lebanon" double precision DEFAULT 0.0 NOT NULL,
    "Morocco" double precision DEFAULT 0.0 NOT NULL,
    "Iraq" double precision DEFAULT 0.0 NOT NULL,
    "Jordan" double precision DEFAULT 0.0 NOT NULL,
    "Virgin Islands U.S." double precision DEFAULT 0.0 NOT NULL,
    "Macao" double precision DEFAULT 0.0 NOT NULL,
    "Serbia and Montenegro" double precision DEFAULT 0.0 NOT NULL,
    "Jamaica" double precision DEFAULT 0.0 NOT NULL,
    "Zimbabwe" double precision DEFAULT 0.0 NOT NULL,
    "Zambia" double precision DEFAULT 0.0 NOT NULL,
    "Rwanda" double precision DEFAULT 0.0 NOT NULL,
    "Belize" double precision DEFAULT 0.0 NOT NULL,
    "Togo" double precision DEFAULT 0.0 NOT NULL,
    "Uzbekistan" double precision DEFAULT 0.0 NOT NULL,
    "Côte Divoire" double precision DEFAULT 0.0 NOT NULL,
    "Mozambique" double precision DEFAULT 0.0 NOT NULL,
    "Cameroon" double precision DEFAULT 0.0 NOT NULL,
    "Qatar" double precision DEFAULT 0.0 NOT NULL,
    "Lesotho" double precision DEFAULT 0.0 NOT NULL,
    "Antarctica" double precision DEFAULT 0.0 NOT NULL,
    "Macedonia the Former Yugoslav Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Bhutan" double precision DEFAULT 0.0 NOT NULL,
    "Dominican Republic" double precision DEFAULT 0.0 NOT NULL,
    "Angola" double precision DEFAULT 0.0 NOT NULL,
    "Serbia" double precision DEFAULT 0.0 NOT NULL,
    "Azerbaijan" double precision DEFAULT 0.0 NOT NULL,
    "Costa Rica" double precision DEFAULT 0.0 NOT NULL,
    "Senegal" double precision DEFAULT 0.0 NOT NULL,
    "Kuwait" double precision DEFAULT 0.0 NOT NULL,
    "Liberia" double precision DEFAULT 0.0 NOT NULL,
    "Réunion" double precision DEFAULT 0.0 NOT NULL,
    "Papua New Guinea" double precision DEFAULT 0.0 NOT NULL,
    "Turkmenistan" double precision DEFAULT 0.0 NOT NULL,
    "Ecuador" double precision DEFAULT 0.0 NOT NULL,
    "Palestine State of" double precision DEFAULT 0.0 NOT NULL,
    "Kyrgyzstan" double precision DEFAULT 0.0 NOT NULL,
    "Guinea" double precision DEFAULT 0.0 NOT NULL,
    "Saint Vincent and the Grenadines" double precision DEFAULT 0.0 NOT NULL,
    "Lao People Democratic Republic" double precision DEFAULT 0.0 NOT NULL,
    "French Polynesia" double precision DEFAULT 0.0 NOT NULL,
    "Burkina Faso" double precision DEFAULT 0.0 NOT NULL,
    "Cape Verde" double precision DEFAULT 0.0 NOT NULL,
    "Saint Kitts and Nevis" double precision DEFAULT 0.0 NOT NULL,
    "Guyana" double precision DEFAULT 0.0 NOT NULL,
    "Curaçao" double precision DEFAULT 0.0 NOT NULL,
    "Puerto Rico" double precision DEFAULT 0.0 NOT NULL,
    "Madagascar" double precision DEFAULT 0.0 NOT NULL,
    "Comoros" double precision DEFAULT 0.0 NOT NULL,
    "Trinidad and Tobago" double precision DEFAULT 0.0 NOT NULL,
    "Nauru" double precision DEFAULT 0.0 NOT NULL,
    "Sudan" double precision DEFAULT 0.0 NOT NULL,
    "Mali" double precision DEFAULT 0.0 NOT NULL,
    "Brunei Darussalam" double precision DEFAULT 0.0 NOT NULL,
    "Equatorial Guinea" double precision DEFAULT 0.0 NOT NULL,
    "Guam" double precision DEFAULT 0.0 NOT NULL,
    "Ethiopia" double precision DEFAULT 0.0 NOT NULL,
    "Bermuda" double precision DEFAULT 0.0 NOT NULL,
    "Oman" double precision DEFAULT 0.0 NOT NULL,
    "Greenland" double precision DEFAULT 0.0 NOT NULL,
    "Guinea-Bissau" double precision DEFAULT 0.0 NOT NULL,
    "Mauritania" double precision DEFAULT 0.0 NOT NULL,
    "Cuba" double precision DEFAULT 0.0 NOT NULL,
    "Somalia" double precision DEFAULT 0.0 NOT NULL,
    "Haiti" double precision DEFAULT 0.0 NOT NULL,
    "Martinique" double precision DEFAULT 0.0 NOT NULL,
    "Botswana" double precision DEFAULT 0.0 NOT NULL,
    "Korea Democratic People Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Sierra Leone" double precision DEFAULT 0.0 NOT NULL,
    "Gambia" double precision DEFAULT 0.0 NOT NULL,
    "Tajikistan" double precision DEFAULT 0.0 NOT NULL,
    "Antigua and Barbuda" double precision DEFAULT 0.0 NOT NULL,
    "Northern Mariana Islands" double precision DEFAULT 0.0 NOT NULL,
    "South Sudan" double precision DEFAULT 0.0 NOT NULL,
    "Bahrain" double precision DEFAULT 0.0 NOT NULL,
    "Maldives" double precision DEFAULT 0.0 NOT NULL,
    "Gibraltar" double precision DEFAULT 0.0 NOT NULL,
    "Faroe Islands" double precision DEFAULT 0.0 NOT NULL,
    "Honduras" double precision DEFAULT 0.0 NOT NULL,
    "Chad" double precision DEFAULT 0.0 NOT NULL,
    "Solomon Islands" double precision DEFAULT 0.0 NOT NULL,
    "Malawi" double precision DEFAULT 0.0 NOT NULL,
    "Montenegro" double precision DEFAULT 0.0 NOT NULL,
    "Aruba" double precision DEFAULT 0.0 NOT NULL,
    "Bahamas" double precision DEFAULT 0.0 NOT NULL,
    "Barbados" double precision DEFAULT 0.0 NOT NULL,
    "British Indian Ocean Territory" double precision DEFAULT 0.0 NOT NULL,
    "Cayman Islands" double precision DEFAULT 0.0 NOT NULL,
    "Central African Republic" double precision DEFAULT 0.0 NOT NULL,
    "Congo" double precision DEFAULT 0.0 NOT NULL,
    "Djibouti" double precision DEFAULT 0.0 NOT NULL,
    "Fiji" double precision DEFAULT 0.0 NOT NULL,
    "French Southern Territories" double precision DEFAULT 0.0 NOT NULL,
    "Gabon" double precision DEFAULT 0.0 NOT NULL,
    "Guadeloupe" double precision DEFAULT 0.0 NOT NULL,
    "Guernsey" double precision DEFAULT 0.0 NOT NULL,
    "Isle of Man" double precision DEFAULT 0.0 NOT NULL,
    "Libya" double precision DEFAULT 0.0 NOT NULL,
    "Liechtenstein" double precision DEFAULT 0.0 NOT NULL,
    "Mongolia" double precision DEFAULT 0.0 NOT NULL,
    "Namibia" double precision DEFAULT 0.0 NOT NULL,
    "Palau" double precision DEFAULT 0.0 NOT NULL,
    "Saint Helena Ascension and Tristan da Cunha" double precision DEFAULT 0.0 NOT NULL,
    "Samoa" double precision DEFAULT 0.0 NOT NULL,
    "San Marino" double precision DEFAULT 0.0 NOT NULL,
    "Suriname" double precision DEFAULT 0.0 NOT NULL,
    "Svalbard and Jan Mayen" double precision DEFAULT 0.0 NOT NULL,
    "Swaziland" double precision DEFAULT 0.0 NOT NULL,
    "Timor-Leste" double precision DEFAULT 0.0 NOT NULL,
    "Vanuatu" double precision DEFAULT 0.0 NOT NULL,
    "Virgin Islands British" double precision DEFAULT 0.0 NOT NULL,
    "Yemen" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.scountries OWNER TO gha_admin;

--
-- Name: scountriescum; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.scountriescum (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "Tunisia" double precision DEFAULT 0.0 NOT NULL,
    "India" double precision DEFAULT 0.0 NOT NULL,
    "Cameroon" double precision DEFAULT 0.0 NOT NULL,
    "Ireland" double precision DEFAULT 0.0 NOT NULL,
    "Nicaragua" double precision DEFAULT 0.0 NOT NULL,
    "South Africa" double precision DEFAULT 0.0 NOT NULL,
    "Poland" double precision DEFAULT 0.0 NOT NULL,
    "Chile" double precision DEFAULT 0.0 NOT NULL,
    "Ukraine" double precision DEFAULT 0.0 NOT NULL,
    "Belgium" double precision DEFAULT 0.0 NOT NULL,
    "Moldova Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Taiwan Province of China" double precision DEFAULT 0.0 NOT NULL,
    "Greece" double precision DEFAULT 0.0 NOT NULL,
    "Austria" double precision DEFAULT 0.0 NOT NULL,
    "Cyprus" double precision DEFAULT 0.0 NOT NULL,
    "Denmark" double precision DEFAULT 0.0 NOT NULL,
    "Lithuania" double precision DEFAULT 0.0 NOT NULL,
    "Hong Kong" double precision DEFAULT 0.0 NOT NULL,
    "Indonesia" double precision DEFAULT 0.0 NOT NULL,
    "Viet Nam" double precision DEFAULT 0.0 NOT NULL,
    "Israel" double precision DEFAULT 0.0 NOT NULL,
    "United Kingdom" double precision DEFAULT 0.0 NOT NULL,
    "Sweden" double precision DEFAULT 0.0 NOT NULL,
    "Latvia" double precision DEFAULT 0.0 NOT NULL,
    "Iran Islamic Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Czech Republic" double precision DEFAULT 0.0 NOT NULL,
    "Portugal" double precision DEFAULT 0.0 NOT NULL,
    "United States" double precision DEFAULT 0.0 NOT NULL,
    "Bosnia and Herzegovina" double precision DEFAULT 0.0 NOT NULL,
    "United Arab Emirates" double precision DEFAULT 0.0 NOT NULL,
    "France" double precision DEFAULT 0.0 NOT NULL,
    "Canada" double precision DEFAULT 0.0 NOT NULL,
    "China" double precision DEFAULT 0.0 NOT NULL,
    "Bangladesh" double precision DEFAULT 0.0 NOT NULL,
    "Russian Federation" double precision DEFAULT 0.0 NOT NULL,
    "Philippines" double precision DEFAULT 0.0 NOT NULL,
    "Norway" double precision DEFAULT 0.0 NOT NULL,
    "Hungary" double precision DEFAULT 0.0 NOT NULL,
    "Korea Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Australia" double precision DEFAULT 0.0 NOT NULL,
    "Romania" double precision DEFAULT 0.0 NOT NULL,
    "Switzerland" double precision DEFAULT 0.0 NOT NULL,
    "Jordan" double precision DEFAULT 0.0 NOT NULL,
    "Singapore" double precision DEFAULT 0.0 NOT NULL,
    "Italy" double precision DEFAULT 0.0 NOT NULL,
    "Germany" double precision DEFAULT 0.0 NOT NULL,
    "Estonia" double precision DEFAULT 0.0 NOT NULL,
    "Brazil" double precision DEFAULT 0.0 NOT NULL,
    "Netherlands" double precision DEFAULT 0.0 NOT NULL,
    "Turkey" double precision DEFAULT 0.0 NOT NULL,
    "Belarus" double precision DEFAULT 0.0 NOT NULL,
    "Argentina" double precision DEFAULT 0.0 NOT NULL,
    "Costa Rica" double precision DEFAULT 0.0 NOT NULL,
    "Croatia" double precision DEFAULT 0.0 NOT NULL,
    "Venezuela Bolivarian Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Armenia" double precision DEFAULT 0.0 NOT NULL,
    "Spain" double precision DEFAULT 0.0 NOT NULL,
    "Japan" double precision DEFAULT 0.0 NOT NULL,
    "Eritrea" double precision DEFAULT 0.0 NOT NULL,
    "Colombia" double precision DEFAULT 0.0 NOT NULL,
    "Albania" double precision DEFAULT 0.0 NOT NULL,
    "Algeria" double precision DEFAULT 0.0 NOT NULL,
    "Sri Lanka" double precision DEFAULT 0.0 NOT NULL,
    "Myanmar" double precision DEFAULT 0.0 NOT NULL,
    "Mauritius" double precision DEFAULT 0.0 NOT NULL,
    "Andorra" double precision DEFAULT 0.0 NOT NULL,
    "Serbia" double precision DEFAULT 0.0 NOT NULL,
    "New Zealand" double precision DEFAULT 0.0 NOT NULL,
    "Nigeria" double precision DEFAULT 0.0 NOT NULL,
    "Saudi Arabia" double precision DEFAULT 0.0 NOT NULL,
    "Slovenia" double precision DEFAULT 0.0 NOT NULL,
    "Guatemala" double precision DEFAULT 0.0 NOT NULL,
    "Nepal" double precision DEFAULT 0.0 NOT NULL,
    "Senegal" double precision DEFAULT 0.0 NOT NULL,
    "Benin" double precision DEFAULT 0.0 NOT NULL,
    "Angola" double precision DEFAULT 0.0 NOT NULL,
    "Kenya" double precision DEFAULT 0.0 NOT NULL,
    "Slovakia" double precision DEFAULT 0.0 NOT NULL,
    "Iceland" double precision DEFAULT 0.0 NOT NULL,
    "Egypt" double precision DEFAULT 0.0 NOT NULL,
    "Bulgaria" double precision DEFAULT 0.0 NOT NULL,
    "Zimbabwe" double precision DEFAULT 0.0 NOT NULL,
    "Finland" double precision DEFAULT 0.0 NOT NULL,
    "Côte Divoire" double precision DEFAULT 0.0 NOT NULL,
    "Mexico" double precision DEFAULT 0.0 NOT NULL,
    "Pakistan" double precision DEFAULT 0.0 NOT NULL,
    "Malaysia" double precision DEFAULT 0.0 NOT NULL,
    "Uzbekistan" double precision DEFAULT 0.0 NOT NULL,
    "Cambodia" double precision DEFAULT 0.0 NOT NULL,
    "Jamaica" double precision DEFAULT 0.0 NOT NULL,
    "Bolivia Plurinational State of" double precision DEFAULT 0.0 NOT NULL,
    "Iraq" double precision DEFAULT 0.0 NOT NULL,
    "Belize" double precision DEFAULT 0.0 NOT NULL,
    "Thailand" double precision DEFAULT 0.0 NOT NULL,
    "Paraguay" double precision DEFAULT 0.0 NOT NULL,
    "Serbia and Montenegro" double precision DEFAULT 0.0 NOT NULL,
    "Congo the Democratic Republic of the" double precision DEFAULT 0.0 NOT NULL,
    "Tanzania United Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Luxembourg" double precision DEFAULT 0.0 NOT NULL,
    "Morocco" double precision DEFAULT 0.0 NOT NULL,
    "Georgia" double precision DEFAULT 0.0 NOT NULL,
    "El Salvador" double precision DEFAULT 0.0 NOT NULL,
    "New Caledonia" double precision DEFAULT 0.0 NOT NULL,
    "Syrian Arab Republic" double precision DEFAULT 0.0 NOT NULL,
    "Macao" double precision DEFAULT 0.0 NOT NULL,
    "Niger" double precision DEFAULT 0.0 NOT NULL,
    "Dominican Republic" double precision DEFAULT 0.0 NOT NULL,
    "Macedonia the Former Yugoslav Republic of" double precision DEFAULT 0.0 CONSTRAINT "scountriescum_Macedonia the Former Yugoslav Republic o_not_null" NOT NULL,
    "Azerbaijan" double precision DEFAULT 0.0 NOT NULL,
    "Peru" double precision DEFAULT 0.0 NOT NULL,
    "Saint Lucia" double precision DEFAULT 0.0 NOT NULL,
    "Malta" double precision DEFAULT 0.0 NOT NULL,
    "Rwanda" double precision DEFAULT 0.0 NOT NULL,
    "Mozambique" double precision DEFAULT 0.0 NOT NULL,
    "Zambia" double precision DEFAULT 0.0 NOT NULL,
    "Lesotho" double precision DEFAULT 0.0 NOT NULL,
    "Kazakhstan" double precision DEFAULT 0.0 NOT NULL,
    "Afghanistan" double precision DEFAULT 0.0 NOT NULL,
    "Uruguay" double precision DEFAULT 0.0 NOT NULL,
    "Togo" double precision DEFAULT 0.0 NOT NULL,
    "Bhutan" double precision DEFAULT 0.0 NOT NULL,
    "Lebanon" double precision DEFAULT 0.0 NOT NULL,
    "Virgin Islands U.S." double precision DEFAULT 0.0 NOT NULL,
    "Ghana" double precision DEFAULT 0.0 NOT NULL,
    "Panama" double precision DEFAULT 0.0 NOT NULL,
    "Antarctica" double precision DEFAULT 0.0 NOT NULL,
    "Qatar" double precision DEFAULT 0.0 NOT NULL,
    "Uganda" double precision DEFAULT 0.0 NOT NULL,
    "Liberia" double precision DEFAULT 0.0 NOT NULL,
    "Réunion" double precision DEFAULT 0.0 NOT NULL,
    "Kyrgyzstan" double precision DEFAULT 0.0 NOT NULL,
    "Guinea" double precision DEFAULT 0.0 NOT NULL,
    "Ecuador" double precision DEFAULT 0.0 NOT NULL,
    "Papua New Guinea" double precision DEFAULT 0.0 NOT NULL,
    "Turkmenistan" double precision DEFAULT 0.0 NOT NULL,
    "Kuwait" double precision DEFAULT 0.0 NOT NULL,
    "Palestine State of" double precision DEFAULT 0.0 NOT NULL,
    "Mali" double precision DEFAULT 0.0 NOT NULL,
    "Oman" double precision DEFAULT 0.0 NOT NULL,
    "Mauritania" double precision DEFAULT 0.0 NOT NULL,
    "Brunei Darussalam" double precision DEFAULT 0.0 NOT NULL,
    "Cape Verde" double precision DEFAULT 0.0 NOT NULL,
    "French Polynesia" double precision DEFAULT 0.0 NOT NULL,
    "Guyana" double precision DEFAULT 0.0 NOT NULL,
    "Bermuda" double precision DEFAULT 0.0 NOT NULL,
    "Madagascar" double precision DEFAULT 0.0 NOT NULL,
    "Saint Kitts and Nevis" double precision DEFAULT 0.0 NOT NULL,
    "Lao People Democratic Republic" double precision DEFAULT 0.0 NOT NULL,
    "Saint Vincent and the Grenadines" double precision DEFAULT 0.0 NOT NULL,
    "Curaçao" double precision DEFAULT 0.0 NOT NULL,
    "Burkina Faso" double precision DEFAULT 0.0 NOT NULL,
    "Comoros" double precision DEFAULT 0.0 NOT NULL,
    "Greenland" double precision DEFAULT 0.0 NOT NULL,
    "Guinea-Bissau" double precision DEFAULT 0.0 NOT NULL,
    "Sudan" double precision DEFAULT 0.0 NOT NULL,
    "Puerto Rico" double precision DEFAULT 0.0 NOT NULL,
    "Equatorial Guinea" double precision DEFAULT 0.0 NOT NULL,
    "Nauru" double precision DEFAULT 0.0 NOT NULL,
    "Ethiopia" double precision DEFAULT 0.0 NOT NULL,
    "Guam" double precision DEFAULT 0.0 NOT NULL,
    "Trinidad and Tobago" double precision DEFAULT 0.0 NOT NULL,
    "South Sudan" double precision DEFAULT 0.0 NOT NULL,
    "Cuba" double precision DEFAULT 0.0 NOT NULL,
    "Haiti" double precision DEFAULT 0.0 NOT NULL,
    "Bahrain" double precision DEFAULT 0.0 NOT NULL,
    "Somalia" double precision DEFAULT 0.0 NOT NULL,
    "Korea Democratic People Republic of" double precision DEFAULT 0.0 NOT NULL,
    "Botswana" double precision DEFAULT 0.0 NOT NULL,
    "Sierra Leone" double precision DEFAULT 0.0 NOT NULL,
    "Martinique" double precision DEFAULT 0.0 NOT NULL,
    "Gambia" double precision DEFAULT 0.0 NOT NULL,
    "Faroe Islands" double precision DEFAULT 0.0 NOT NULL,
    "Northern Mariana Islands" double precision DEFAULT 0.0 NOT NULL,
    "Tajikistan" double precision DEFAULT 0.0 NOT NULL,
    "Gibraltar" double precision DEFAULT 0.0 NOT NULL,
    "Antigua and Barbuda" double precision DEFAULT 0.0 NOT NULL,
    "Maldives" double precision DEFAULT 0.0 NOT NULL,
    "Malawi" double precision DEFAULT 0.0 NOT NULL,
    "Chad" double precision DEFAULT 0.0 NOT NULL,
    "Honduras" double precision DEFAULT 0.0 NOT NULL,
    "Solomon Islands" double precision DEFAULT 0.0 NOT NULL,
    "Montenegro" double precision DEFAULT 0.0 NOT NULL,
    "Aruba" double precision DEFAULT 0.0 NOT NULL,
    "Bahamas" double precision DEFAULT 0.0 NOT NULL,
    "Barbados" double precision DEFAULT 0.0 NOT NULL,
    "British Indian Ocean Territory" double precision DEFAULT 0.0 NOT NULL,
    "Cayman Islands" double precision DEFAULT 0.0 NOT NULL,
    "Central African Republic" double precision DEFAULT 0.0 NOT NULL,
    "Congo" double precision DEFAULT 0.0 NOT NULL,
    "Djibouti" double precision DEFAULT 0.0 NOT NULL,
    "Fiji" double precision DEFAULT 0.0 NOT NULL,
    "French Southern Territories" double precision DEFAULT 0.0 NOT NULL,
    "Gabon" double precision DEFAULT 0.0 NOT NULL,
    "Guadeloupe" double precision DEFAULT 0.0 NOT NULL,
    "Guernsey" double precision DEFAULT 0.0 NOT NULL,
    "Isle of Man" double precision DEFAULT 0.0 NOT NULL,
    "Libya" double precision DEFAULT 0.0 NOT NULL,
    "Liechtenstein" double precision DEFAULT 0.0 NOT NULL,
    "Mongolia" double precision DEFAULT 0.0 NOT NULL,
    "Namibia" double precision DEFAULT 0.0 NOT NULL,
    "Palau" double precision DEFAULT 0.0 NOT NULL,
    "Saint Helena Ascension and Tristan da Cunha" double precision DEFAULT 0.0 CONSTRAINT "scountriescum_Saint Helena Ascension and Tristan da Cu_not_null" NOT NULL,
    "Samoa" double precision DEFAULT 0.0 NOT NULL,
    "San Marino" double precision DEFAULT 0.0 NOT NULL,
    "Suriname" double precision DEFAULT 0.0 NOT NULL,
    "Svalbard and Jan Mayen" double precision DEFAULT 0.0 NOT NULL,
    "Swaziland" double precision DEFAULT 0.0 NOT NULL,
    "Timor-Leste" double precision DEFAULT 0.0 NOT NULL,
    "Vanuatu" double precision DEFAULT 0.0 NOT NULL,
    "Virgin Islands British" double precision DEFAULT 0.0 NOT NULL,
    "Yemen" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.scountriescum OWNER TO gha_admin;

--
-- Name: scs; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.scs (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.scs OWNER TO gha_admin;

--
-- Name: scsr; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.scsr (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.scsr OWNER TO gha_admin;

--
-- Name: sepisodic_contributors; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sepisodic_contributors (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sepisodic_contributors OWNER TO gha_admin;

--
-- Name: sepisodic_contributors_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sepisodic_contributors_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sepisodic_contributors_repos OWNER TO gha_admin;

--
-- Name: sepisodic_issues; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sepisodic_issues (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sepisodic_issues OWNER TO gha_admin;

--
-- Name: sepisodic_issues_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sepisodic_issues_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sepisodic_issues_repos OWNER TO gha_admin;

--
-- Name: sevents_h; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sevents_h (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sevents_h OWNER TO gha_admin;

--
-- Name: sfirst_non_author; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sfirst_non_author (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    descr text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.sfirst_non_author OWNER TO gha_admin;

--
-- Name: sfirst_non_author_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sfirst_non_author_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    descr text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sfirst_non_author_repos OWNER TO gha_admin;

--
-- Name: sgh_stats_r; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sgh_stats_r (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/heapster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kube-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/external-storage" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/aws-load-balancer-controll_not_null" NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kube-batch" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubefed" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/gcp-compute-persistent-dis_not_null" NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-provider-vsphe_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-provider-opens_not_null" NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-provider-digit_not_null" NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/sig-storage-local-static-p_not_null" NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/kubebuilder-declarative-pa_not_null" NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-provider-ibmcl_not_null" NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/multi-tenancy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-provider-packe_not_null" NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/nfs-subdir-external-provis_not_null" NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kpng" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/hierarchical-namespaces" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/ibm-powervs-block-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/gateway-api-inference-exte_not_null" NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-ibm-cloud" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/karpenter-provider-ibm-clo_not_null" NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multicluster-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-ipam-provider-in-cluster" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-ipam-provider-_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/container-object-storage-i_not_null" NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-driver-cpu" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dranet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-readiness-controller" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-addon-provider_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-provider-kubev_not_null" NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/crdify" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gwctl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/work-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-ai-conformance" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/signalhound" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-ai-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cloud-provider-equinix-met_not_null" NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apisnoop" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mdtoc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-serving" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/provider-ibmcloud-test-infra" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/provider-ibmcloud-test-inf_not_null" NOT NULL,
    "kubernetes-sigs/azurelustre-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/nfs-ganesha-server-and-ext_not_null" NOT NULL,
    "kubernetes-sigs/dra-driver-topology" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-network-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-proportional-verti_not_null" NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/verify-conformance" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-sync-controller" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/secrets-store-sync-control_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-agentic-networking" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-inventory-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-multicluster-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/about-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcd-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cosi-driver-sample" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nvmf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minikube-preloads" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-template-project" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/network-policy-finalizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-provider-cloud_not_null" NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-proportional-autos_not_null" NOT NULL,
    "kubernetes-sigs/cve-feed-osv" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/node-feature-discovery-ope_not_null" NOT NULL,
    "kubernetes-sigs/knftables" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kindnet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-fsx-openzfs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/sig-storage-lib-external-p_not_null" NOT NULL,
    "kubernetes-sigs/release-actions" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-csi/volume-data-source-validato_not_null" NOT NULL,
    "kubernetes-sigs/nat64" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/maintainer-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/blixt" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/system-validators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/iptables-wrappers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/slack-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/kube-scheduler-wasm-extens_not_null" NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/ingress-controller-conform_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-file-cache-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/maintainers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-device-management" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-cluster-api" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/karpenter-provider-cluster_not_null" NOT NULL,
    "kubernetes-sigs/minikube-gui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-ipam-controller" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/logtools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/json" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/kube-storage-version-migra_not_null" NOT NULL,
    "kubernetes-sigs/cni-dra-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/porche" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testgrid" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubemark" double precision DEFAULT 0.0 CONSTRAINT "sgh_stats_r_kubernetes-sigs/cluster-api-provider-kubem_not_null" NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-auth-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dynamic-resource-allocation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/community-images" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/depstat" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-release-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-network" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/randfill" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/mount-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minikube-os" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/resource-state-metrics" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sigs-github-actions" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/externalip-webhook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/ruby" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-sample" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/perl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/legacy-cloud-providers" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sgh_stats_r OWNER TO gha_admin;

--
-- Name: sgh_stats_rgrp; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sgh_stats_rgrp (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sgh_stats_rgrp OWNER TO gha_admin;

--
-- Name: shcom; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.shcom (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    name text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.shcom OWNER TO gha_admin;

--
-- Name: shdev; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.shdev (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.shdev OWNER TO gha_admin;

--
-- Name: shdev_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.shdev_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.shdev_repos OWNER TO gha_admin;

--
-- Name: shpr_mergers; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.shpr_mergers (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.shpr_mergers OWNER TO gha_admin;

--
-- Name: shpr_wlsigs; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.shpr_wlsigs (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    abs double precision DEFAULT 0.0 NOT NULL,
    rev double precision DEFAULT 0.0 NOT NULL,
    rel double precision DEFAULT 0.0 NOT NULL,
    sig text DEFAULT ''::text NOT NULL,
    iss double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.shpr_wlsigs OWNER TO gha_admin;

--
-- Name: shpr_wrlsigs; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.shpr_wrlsigs (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    abs double precision DEFAULT 0.0 NOT NULL,
    rev double precision DEFAULT 0.0 NOT NULL,
    rel double precision DEFAULT 0.0 NOT NULL,
    sig text DEFAULT ''::text NOT NULL,
    repo text DEFAULT ''::text NOT NULL,
    iss double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.shpr_wrlsigs OWNER TO gha_admin;

--
-- Name: siclosed_lsk; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.siclosed_lsk (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.siclosed_lsk OWNER TO gha_admin;

--
-- Name: siclosed_lskr; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.siclosed_lskr (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.siclosed_lskr OWNER TO gha_admin;

--
-- Name: sinactive_issues_by_sig_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sinactive_issues_by_sig_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sinactive_issues_by_sig_repos OWNER TO gha_admin;

--
-- Name: sinactive_issues_by_sigd30; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sinactive_issues_by_sigd30 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sinactive_issues_by_sigd30 OWNER TO gha_admin;

--
-- Name: sinactive_issues_by_sigd90; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sinactive_issues_by_sigd90 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sinactive_issues_by_sigd90 OWNER TO gha_admin;

--
-- Name: sinactive_issues_by_sigw2; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sinactive_issues_by_sigw2 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sinactive_issues_by_sigw2 OWNER TO gha_admin;

--
-- Name: sinactive_prs_by_sig_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sinactive_prs_by_sig_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sinactive_prs_by_sig_repos OWNER TO gha_admin;

--
-- Name: sinactive_prs_by_sigd30; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sinactive_prs_by_sigd30 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sinactive_prs_by_sigd30 OWNER TO gha_admin;

--
-- Name: sinactive_prs_by_sigd90; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sinactive_prs_by_sigd90 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sinactive_prs_by_sigd90 OWNER TO gha_admin;

--
-- Name: sinactive_prs_by_sigw2; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sinactive_prs_by_sigw2 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sinactive_prs_by_sigw2 OWNER TO gha_admin;

--
-- Name: sissues_age; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sissues_age (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    descr text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.sissues_age OWNER TO gha_admin;

--
-- Name: sissues_age_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sissues_age_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    descr text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sissues_age_repos OWNER TO gha_admin;

--
-- Name: sissues_milestones; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sissues_milestones (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sissues_milestones OWNER TO gha_admin;

--
-- Name: snew_contributors; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.snew_contributors (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.snew_contributors OWNER TO gha_admin;

--
-- Name: snew_contributors_data; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.snew_contributors_data (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    str text DEFAULT ''::text NOT NULL,
    dt timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone NOT NULL
);


ALTER TABLE public.snew_contributors_data OWNER TO gha_admin;

--
-- Name: snew_contributors_data_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.snew_contributors_data_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    str text DEFAULT ''::text NOT NULL,
    dt timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone NOT NULL
);


ALTER TABLE public.snew_contributors_data_repos OWNER TO gha_admin;

--
-- Name: snew_contributors_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.snew_contributors_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.snew_contributors_repos OWNER TO gha_admin;

--
-- Name: snew_issues; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.snew_issues (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.snew_issues OWNER TO gha_admin;

--
-- Name: snew_issues_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.snew_issues_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.snew_issues_repos OWNER TO gha_admin;

--
-- Name: snum_stats; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.snum_stats (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.snum_stats OWNER TO gha_admin;

--
-- Name: snum_stats_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.snum_stats_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.snum_stats_repos OWNER TO gha_admin;

--
-- Name: spr_apprappr; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_apprappr (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_apprappr OWNER TO gha_admin;

--
-- Name: spr_apprwait; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_apprwait (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_apprwait OWNER TO gha_admin;

--
-- Name: spr_auth; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_auth (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_auth OWNER TO gha_admin;

--
-- Name: spr_auth_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_auth_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_auth_repos OWNER TO gha_admin;

--
-- Name: spr_comms_med; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_comms_med (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_comms_med OWNER TO gha_admin;

--
-- Name: spr_comms_p85; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_comms_p85 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_comms_p85 OWNER TO gha_admin;

--
-- Name: spr_comms_p95; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_comms_p95 (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_comms_p95 OWNER TO gha_admin;

--
-- Name: spr_repapprappr; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_repapprappr (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/ibm-vpc-block-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/drivers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/sig-storage-lib-extern_not_null" NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/horizontal-self-scaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/kube-scheduler-simulat_not_null" NOT NULL,
    "kubernetes/cluster-registry" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-containerd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/aws-alb-ingress-contro_not_null" NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/apiserver-builder-alph_not_null" NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/aws-encryption-provide_not_null" NOT NULL,
    "kubernetes/security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-d_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/secrets-store-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/node-feature-discovery_not_null" NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-c_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/apiserver-network-prox_not_null" NOT NULL,
    "kubernetes-sigs/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-k_not_null" NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kpng" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/kube-scheduler-wasm-ex_not_null" NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/nfs-ganesha-server-and_not_null" NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/repo-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-docker" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-_not_null1" NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/features" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-storage" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/usage-metrics-collecto_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/gateway-api-inference-_not_null" NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-csi/volume-data-source-vali_not_null" NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kargo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-arbitrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alb-ingress-controller" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-o_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-g_not_null" NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/gcp-filestore-csi-driv_not_null" NOT NULL,
    "kubernetes-incubator/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minibroker" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-controller" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/container-object-stora_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-incubator/cluster-proportio_not_null" NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-csi/external-snapshot-metad_not_null" NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcdadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/sig-storage-local-stat_not_null" NOT NULL,
    "kubernetes-incubator/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-incubator/apiserver-builder_not_null" NOT NULL,
    "kubernetes-sigs/k8s-container-image-promoter" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/k8s-container-image-pr_not_null" NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/oci-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-addon-prov_not_null" NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/custom-metrics-apiserv_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-p_not_null" NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/kernel-module-manageme_not_null" NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/kubebuilder-declarativ_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-dev-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-deploy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-cn" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubefed" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/hierarchical-namespaces" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/hierarchical-namespace_not_null" NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 NOT NULL,
    "GoogleCloudPlatform/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/nfs-subdir-external-pr_not_null" NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/ibm-powervs-block-csi-_not_null" NOT NULL,
    "kubernetes/kubernetes.github.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/federation-v2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/frakti" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/alibaba-cloud-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-tweets" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blobfuse-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/ingress-controller-con_not_null" NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/special-resource-operator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/special-resource-opera_not_null" NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/gcp-compute-persistent_not_null" NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 NOT NULL,
    kubernetes double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-incubator/apiserver-builde_not_null1" NOT NULL,
    "kubernetes-incubator/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-incubator/custom-metrics-ap_not_null" NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/node-feature-discover_not_null1" NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/aws-load-balancer-cont_not_null" NOT NULL,
    "kubernetes-sigs/poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-tenancy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/llm-instance-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-apis" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-a_not_null" NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/federation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-_not_null2" NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cloud-provider-huaweic_not_null" NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-proportional-a_not_null" NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-incubator/node-feature-disc_not_null" NOT NULL,
    "kubernetes-incubator/kube-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes/cloud-provider-alibaba-clou_not_null" NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/security-profiles-oper_not_null" NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/kube-storage-version-m_not_null" NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-i_not_null" NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/addon-operators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/downloadkubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/provider-aws-test-infr_not_null" NOT NULL,
    "kubernetes-sigs/blixt" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/client-python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cloud-provider-equinix_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-bootstrap-_not_null" NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-v_not_null" NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-batch" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/seccomp-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-anywhere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubeadm-dind-cluster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/heapster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-nested" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/cluster-api-provider-n_not_null" NOT NULL,
    "kubernetes-sigs/aws_encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes-sigs/aws_encryption-provide_not_null" NOT NULL,
    "kubernetes-incubator/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprappr_kubernetes/cluster-proportional-autosc_not_null" NOT NULL,
    "kubernetes-sigs/volcano" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/relnotes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduling_poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apps_application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_repapprappr OWNER TO gha_admin;

--
-- Name: spr_repapprwait; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_repapprwait (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes/features" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-anywhere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 NOT NULL,
    "GoogleCloudPlatform/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/apiserver-builder-alph_not_null" NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/ibm-vpc-block-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-incubator/cluster-proportio_not_null" NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-i_not_null" NOT NULL,
    "kubernetes-incubator/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-arbitrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-incubator/node-feature-disc_not_null" NOT NULL,
    "kubernetes-incubator/apiserver-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-controller" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/container-object-stora_not_null" NOT NULL,
    "kubernetes-incubator/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/heapster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcdadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/kubebuilder-declarativ_not_null" NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/downloadkubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubeadm-dind-cluster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/ibm-powervs-block-csi-_not_null" NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes.github.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-registry" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-a_not_null" NOT NULL,
    "kubernetes-sigs/k8s-container-image-promoter" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/k8s-container-image-pr_not_null" NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/aws-load-balancer-cont_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/gcp-compute-persistent_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cloud-provider-huaweic_not_null" NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/secrets-store-csi-driv_not_null" NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-tenancy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blixt" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/client-python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/kube-storage-version-m_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-o_not_null" NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/nfs-ganesha-server-and_not_null" NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alb-ingress-controller" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-containerd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/addon-operators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-p_not_null" NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-g_not_null" NOT NULL,
    "kubernetes-incubator/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-incubator/apiserver-builde_not_null1" NOT NULL,
    "kubernetes-sigs/federation-v2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-dev-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/gateway-api-inference-_not_null" NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-k_not_null" NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-csi/external-snapshot-metad_not_null" NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blobfuse-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/security-profiles-oper_not_null" NOT NULL,
    "kubernetes-sigs/kpng" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/provider-aws-test-infr_not_null" NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/kube-scheduler-simulat_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-apis" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/node-feature-discover_not_null1" NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-csi/volume-data-source-vali_not_null" NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/usage-metrics-collecto_not_null" NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-nested" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-n_not_null" NOT NULL,
    "kubernetes/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-proportional-a_not_null" NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/llm-instance-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-incubator/custom-metrics-ap_not_null" NOT NULL,
    "kubernetes-sigs/hierarchical-namespaces" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/hierarchical-namespace_not_null" NOT NULL,
    kubernetes double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-batch" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/nfs-subdir-external-pr_not_null" NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/kernel-module-manageme_not_null" NOT NULL,
    "kubernetes-incubator/external-storage" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/apiserver-network-prox_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-addon-prov_not_null" NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/sig-storage-lib-extern_not_null" NOT NULL,
    "kubernetes-incubator/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/special-resource-operator" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/special-resource-opera_not_null" NOT NULL,
    "kubernetes-sigs/oci-proxy" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/federation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minibroker" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/gcp-filestore-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/aws-encryption-provide_not_null" NOT NULL,
    "kubernetes-sigs/aws-alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/aws-alb-ingress-contro_not_null" NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-_not_null1" NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/horizontal-self-scaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/custom-metrics-apiserv_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-v_not_null" NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/sig-storage-local-stat_not_null" NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-bootstrap-_not_null" NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/alibaba-cloud-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/kube-scheduler-wasm-ex_not_null" NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubefed" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/ingress-controller-con_not_null" NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-deploy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cloud-provider-equinix_not_null" NOT NULL,
    "kubernetes-incubator/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-d_not_null" NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/frakti" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-cn" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/seccomp-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kargo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/repo-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/drivers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-docker" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-_not_null2" NOT NULL,
    "kubernetes-sigs/contributor-tweets" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes/cloud-provider-alibaba-clou_not_null" NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/cluster-api-provider-c_not_null" NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes/cluster-proportional-autosc_not_null" NOT NULL,
    "kubernetes-sigs/volcano" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws_encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spr_repapprwait_kubernetes-sigs/aws_encryption-provide_not_null" NOT NULL,
    "kubernetes/kubernetes-console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/relnotes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduling_poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apps_application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_repapprwait OWNER TO gha_admin;

--
-- Name: spr_workload_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spr_workload_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spr_workload_repos OWNER TO gha_admin;

--
-- Name: sprblckall; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprblckall (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprblckall OWNER TO gha_admin;

--
-- Name: sprblckdo_not_merge; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprblckdo_not_merge (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 CONSTRAINT "sprblckdo_not_merge_SIG Cluster Lifecycle (Cluster API_not_null" NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprblckdo_not_merge OWNER TO gha_admin;

--
-- Name: sprblckneeds_ok_to_test; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprblckneeds_ok_to_test (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 CONSTRAINT "sprblckneeds_ok_to_test_SIG Cluster Lifecycle (Cluster_not_null" NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprblckneeds_ok_to_test OWNER TO gha_admin;

--
-- Name: sprblckno_approve; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprblckno_approve (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprblckno_approve OWNER TO gha_admin;

--
-- Name: sprblckno_lgtm; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprblckno_lgtm (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprblckno_lgtm OWNER TO gha_admin;

--
-- Name: sprblckrelease_note_label_needed; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprblckrelease_note_label_needed (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "SIG Instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "SIG Testing" double precision DEFAULT 0.0 NOT NULL,
    "SIG Node" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scalability" double precision DEFAULT 0.0 NOT NULL,
    "SIG Service Catalog" double precision DEFAULT 0.0 NOT NULL,
    "SIG Network" double precision DEFAULT 0.0 NOT NULL,
    "Steering Committee" double precision DEFAULT 0.0 NOT NULL,
    "SIG Scheduling" double precision DEFAULT 0.0 NOT NULL,
    "SIG API Machinery" double precision DEFAULT 0.0 NOT NULL,
    "SIG CLI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Multicluster" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle (Cluster API)" double precision DEFAULT 0.0 CONSTRAINT "sprblckrelease_note_label_n_SIG Cluster Lifecycle (Clu_not_null" NOT NULL,
    "SIG Auth" double precision DEFAULT 0.0 NOT NULL,
    "Other" double precision DEFAULT 0.0 NOT NULL,
    "SIG Apps" double precision DEFAULT 0.0 NOT NULL,
    "SIG Docs" double precision DEFAULT 0.0 NOT NULL,
    "SIG Contributor Experience" double precision DEFAULT 0.0 CONSTRAINT "sprblckrelease_note_label_n_SIG Contributor Experience_not_null" NOT NULL,
    "SIG Storage" double precision DEFAULT 0.0 NOT NULL,
    "SIG Autoscaling" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "SIG UI" double precision DEFAULT 0.0 NOT NULL,
    "SIG Architecture" double precision DEFAULT 0.0 NOT NULL,
    "SIG Release" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cloud Provider" double precision DEFAULT 0.0 NOT NULL,
    "SIG Windows" double precision DEFAULT 0.0 NOT NULL,
    "Product Security Committee" double precision DEFAULT 0.0 CONSTRAINT "sprblckrelease_note_label_n_Product Security Committee_not_null" NOT NULL,
    "Kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "SIG Cluster Lifecycle" double precision DEFAULT 0.0 NOT NULL,
    "SIG Usability" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprblckrelease_note_label_needed OWNER TO gha_admin;

--
-- Name: spreprblckall; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spreprblckall (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes-incubator/apiserver-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-csi/volume-data-source-valida_not_null" NOT NULL,
    "kubernetes/repo-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubefed" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/gateway-api-inference-ex_not_null" NOT NULL,
    "kubernetes-sigs/testgrid" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-nested" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-nes_not_null" NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/features" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/system-validators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-proportional-aut_not_null" NOT NULL,
    "kubernetes-sigs/provider-ibmcloud-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/provider-ibmcloud-test-i_not_null" NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/aws-alb-ingress-controll_not_null" NOT NULL,
    "kubernetes-csi/drivers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-bootstrap-pr_not_null" NOT NULL,
    "kubernetes-sigs/cosi-driver-sample" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/verify-conformance" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kargo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/helm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-proportional-ver_not_null" NOT NULL,
    "kubernetes-sigs/windows-operational-readiness" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/windows-operational-read_not_null" NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/nfs-subdir-external-prov_not_null" NOT NULL,
    "kubernetes-sigs/multicluster-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-incubator/apiserver-builder-a_not_null" NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/client-go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blobfuse-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kpng" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/sig-storage-local-static_not_null" NOT NULL,
    "kubernetes-sigs/mdtoc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/container-object-storage_not_null" NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-containerd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-network" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/federation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-registry" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/node-feature-discovery-o_not_null" NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apisnoop" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/heapster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation-addons" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-clo_not_null" NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcdadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/kubernetes-csi-migration-library" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-csi/kubernetes-csi-migration-_not_null" NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/aws-load-balancer-contro_not_null" NOT NULL,
    "kubernetes-sigs/wg-device-management" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-cluster-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/karpenter-provider-clust_not_null" NOT NULL,
    "kubernetes-incubator/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/frakti" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-incubator/node-feature-discov_not_null" NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/cluster-driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-serving" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/network-policy-finalizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-anywhere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes.github.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-apis" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cloud-provider-huaweiclo_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-docker" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-doc_not_null" NOT NULL,
    "kubernetes-incubator/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/about-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/kubebuilder-release-tool_not_null" NOT NULL,
    "kubernetes-sigs/seccomp-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubemark" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-kub_not_null" NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/ibm-powervs-block-csi-dr_not_null" NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/hierarchical-namespaces" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/nfs-ganesha-server-and-e_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-ipam-provider-in-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-ipam-provide_not_null" NOT NULL,
    "kubernetes-sigs/cluster-inventory-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/k8s-container-image-promoter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/k8s-container-image-prom_not_null" NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/container-object-storag_not_null1" NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/knftables" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-csi/external-snapshot-metadat_not_null" NOT NULL,
    "kubernetes-sigs/cni-dra-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/client-python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-dig_not_null" NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-ibm_not_null" NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/depstat" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/nfs-provisioner" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-dev-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gwctl" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-deploy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/kubebuilder-declarative-_not_null" NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/sig-storage-lib-external_not_null" NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/kube-scheduler-wasm-exte_not_null" NOT NULL,
    "kubernetes-sigs/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-azu_not_null" NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-batch" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dashboard-metrics-scraper" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/dashboard-metrics-scrape_not_null" NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/kube-storage-version-mig_not_null" NOT NULL,
    "kubernetes-sigs/gluster-file-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/gluster-file-external-pr_not_null" NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/security-profiles-operat_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-pac_not_null" NOT NULL,
    "kubernetes-sigs/sig-multicluster-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-storage" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-tenancy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-tweets" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/ingress-controller-confo_not_null" NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cloud-provider-equinix-m_not_null" NOT NULL,
    "kubernetes-sigs/blixt" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-vsp_not_null" NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/container-object-storag_not_null2" NOT NULL,
    "kubernetes-sigs/federation-v2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubeadm-dind-cluster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurelustre-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-sync-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/secrets-store-sync-contr_not_null" NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/charts" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testing_frameworks" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minikube-gui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-bootcamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/downloadkubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/community-images" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/oci-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-addon-provid_not_null" NOT NULL,
    "kubernetes-sigs/crdify" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "GoogleCloudPlatform/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-ku_not_null1" NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/work-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-csi-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/container-object-storag_not_null3" NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 NOT NULL,
    kubernetes double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/ruby" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/gcp-compute-persistent-d_not_null" NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/legacyflag" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cluster-api-provider-ope_not_null" NOT NULL,
    "kubernetes-sigs/minibroker" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubedash" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krm-functions-registry" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/go-open-service-broker-client" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/go-open-service-broker-c_not_null" NOT NULL,
    "kubernetes-sigs/special-resource-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/special-resource-operato_not_null" NOT NULL,
    "kubernetes/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nat64" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/logtools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/pspmigrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-template-project" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-fsx-openzfs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/aws-fsx-openzfs-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/maintainers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-ipam-controller" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-incubator/cluster-proportiona_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-nvmf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-ibm-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/karpenter-provider-ibm-c_not_null" NOT NULL,
    "kubernetes/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-ai-conformance" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcd-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kindnet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-flex" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-arbitrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-spec" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/container-object-storag_not_null4" NOT NULL,
    "kubernetes-sigs/ingate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gluster-block-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/gluster-block-external-p_not_null" NOT NULL,
    "kubernetes-sigs/json" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-actions" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/funding" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-driver-topology" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-agentic-networking" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-sample" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubectl-check-ownerreferences" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/kubectl-check-ownerrefer_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-baiducloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/cloud-provider-baiduclou_not_null" NOT NULL,
    "kubernetes/kubernetes-docs-cn" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/pr-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-fibre-channel" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-ja" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubernetes-docs-ko" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/slack-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-incubator/cluster-proportion_not_null1" NOT NULL,
    "kubernetes-sig-testing/frameworks" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-incubator/custom-metrics-apis_not_null" NOT NULL,
    "kubernetes-csi/kubernetes-csi.github.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-ko" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/addon-operators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/referencegrant-poc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/llm-instance-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubernetes-docs-ja" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/perl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testgrid-json-exporter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/volcano" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-team-shadow-stats" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/release-team-shadow-stat_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-image-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-csi/csi-driver-image-populato_not_null" NOT NULL,
    "kubernetes-sigs/wg-ai-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-usability" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/application-images" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/iptables-wrappers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/obscli" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cve-feed-osv" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/externalip-webhook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/typescript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/porche" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-security/cvelist-public" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/relnotes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/spartakus" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-service-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-bootstrap" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-file-cache-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/aws-file-cache-csi-drive_not_null" NOT NULL,
    "kubernetes/kms" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/k8s-gsm-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-mesos-framework" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-incubator/kube-mesos-framewor_not_null" NOT NULL,
    "kubernetes/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/logical-cluster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-fc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-katacoda" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/noderesourcetopology-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mutating-trace-admission-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/mutating-trace-admission_not_null" NOT NULL,
    "kubernetes-sigs/instrumentation-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-driver-cpu" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sigs-github-actions" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/common" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/signalhound" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-readiness-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes-sigs/node-readiness-controlle_not_null" NOT NULL,
    "kubernetes-sigs/maintainer-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/architecture-tracking" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/component-helpers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dranet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/testing_frameworks" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/execution-hook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/discuss-theme" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cel-admission-webhook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/csi-translation-lib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minikube-preloads" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/component-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-auth-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckall_kubernetes/cluster-proportional-autoscal_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-samples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/legacy-cloud-providers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/mount-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/controller-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/resources" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cri-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduling_poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/clientgofix" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alb-ingress-controller" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/horizontal-self-scaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/randfill" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/foo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws_encryption-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apps_application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-network-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cosi-driver-minio" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-graveyard/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/md-format" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spreprblckall OWNER TO gha_admin;

--
-- Name: spreprblckdo_not_merge; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spreprblckdo_not_merge (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/ibm-powervs-blo_not_null" NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-sync-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/secrets-store-s_not_null" NOT NULL,
    "kubernetes/repo-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/provider-ibmcloud-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/provider-ibmclo_not_null" NOT NULL,
    "kubernetes-sigs/aws-alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-alb-ingress_not_null" NOT NULL,
    "kubernetes-incubator/kube-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/reference-docs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/reference-_not_null" NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-efs-csi-dri_not_null" NOT NULL,
    "kubernetes-sigs/kube-batch" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/ip-masq-agent" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/ip-masq-ag_not_null" NOT NULL,
    "kubernetes-sigs/community-images" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/community-image_not_null" NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/network-policy-finalizer" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/network-policy-_not_null" NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kube-network-po_not_null" NOT NULL,
    "kubernetes/ingress" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/cloud-provider-aliba_not_null" NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/network-policy_not_null1" NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/alibaba-cloud-c_not_null" NOT NULL,
    "kubernetes-client/ruby" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kubectl-validat_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-ipam-provider-in-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-ipa_not_null" NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/security-profil_not_null" NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-device-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/wg-device-manag_not_null" NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/features" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/apiserver-_not_null" NOT NULL,
    "kubernetes-csi/drivers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pro_not_null" NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-inventory-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-invento_not_null" NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/descheduler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/deschedule_not_null" NOT NULL,
    "kubernetes/federation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/apiserver_not_null1" NOT NULL,
    "kubernetes-sigs/minikube-gui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/ibm-vpc-block-c_not_null" NOT NULL,
    "GoogleCloudPlatform/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-apis" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/vsphere-csi-dri_not_null" NOT NULL,
    "kubernetes-sigs/downloadkubernetes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/downloadkuberne_not_null" NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/gcp-compute-per_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null1" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/container-objec_not_null" NOT NULL,
    "kubernetes-sigs/crdify" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/secrets-store-c_not_null" NOT NULL,
    "kubernetes-sigs/apiserver-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/apiserver-runti_not_null" NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/dra-example-dri_not_null" NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testgrid" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-ope_not_null" NOT NULL,
    "kubernetes/kube-deploy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/structured-merg_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null2" NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kernel-module-m_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/gateway-api-inf_not_null" NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blobfuse-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/blobfuse-csi-dr_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null3" NOT NULL,
    "kubernetes-sigs/blixt" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-tenancy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/contributor-sit_not_null" NOT NULL,
    "kubernetes-sigs/contributor-tweets" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/contributor-twe_not_null" NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null4" NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/nfs-ganesha-ser_not_null" NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/knftables" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kpng" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/controller-runt_not_null" NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/external-attache_not_null" NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/cloud-provider-opens_not_null" NOT NULL,
    "kubernetes-sigs/hierarchical-namespaces" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/hierarchical-na_not_null" NOT NULL,
    "kubernetes-sigs/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-dns" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/external-d_not_null" NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/node-feature-di_not_null" NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-add_not_null" NOT NULL,
    "kubernetes/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/service-catalog" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/service-ca_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null5" NOT NULL,
    "kubernetes-sigs/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/prometheus-adap_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cloud-provider-_not_null" NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/frakti" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation-addons" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/instrumentation_not_null" NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null6" NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/ingress-control_not_null" NOT NULL,
    "kubernetes-sigs/multi-network" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kargo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null7" NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kube-scheduler-_not_null" NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/provider-aws-te_not_null" NOT NULL,
    "kubernetes/kubernetes.github.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/node-featu_not_null" NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/system-validators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/apiserver-build_not_null" NOT NULL,
    "kubernetes-sigs/minibroker" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/kubernetes-csi-migration-library" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/kubernetes-csi-m_not_null" NOT NULL,
    "kubernetes-sigs/kui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/client-go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/csi-driver-host-_not_null" NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/csi-release-tool_not_null" NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-load-balanc_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null8" NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/volume-data-sour_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cloud-provider_not_null1" NOT NULL,
    "kubernetes-sigs/cni-dra-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/lib-volume-popul_not_null" NOT NULL,
    "kubernetes/kubernetes-anywhere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/node-problem-detecto_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-registry" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/scheduler-plugi_not_null" NOT NULL,
    "kubernetes-incubator/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/container-obje_not_null1" NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/usage-metrics-c_not_null" NOT NULL,
    "kubernetes-sigs/wg-serving" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/metrics-server" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/metrics-se_not_null" NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/committee-security-r_not_null" NOT NULL,
    "kubernetes-sigs/windows-operational-readiness" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/windows-operati_not_null" NOT NULL,
    "kubernetes/kubernetes-bootcamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-containerd" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/cri-contai_not_null" NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/azurefile-csi-d_not_null" NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-proport_not_null" NOT NULL,
    "kubernetes-sigs/about-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-storage" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/external-s_not_null" NOT NULL,
    "kubernetes-sigs/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/testing_framewo_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-docker" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-pr_not_null9" NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/sig-storage-loc_not_null" NOT NULL,
    "kubernetes-sigs/seccomp-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/seccomp-operato_not_null" NOT NULL,
    "kubernetes-sigs/gwctl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/legacyflag" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-boo_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kubebuilder-dec_not_null" NOT NULL,
    "kubernetes-incubator/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/federation-v2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/sig-storage-lib_not_null" NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-multicluster-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/sig-multicluste_not_null" NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/wg-policy-proto_not_null" NOT NULL,
    "kubernetes-csi/driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/cluster-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/cluster-driver-r_not_null" NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/azuredisk-csi-d_not_null" NOT NULL,
    "kubernetes/heapster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcdadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mdtoc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/nfs-subdir-exte_not_null" NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multicluster-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/multicluster-ru_not_null" NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kube-storage-ve_not_null" NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-fsx-csi-dri_not_null" NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cli-experimenta_not_null" NOT NULL,
    "kubernetes-sigs/work-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/container-obje_not_null2" NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/node-driver-regi_not_null" NOT NULL,
    kubernetes double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubeadm-dind-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kubeadm-dind-cl_not_null" NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/external-health-_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cloud-provider_not_null2" NOT NULL,
    "kubernetes-sigs/apisnoop" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-p_not_null10" NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/gcp-filestore-c_not_null" NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/oci-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/custom-metrics-_not_null" NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/external-snapsho_not_null" NOT NULL,
    "kubernetes-sigs/karpenter-provider-cluster-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/karpenter-provi_not_null" NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubefed" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/depstat" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-encryption-_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-nested" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-p_not_null11" NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kube-scheduler_not_null1" NOT NULL,
    "kubernetes-sigs/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-propor_not_null1" NOT NULL,
    "kubernetes-sigs/azurelustre-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/azurelustre-csi_not_null" NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/client-python" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/client-pyt_not_null" NOT NULL,
    "kubernetes-sigs/poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/apiserver-netwo_not_null" NOT NULL,
    "kubernetes-sigs/dashboard-metrics-scraper" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/dashboard-metri_not_null" NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gluster-file-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/gluster-file-ex_not_null" NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/contributor-pla_not_null" NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-ebs-csi-dri_not_null" NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/controller-tool_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/charts" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/helm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cloud-provider_not_null3" NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/node-feature-d_not_null1" NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cosi-driver-sample" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cosi-driver-sam_not_null" NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/nfs-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/nfs-provis_not_null" NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/external-snapsh_not_null1" NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/external-provisi_not_null" NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-iam-authent_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kubebuilder-rel_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubemark" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-api-p_not_null12" NOT NULL,
    "kubernetes-sigs/verify-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/verify-conforma_not_null" NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/cloud-provider-vsphe_not_null" NOT NULL,
    "kubernetes-sigs/k8s-container-image-promoter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/k8s-container-i_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-dev-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/sig-windows-dev_not_null" NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-csi-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/container-obje_not_null3" NOT NULL,
    "kubernetes-incubator/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-fsx-openzfs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-fsx-openzfs_not_null" NOT NULL,
    "kubernetes-sigs/node-ipam-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/node-ipam-contr_not_null" NOT NULL,
    "kubernetes-sigs/krm-functions-registry" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/krm-functions-r_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/sig-windows-too_not_null" NOT NULL,
    "kubernetes-incubator/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/cluster-pr_not_null" NOT NULL,
    "kubernetes/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/maintainers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/go-open-service-broker-client" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/go-open-service_not_null" NOT NULL,
    "kubernetes/kubernetes-template-project" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/kubernetes-template-_not_null" NOT NULL,
    "kubernetes/kubedash" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cluster-capacit_not_null" NOT NULL,
    "kubernetes-sigs/special-resource-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/special-resourc_not_null" NOT NULL,
    "kubernetes-sigs/nat64" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/pspmigrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcd-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nvmf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-ibm-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/karpenter-prov_not_null1" NOT NULL,
    "kubernetes-sigs/logtools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kindnet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-ai-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/wg-ai-conforman_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-zh" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-retired/kubernetes-d_not_null" NOT NULL,
    "kubernetes-incubator/kube-arbitrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/kube-arbit_not_null" NOT NULL,
    "kubernetes/funding" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-baiducloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cloud-provider_not_null4" NOT NULL,
    "kubernetes-sigs/gluster-block-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/gluster-block-e_not_null" NOT NULL,
    "kubernetes-sigs/json" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-spec" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/container-obje_not_null4" NOT NULL,
    "kubernetes-sigs/kube-agentic-networking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kube-agentic-ne_not_null" NOT NULL,
    "kubernetes/pr-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-flex" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-fibre-channel" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/csi-driver-fibre_not_null" NOT NULL,
    "kubernetes-sigs/release-actions" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-cn" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubectl-check-ownerreferences" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/kubectl-check-o_not_null" NOT NULL,
    "kubernetes/cloud-provider-sample" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/cloud-provider-sampl_not_null" NOT NULL,
    "kubernetes-sigs/dra-driver-topology" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/dra-driver-topo_not_null" NOT NULL,
    "kubernetes-sigs/ingate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/cluster-p_not_null1" NOT NULL,
    "kubernetes-sigs/referencegrant-poc" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/referencegrant-_not_null" NOT NULL,
    "kubernetes-sigs/volcano" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testgrid-json-exporter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/testgrid-json-e_not_null" NOT NULL,
    "kubernetes-incubator/cluster-capacity" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/cluster-ca_not_null" NOT NULL,
    "kubernetes-sig-testing/frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sig-testing/framewor_not_null" NOT NULL,
    "kubernetes-incubator/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/custom-met_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-ko" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-retired/kubernetes-_not_null1" NOT NULL,
    "kubernetes-sigs/release-team-shadow-stats" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/release-team-sh_not_null" NOT NULL,
    "kubernetes-sigs/slack-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/kubernetes-csi.github.io" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/kubernetes-csi.g_not_null" NOT NULL,
    "kubernetes-client/perl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/llm-instance-gateway" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/llm-instance-ga_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-ja" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-retired/kubernetes-_not_null2" NOT NULL,
    "kubernetes/kubernetes-docs-ja" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-ko" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/addon-operators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-usability" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/iptables-wrappers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/iptables-wrappe_not_null" NOT NULL,
    "kubernetes-sigs/obscli" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/externalip-webhook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/externalip-webh_not_null" NOT NULL,
    "kubernetes-sigs/wg-ai-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/application-images" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-image-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-csi/csi-driver-image_not_null" NOT NULL,
    "kubernetes-sigs/cve-feed-osv" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/spartakus" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-service-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/windows-service_not_null" NOT NULL,
    "kubernetes-sigs/relnotes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/typescript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/k8s-gsm-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/porche" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-security/cvelist-public" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-security/cvelist-pub_not_null" NOT NULL,
    "kubernetes/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-mesos-framework" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-incubator/kube-mesos_not_null" NOT NULL,
    "kubernetes/cluster-bootstrap" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-file-cache-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws-file-cache-_not_null" NOT NULL,
    "kubernetes/kms" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/noderesourcetopology-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/noderesourcetop_not_null" NOT NULL,
    "kubernetes-csi/csi-lib-fc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-katacoda" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/contributor-kat_not_null" NOT NULL,
    "kubernetes-sigs/logical-cluster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/instrumentatio_not_null1" NOT NULL,
    "kubernetes-sigs/mutating-trace-admission-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/mutating-trace-_not_null" NOT NULL,
    "kubernetes-client/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-driver-cpu" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/signalhound" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/common" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-readiness-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/node-readiness-_not_null" NOT NULL,
    "kubernetes-sigs/maintainer-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/maintainer-tool_not_null" NOT NULL,
    "kubernetes-sigs/sigs-github-actions" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/sigs-github-act_not_null" NOT NULL,
    "kubernetes-retired/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-retired/testing_fram_not_null" NOT NULL,
    "kubernetes-sigs/architecture-tracking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/architecture-tr_not_null" NOT NULL,
    "kubernetes/component-helpers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dranet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/execution-hook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cel-admission-webhook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/cel-admission-webhoo_not_null" NOT NULL,
    "kubernetes-sigs/discuss-theme" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-auth-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/component-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/csi-translation-lib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minikube-preloads" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/minikube-preloa_not_null" NOT NULL,
    "kubernetes-sigs/instrumentation" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/instrumentatio_not_null2" NOT NULL,
    "kubernetes-sigs/sig-windows-samples" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/sig-windows-sam_not_null" NOT NULL,
    "kubernetes/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/cluster-proportional_not_null" NOT NULL,
    "kubernetes/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/mount-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/legacy-cloud-providers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/legacy-cloud-provide_not_null" NOT NULL,
    "kubernetes/controller-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/resources" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cri-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduling_poseidon" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/scheduling_pose_not_null" NOT NULL,
    "kubernetes-sigs/clientgofix" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/randfill" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/alb-ingress-con_not_null" NOT NULL,
    "kubernetes/horizontal-self-scaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes/horizontal-self-scal_not_null" NOT NULL,
    "kubernetes-sigs/foo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws_encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/aws_encryption-_not_null" NOT NULL,
    "kubernetes-sigs/apps_application" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/apps_applicatio_not_null" NOT NULL,
    "kubernetes-sigs/multi-network-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/multi-network-a_not_null" NOT NULL,
    "kubernetes-sigs/cosi-driver-minio" double precision DEFAULT 0.0 CONSTRAINT "spreprblckdo_not_merge_kubernetes-sigs/cosi-driver-min_not_null" NOT NULL,
    "kubernetes-graveyard/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/md-format" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spreprblckdo_not_merge OWNER TO gha_admin;

--
-- Name: spreprblckneeds_ok_to_test; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spreprblckneeds_ok_to_test (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/node-driver-_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-csi-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/container-o_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/custom-metr_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/gateway-api_not_null" NOT NULL,
    "kubernetes-sigs/provider-ibmcloud-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/provider-ib_not_null" NOT NULL,
    "kubernetes/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cloud-provider-v_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null1" NOT NULL,
    "kubernetes-sigs/k8s-container-image-promoter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/k8s-contain_not_null" NOT NULL,
    "kubernetes-sigs/etcdadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/prometheus-_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null2" NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/wg-policy-p_not_null" NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurelustre-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/azurelustre_not_null" NOT NULL,
    "kubernetes-sigs/knftables" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/metrics-server" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/metric_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-nested" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null3" NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/client-go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/windows-tes_not_null" NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/release-not_not_null" NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-operational-readiness" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/windows-ope_not_null" NOT NULL,
    "kubernetes-sigs/kubeadm-dind-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kubeadm-din_not_null" NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-encrypt_not_null" NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/provider-aw_not_null" NOT NULL,
    "kubernetes-sigs/wg-device-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/wg-device-m_not_null" NOT NULL,
    "kubernetes-incubator/service-catalog" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/servic_not_null" NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cloud-provi_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-driver-h_not_null" NOT NULL,
    "kubernetes-sigs/multi-network" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/multi-netwo_not_null" NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null4" NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/contributor_not_null" NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-pro_not_null" NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-sync-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/secrets-sto_not_null" NOT NULL,
    "kubernetes-sigs/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-driver-s_not_null" NOT NULL,
    "kubernetes-sigs/seccomp-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/seccomp-ope_not_null" NOT NULL,
    "kubernetes-incubator/reference-docs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/refere_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cloud-prov_not_null1" NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cloud-provider-g_not_null" NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/external-pro_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cloud-prov_not_null2" NOT NULL,
    "kubernetes-sigs/mdtoc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minibroker" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kube-networ_not_null" NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/bootkube" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/bootku_not_null" NOT NULL,
    "kubernetes-sigs/kubefed" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/legacyflag" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/release-uti_not_null" NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/ingress2gat_not_null" NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/secrets-st_not_null1" NOT NULL,
    "kubernetes-sigs/downloadkubernetes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/downloadkub_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null5" NOT NULL,
    "kubernetes-sigs/minikube-gui" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/minikube-gu_not_null" NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kubectl-val_not_null" NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-client/javascrip_not_null" NOT NULL,
    "kubernetes-incubator/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/apiser_not_null" NOT NULL,
    "kubernetes/frakti" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/node-f_not_null" NOT NULL,
    "kubernetes/federation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/nfs-subdir-_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/network-pol_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null6" NOT NULL,
    "kubernetes-sigs/crdify" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/depstat" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/external-sna_not_null" NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null7" NOT NULL,
    "kubernetes-sigs/contributor-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/contributo_not_null1" NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/apiserver-b_not_null" NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-deploy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/apise_not_null1" NOT NULL,
    "kubernetes-incubator/cri-containerd" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/cri-co_not_null" NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/livenessprob_not_null" NOT NULL,
    "kubernetes-sigs/kube-batch" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kube-storag_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null8" NOT NULL,
    "kubernetes-sigs/apiserver-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/apiserver-r_not_null" NOT NULL,
    "kubernetes-sigs/service-catalog" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/service-cat_not_null" NOT NULL,
    "kubernetes-incubator/cri-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/cri-to_not_null" NOT NULL,
    "kubernetes-sigs/federation-v2" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/federation-_not_null" NOT NULL,
    "kubernetes-incubator/ip-masq-agent" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/ip-mas_not_null" NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sig-storage_not_null" NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-fsx-csi_not_null" NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gwctl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kargo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/charts" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/ip-masq-age_not_null" NOT NULL,
    "kubernetes/features" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/client-python" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/client_not_null" NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/controller-_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kubebuilder_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kubebuilde_not_null1" NOT NULL,
    "kubernetes-sigs/cosi-driver-sample" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cosi-driver_not_null" NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/external-hea_not_null" NOT NULL,
    "kubernetes-incubator/nfs-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/nfs-pr_not_null" NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-ipam-provider-in-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-ap_not_null9" NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cloud-provider-o_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-docker" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-a_not_null10" NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kernel-modu_not_null" NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kube-schedu_not_null" NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/ingress-con_not_null" NOT NULL,
    "kubernetes-sigs/apisnoop" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-release-_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-a_not_null11" NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-alb-ing_not_null" NOT NULL,
    "kubernetes-sigs/kpng" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/community-images" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/community-i_not_null" NOT NULL,
    "kubernetes/ingress" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/apiserver-n_not_null" NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/container-_not_null1" NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/usage-metri_not_null" NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kompose" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/kompos_not_null" NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/system-validators" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/system-validator_not_null" NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/vsphere-csi_not_null" NOT NULL,
    "kubernetes-sigs/instrumentation-addons" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/instrumenta_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/container-_not_null2" NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sig-storag_not_null1" NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/alibaba-clo_not_null" NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/security-pr_not_null" NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/e2e-framewo_not_null" NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multicluster-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/multicluste_not_null" NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 NOT NULL,
    kubernetes double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/drivers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/cluster-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/cluster-driv_not_null" NOT NULL,
    "kubernetes-csi/driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/driver-regis_not_null" NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/ibm-powervs_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/container-_not_null3" NOT NULL,
    "kubernetes/kubernetes-bootcamp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes-bootc_not_null" NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/controller_not_null1" NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-iam-aut_not_null" NOT NULL,
    "kubernetes-sigs/gluster-file-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/gluster-fil_not_null" NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-a_not_null12" NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/azurefile-c_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/gateway-ap_not_null1" NOT NULL,
    "kubernetes-sigs/multi-tenancy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/multi-tenan_not_null" NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/about-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blixt" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-inventory-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-inv_not_null" NOT NULL,
    "kubernetes-sigs/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/testing_fra_not_null" NOT NULL,
    "kubernetes-sigs/dashboard-metrics-scraper" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/dashboard-m_not_null" NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/windows-gms_not_null" NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-load-ba_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-driver-n_not_null" NOT NULL,
    "kubernetes-sigs/sig-multicluster-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sig-multicl_not_null" NOT NULL,
    "kubernetes-client/ruby" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-cluster-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/karpenter-p_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kubebuilde_not_null2" NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/gcp-filesto_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-dev-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sig-windows_not_null" NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/ibm-vpc-blo_not_null" NOT NULL,
    "kubernetes-sigs/testgrid" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/lib-volume-p_not_null" NOT NULL,
    "kubernetes-incubator/kube-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/kube-a_not_null" NOT NULL,
    "kubernetes/cluster-registry" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/node-featur_not_null" NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/volume-data-_not_null" NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/inference-p_not_null" NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kube-state-metri_not_null" NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-add_not_null" NOT NULL,
    "kubernetes-sigs/contributor-tweets" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/contributo_not_null2" NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kube-sched_not_null1" NOT NULL,
    "kubernetes-sigs/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-pr_not_null1" NOT NULL,
    "kubernetes-client/python-base" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-client/python-ba_not_null" NOT NULL,
    "GoogleCloudPlatform/kubernetes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_GoogleCloudPlatform/kuberne_not_null" NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/blob-csi-dr_not_null" NOT NULL,
    "kubernetes-sigs/cni-dra-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cni-dra-dri_not_null" NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/metrics-ser_not_null" NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-ebs-csi_not_null" NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/node-problem-det_not_null" NOT NULL,
    "kubernetes-incubator/external-dns" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/extern_not_null" NOT NULL,
    "kubernetes-sigs/poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/gcp-compute_not_null" NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cloud-provider-a_not_null" NOT NULL,
    "kubernetes-sigs/verify-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/verify-conf_not_null" NOT NULL,
    "kubernetes-csi/csi-lib-iscsi" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-lib-iscs_not_null" NOT NULL,
    "kubernetes-incubator/external-storage" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/exter_not_null1" NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/hierarchical-namespaces" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/hierarchica_not_null" NOT NULL,
    "kubernetes-incubator/kubespray" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/kubesp_not_null" NOT NULL,
    "kubernetes/helm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/scheduler-p_not_null" NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cli-experim_not_null" NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/agent-sandb_not_null" NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kube-api-li_not_null" NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/azuredisk-c_not_null" NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/image-build_not_null" NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-apis" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/service-api_not_null" NOT NULL,
    "kubernetes-sigs/work-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cloud-prov_not_null3" NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/external-att_not_null" NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/dra-example_not_null" NOT NULL,
    "kubernetes/kubernetes-anywhere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes-anywh_not_null" NOT NULL,
    "kubernetes/repo-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/node-featu_not_null1" NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-lib-util_not_null" NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/external-res_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-driver-i_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-finalizer" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/network-po_not_null1" NOT NULL,
    "kubernetes-csi/kubernetes-csi-migration-library" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/kubernetes-c_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-a_not_null13" NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-efs-csi_not_null" NOT NULL,
    "kubernetes-sigs/blobfuse-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/blobfuse-cs_not_null" NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/nfs-ganesha_not_null" NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/heapster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/structured-_not_null" NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/descheduler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/desche_not_null" NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/external-dn_not_null" NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubemark" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-a_not_null14" NOT NULL,
    "kubernetes-sigs/wg-serving" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-a_not_null15" NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-a_not_null16" NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/oci-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/reference-d_not_null" NOT NULL,
    "kubernetes/kubernetes.github.io" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes.githu_not_null" NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cloud-provider-_not_null1" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-a_not_null17" NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/committee-securi_not_null" NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/external-sn_not_null1" NOT NULL,
    "kubernetes/cloud-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cloud-provider-_not_null2" NOT NULL,
    "kubernetes-sigs/node-ipam-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/node-ipam-c_not_null" NOT NULL,
    "kubernetes-sigs/nat64" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubedash" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/go-open-service-broker-client" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/go-open-ser_not_null" NOT NULL,
    "kubernetes-incubator/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/cluste_not_null" NOT NULL,
    "kubernetes-sigs/wg-ai-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/wg-ai-confo_not_null" NOT NULL,
    "kubernetes-sigs/kindnet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/logtools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krm-functions-registry" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/krm-functio_not_null" NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cluster-cap_not_null" NOT NULL,
    "kubernetes-sigs/karpenter-provider-ibm-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/karpenter-_not_null1" NOT NULL,
    "kubernetes-csi/csi-driver-nvmf" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-driver-_not_null1" NOT NULL,
    "kubernetes/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcd-manager" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/etcd-manage_not_null" NOT NULL,
    "kubernetes/kubernetes-docs-zh" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes-docs-_not_null" NOT NULL,
    "kubernetes-sigs/aws-fsx-openzfs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-fsx-ope_not_null" NOT NULL,
    "kubernetes-sigs/pspmigrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/maintainers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-template-project" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes-templ_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sig-window_not_null1" NOT NULL,
    "kubernetes-sigs/special-resource-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/special-res_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-flex" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-driver-f_not_null" NOT NULL,
    "kubernetes-sigs/dra-driver-topology" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/dra-driver-_not_null" NOT NULL,
    "kubernetes-sigs/gluster-block-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/gluster-blo_not_null" NOT NULL,
    "kubernetes-sigs/json" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubernetes-docs-zh" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-retired/kubernet_not_null" NOT NULL,
    "kubernetes/pr-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-arbitrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/kube-_not_null1" NOT NULL,
    "kubernetes-sigs/release-actions" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/release-act_not_null" NOT NULL,
    "kubernetes/kubernetes-docs-cn" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes-docs_not_null1" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-spec" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/container-_not_null4" NOT NULL,
    "kubernetes-csi/csi-driver-fibre-channel" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-driver-_not_null2" NOT NULL,
    "kubernetes-sigs/kubectl-check-ownerreferences" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kubectl-che_not_null" NOT NULL,
    "kubernetes/cloud-provider-sample" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cloud-provider-s_not_null" NOT NULL,
    "kubernetes-sigs/kube-agentic-networking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/kube-agenti_not_null" NOT NULL,
    "kubernetes/funding" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-baiducloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cloud-prov_not_null4" NOT NULL,
    "kubernetes/sig-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/perl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-ko" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes-docs_not_null2" NOT NULL,
    "kubernetes-sigs/testgrid-json-exporter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/testgrid-js_not_null" NOT NULL,
    "kubernetes-csi/kubernetes-csi.github.io" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/kubernetes-_not_null1" NOT NULL,
    "kubernetes-retired/kubernetes-docs-ja" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-retired/kuberne_not_null1" NOT NULL,
    "kubernetes-retired/kubernetes-docs-ko" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-retired/kuberne_not_null2" NOT NULL,
    "kubernetes-sigs/addon-operators" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/addon-opera_not_null" NOT NULL,
    "kubernetes-sigs/release-team-shadow-stats" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/release-tea_not_null" NOT NULL,
    "kubernetes-sig-testing/frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sig-testing/fram_not_null" NOT NULL,
    "kubernetes/kubernetes-docs-ja" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes-docs_not_null3" NOT NULL,
    "kubernetes-sigs/llm-instance-gateway" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/llm-instanc_not_null" NOT NULL,
    "kubernetes-sigs/volcano" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/clust_not_null1" NOT NULL,
    "kubernetes-sigs/referencegrant-poc" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/referencegr_not_null" NOT NULL,
    "kubernetes-incubator/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/custom_not_null" NOT NULL,
    "kubernetes-incubator/cluster-capacity" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/clust_not_null2" NOT NULL,
    "kubernetes-sigs/slack-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cve-feed-osv" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cve-feed-os_not_null" NOT NULL,
    "kubernetes-client/go-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/obscli" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/application-images" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/application-imag_not_null" NOT NULL,
    "kubernetes-sigs/wg-ai-gateway" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/wg-ai-gatew_not_null" NOT NULL,
    "kubernetes-sigs/sig-usability" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sig-usabili_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-image-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-csi/csi-driver-_not_null3" NOT NULL,
    "kubernetes-sigs/externalip-webhook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/externalip-_not_null" NOT NULL,
    "kubernetes-sigs/iptables-wrappers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/iptables-wr_not_null" NOT NULL,
    "kubernetes-sigs/aws-file-cache-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws-file-ca_not_null" NOT NULL,
    "kubernetes-incubator/spartakus" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/sparta_not_null" NOT NULL,
    "kubernetes-sigs/k8s-gsm-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/k8s-gsm-too_not_null" NOT NULL,
    "kubernetes-security/cvelist-public" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-security/cvelist_not_null" NOT NULL,
    "kubernetes/kms" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/porche" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-bootstrap" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cluster-bootstra_not_null" NOT NULL,
    "kubernetes-sigs/relnotes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-mesos-framework" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-incubator/kube-m_not_null" NOT NULL,
    "kubernetes-client/typescript" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-client/typescrip_not_null" NOT NULL,
    "kubernetes-sigs/windows-service-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/windows-ser_not_null" NOT NULL,
    "kubernetes/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-console" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/kubernetes-conso_not_null" NOT NULL,
    "kubernetes/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/noderesourcetopology-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/noderesourc_not_null" NOT NULL,
    "kubernetes-sigs/contributor-katacoda" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/contributo_not_null3" NOT NULL,
    "kubernetes/console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-fc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/logical-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/logical-clu_not_null" NOT NULL,
    "kubernetes-client/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/instrument_not_null1" NOT NULL,
    "kubernetes-sigs/mutating-trace-admission-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/mutating-tr_not_null" NOT NULL,
    "kubernetes-sigs/dra-driver-cpu" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/dra-driver_not_null1" NOT NULL,
    "kubernetes-sigs/signalhound" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/common" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-readiness-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/node-readin_not_null" NOT NULL,
    "kubernetes-sigs/sigs-github-actions" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sigs-github_not_null" NOT NULL,
    "kubernetes-sigs/maintainer-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/maintainer-_not_null" NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/architecture-tracking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/architectur_not_null" NOT NULL,
    "kubernetes-sigs/dranet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-retired/testing__not_null" NOT NULL,
    "kubernetes/component-helpers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/component-helper_not_null" NOT NULL,
    "kubernetes-sigs/execution-hook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/execution-h_not_null" NOT NULL,
    "kubernetes-sigs/discuss-theme" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/discuss-the_not_null" NOT NULL,
    "kubernetes/cel-admission-webhook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cel-admission-we_not_null" NOT NULL,
    "kubernetes/csi-translation-lib" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/csi-translation-_not_null" NOT NULL,
    "kubernetes-sigs/minikube-preloads" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/minikube-pr_not_null" NOT NULL,
    "kubernetes/component-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-auth-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sig-auth-to_not_null" NOT NULL,
    "kubernetes-sigs/instrumentation" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/instrument_not_null2" NOT NULL,
    "kubernetes-sigs/sig-windows-samples" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/sig-window_not_null2" NOT NULL,
    "kubernetes/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/cluster-proporti_not_null" NOT NULL,
    "kubernetes/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/legacy-cloud-providers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/legacy-cloud-pro_not_null" NOT NULL,
    "kubernetes/mount-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/controller-manager" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/controller-manag_not_null" NOT NULL,
    "kubernetes-retired/community" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-retired/communit_not_null" NOT NULL,
    "kubernetes-csi/resources" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cri-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduling_poseidon" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/scheduling__not_null" NOT NULL,
    "kubernetes-sigs/clientgofix" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/horizontal-self-scaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes/horizontal-self-_not_null" NOT NULL,
    "kubernetes-sigs/alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/alb-ingress_not_null" NOT NULL,
    "kubernetes-sigs/randfill" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/foo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws_encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/aws_encrypt_not_null" NOT NULL,
    "kubernetes-sigs/multi-network-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/multi-netw_not_null1" NOT NULL,
    "kubernetes-sigs/apps_application" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/apps_applic_not_null" NOT NULL,
    "kubernetes-sigs/cosi-driver-minio" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-sigs/cosi-drive_not_null1" NOT NULL,
    "kubernetes-graveyard/md-check" double precision DEFAULT 0.0 CONSTRAINT "spreprblckneeds_ok_to_test_kubernetes-graveyard/md-che_not_null" NOT NULL,
    "kubernetes/md-format" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spreprblckneeds_ok_to_test OWNER TO gha_admin;

--
-- Name: spreprblckno_approve; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spreprblckno_approve (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-provi_not_null" NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-nested" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null1" NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/provider-aws-test_not_null" NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-iam-authentic_not_null" NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null2" NOT NULL,
    "kubernetes-sigs/hierarchical-namespaces" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/hierarchical-name_not_null" NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kube-network-poli_not_null" NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-docker" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null3" NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/work-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/service-catalog" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/service-cata_not_null" NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/node-driver-regist_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null4" NOT NULL,
    "kubernetes/cluster-registry" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-addon_not_null" NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/usage-metrics-col_not_null" NOT NULL,
    "kubernetes-sigs/k8s-container-image-promoter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/k8s-container-ima_not_null" NOT NULL,
    "kubernetes-sigs/sig-multicluster-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/sig-multicluster-_not_null" NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/ip-masq-agent" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/ip-masq-agen_not_null" NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/nfs-subdir-extern_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-dev-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/sig-windows-dev-t_not_null" NOT NULL,
    "kubernetes-sigs/minikube-gui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kube-scheduler-wa_not_null" NOT NULL,
    "kubernetes-sigs/apisnoop" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testgrid" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-bootcamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/external-provision_not_null" NOT NULL,
    "kubernetes-sigs/dashboard-metrics-scraper" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/dashboard-metrics_not_null" NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/apiserver-builder_not_null" NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/volume-data-source_not_null" NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/nfs-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/nfs-provisio_not_null" NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null5" NOT NULL,
    "kubernetes/system-validators" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/seccomp-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/community-images" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/client-go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/federation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/container-object-_not_null" NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/gcp-filestore-csi_not_null" NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blixt" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/gateway-api-infer_not_null" NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/node-feature-disc_not_null" NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cloud-provider-eq_not_null" NOT NULL,
    "kubernetes-incubator/external-storage" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/external-sto_not_null" NOT NULL,
    "kubernetes/repo-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kubebuilder-relea_not_null" NOT NULL,
    "kubernetes-sigs/secrets-store-sync-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/secrets-store-syn_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null6" NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/apiserver-network_not_null" NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-encryption-pr_not_null" NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cosi-driver-sample" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cosi-driver-sampl_not_null" NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/charts" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes/committee-security-res_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-ipam-provider-in-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-ipam-_not_null" NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/knftables" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-proportio_not_null" NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/apiserver-bu_not_null" NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/azurefile-csi-dri_not_null" NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null7" NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-deploy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes.github.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/structured-merge-_not_null" NOT NULL,
    "kubernetes-sigs/legacyflag" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-containerd" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/cri-containe_not_null" NOT NULL,
    "kubernetes/ingress" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/frakti" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/sig-storage-local_not_null" NOT NULL,
    "kubernetes-sigs/mdtoc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kernel-module-man_not_null" NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null8" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-prov_not_null9" NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubeadm-dind-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kubeadm-dind-clus_not_null" NOT NULL,
    "kubernetes-sigs/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "GoogleCloudPlatform/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-apis" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-ebs-csi-drive_not_null" NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-fsx-csi-drive_not_null" NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-csi-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/container-object_not_null1" NOT NULL,
    "kubernetes-incubator/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/ruby" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/container-object_not_null2" NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/reference-docs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/reference-do_not_null" NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/external-snapshott_not_null" NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/dra-example-drive_not_null" NOT NULL,
    "kubernetes-sigs/karpenter-provider-cluster-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/karpenter-provide_not_null" NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/gcp-compute-persi_not_null" NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 NOT NULL,
    kubernetes double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/kubernetes-csi-migration-library" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/kubernetes-csi-mig_not_null" NOT NULL,
    "kubernetes-sigs/cni-dra-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/ingress-controlle_not_null" NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/vsphere-csi-drive_not_null" NOT NULL,
    "kubernetes-sigs/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-proporti_not_null1" NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubefed" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/alibaba-cloud-csi_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubemark" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-pro_not_null10" NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/lib-volume-populat_not_null" NOT NULL,
    "kubernetes-sigs/about-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurelustre-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/azurelustre-csi-d_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/container-object_not_null3" NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-boots_not_null" NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-serving" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/crdify" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/apiserver-b_not_null1" NOT NULL,
    "kubernetes-sigs/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/testing_framework_not_null" NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/nfs-ganesha-serve_not_null" NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-pro_not_null11" NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/ibm-powervs-block_not_null" NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-alb-ingress-c_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-pro_not_null12" NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcdadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kube-scheduler-si_not_null" NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-batch" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/depstat" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/node-feature_not_null" NOT NULL,
    "kubernetes-sigs/poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes/cloud-provider-alibaba_not_null" NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/security-profiles_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cloud-provider-hu_not_null" NOT NULL,
    "kubernetes-sigs/multi-network" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/node-feature-dis_not_null1" NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/wg-policy-prototy_not_null" NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/external-health-mo_not_null" NOT NULL,
    "kubernetes/heapster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/cluster-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/cluster-driver-reg_not_null" NOT NULL,
    "kubernetes-incubator/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blobfuse-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/blobfuse-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-operational-readiness" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/windows-operation_not_null" NOT NULL,
    "kubernetes-sigs/gwctl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multicluster-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/multicluster-runt_not_null" NOT NULL,
    "kubernetes-sigs/kpng" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/csi-driver-host-pa_not_null" NOT NULL,
    "kubernetes-sigs/minibroker" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-api-opera_not_null" NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/custom-metrics-ap_not_null" NOT NULL,
    "kubernetes-sigs/provider-ibmcloud-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/provider-ibmcloud_not_null" NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kubebuilder-decla_not_null" NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/azuredisk-csi-dri_not_null" NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/secrets-store-csi_not_null" NOT NULL,
    "kubernetes-sigs/gluster-file-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/gluster-file-exte_not_null" NOT NULL,
    "kubernetes/kubernetes-anywhere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/contributor-playg_not_null" NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-device-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/wg-device-managem_not_null" NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kube-storage-vers_not_null" NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/metrics-server" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/metrics-serv_not_null" NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/prometheus-adapte_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/network-policy-ap_not_null" NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/ibm-vpc-block-csi_not_null" NOT NULL,
    "kubernetes-sigs/cluster-inventory-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cluster-inventory_not_null" NOT NULL,
    "kubernetes/features" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/controller-runtim_not_null" NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-load-balancer_not_null" NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation-addons" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/instrumentation-a_not_null" NOT NULL,
    "kubernetes-sigs/contributor-tweets" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/contributor-tweet_not_null" NOT NULL,
    "kubernetes-sigs/downloadkubernetes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/downloadkubernete_not_null" NOT NULL,
    "kubernetes-incubator/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/helm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/drivers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/sig-storage-lib-e_not_null" NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/external-snapshot-_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-finalizer" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/network-policy-fi_not_null" NOT NULL,
    "kubernetes-sigs/federation-v2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cloud-provider-az_not_null" NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/verify-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/verify-conformanc_not_null" NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kargo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/client-python" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/client-pytho_not_null" NOT NULL,
    "kubernetes-sigs/multi-tenancy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/oci-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cloud-provider-ki_not_null" NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes/cloud-provider-opensta_not_null" NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-efs-csi-drive_not_null" NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/special-resource-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/special-resource-_not_null" NOT NULL,
    "kubernetes-sigs/wg-ai-conformance" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/cluster-prop_not_null" NOT NULL,
    "kubernetes-sigs/pspmigrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/maintainers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/logtools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nvmf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krm-functions-registry" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/krm-functions-reg_not_null" NOT NULL,
    "kubernetes-sigs/etcd-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nat64" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kindnet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-ipam-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/node-ipam-control_not_null" NOT NULL,
    "kubernetes/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-ibm-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/karpenter-provid_not_null1" NOT NULL,
    "kubernetes/kubedash" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/go-open-service-broker-client" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/go-open-service-b_not_null" NOT NULL,
    "kubernetes/kubernetes-template-project" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes/kubernetes-template-pr_not_null" NOT NULL,
    "kubernetes-sigs/aws-fsx-openzfs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-fsx-openzfs-c_not_null" NOT NULL,
    "kubernetes/funding" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/pr-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-sample" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-baiducloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/cloud-provider-ba_not_null" NOT NULL,
    "kubernetes-sigs/ingate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-actions" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubectl-check-ownerreferences" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kubectl-check-own_not_null" NOT NULL,
    "kubernetes-sigs/gluster-block-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/gluster-block-ext_not_null" NOT NULL,
    "kubernetes-incubator/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-spec" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/container-object_not_null4" NOT NULL,
    "kubernetes-retired/kubernetes-docs-zh" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-retired/kubernetes-doc_not_null" NOT NULL,
    "kubernetes/kubernetes-docs-cn" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/json" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-driver-topology" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/dra-driver-topolo_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-flex" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-agentic-networking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/kube-agentic-netw_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-fibre-channel" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/csi-driver-fibre-c_not_null" NOT NULL,
    "kubernetes-incubator/kube-arbitrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/kube-arbitra_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-ja" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-retired/kubernetes-do_not_null1" NOT NULL,
    "kubernetes/sig-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/volcano" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/slack-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/llm-instance-gateway" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/llm-instance-gate_not_null" NOT NULL,
    "kubernetes-incubator/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/cluster-pro_not_null1" NOT NULL,
    "kubernetes-incubator/cluster-capacity" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/cluster-capa_not_null" NOT NULL,
    "kubernetes-sig-testing/frameworks" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-ko" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/custom-metri_not_null" NOT NULL,
    "kubernetes/kubernetes-docs-ja" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubernetes-docs-ko" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-retired/kubernetes-do_not_null2" NOT NULL,
    "kubernetes-sigs/referencegrant-poc" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/referencegrant-po_not_null" NOT NULL,
    "kubernetes-sigs/release-team-shadow-stats" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/release-team-shad_not_null" NOT NULL,
    "kubernetes-csi/kubernetes-csi.github.io" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/kubernetes-csi.git_not_null" NOT NULL,
    "kubernetes-client/perl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testgrid-json-exporter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/testgrid-json-exp_not_null" NOT NULL,
    "kubernetes-sigs/addon-operators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-usability" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/application-images" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-ai-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cve-feed-osv" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/iptables-wrappers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/obscli" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/externalip-webhook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/externalip-webhoo_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-image-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-csi/csi-driver-image-p_not_null" NOT NULL,
    "kubernetes/kms" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-security/cvelist-public" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-security/cvelist-publi_not_null" NOT NULL,
    "kubernetes/cluster-bootstrap" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/k8s-gsm-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-mesos-framework" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-incubator/kube-mesos-f_not_null" NOT NULL,
    "kubernetes-client/typescript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-service-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/windows-service-p_not_null" NOT NULL,
    "kubernetes-sigs/aws-file-cache-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws-file-cache-cs_not_null" NOT NULL,
    "kubernetes-incubator/spartakus" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/relnotes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/porche" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/noderesourcetopology-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/noderesourcetopol_not_null" NOT NULL,
    "kubernetes/console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-katacoda" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/contributor-katac_not_null" NOT NULL,
    "kubernetes-retired/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-fc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/logical-cluster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mutating-trace-admission-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/mutating-trace-ad_not_null" NOT NULL,
    "kubernetes-sigs/dra-driver-cpu" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/instrumentation-t_not_null" NOT NULL,
    "kubernetes-sigs/maintainer-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-readiness-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/node-readiness-co_not_null" NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sigs-github-actions" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/sigs-github-actio_not_null" NOT NULL,
    "kubernetes/common" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/signalhound" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dranet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/architecture-tracking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/architecture-trac_not_null" NOT NULL,
    "kubernetes/component-helpers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-retired/testing_framew_not_null" NOT NULL,
    "kubernetes-sigs/execution-hook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cel-admission-webhook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/discuss-theme" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/csi-translation-lib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-auth-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/component-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minikube-preloads" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-samples" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/sig-windows-sampl_not_null" NOT NULL,
    "kubernetes/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes/cluster-proportional-a_not_null" NOT NULL,
    "kubernetes/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/mount-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/legacy-cloud-providers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/controller-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/resources" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cri-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduling_poseidon" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/scheduling_poseid_not_null" NOT NULL,
    "kubernetes-sigs/clientgofix" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/alb-ingress-contr_not_null" NOT NULL,
    "kubernetes/horizontal-self-scaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/randfill" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/foo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apps_application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws_encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_approve_kubernetes-sigs/aws_encryption-pr_not_null" NOT NULL,
    "kubernetes-sigs/multi-network-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cosi-driver-minio" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-graveyard/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/md-format" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spreprblckno_approve OWNER TO gha_admin;

--
-- Name: spreprblckno_lgtm; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spreprblckno_lgtm (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/federation-v2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/gateway-api-inferenc_not_null" NOT NULL,
    "kubernetes/helm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubeadm-dind-cluster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/container-object-sto_not_null" NOT NULL,
    "kubernetes-incubator/external-storage" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/external-storag_not_null" NOT NULL,
    "kubernetes-incubator/nfs-provisioner" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/gcp-compute-persiste_not_null" NOT NULL,
    "kubernetes-sigs/kui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gwctl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testgrid" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubemark" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provider_not_null" NOT NULL,
    "kubernetes-csi/cluster-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-csi/cluster-driver-regist_not_null" NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cosi-driver-sample" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/contributor-playgrou_not_null" NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/aws-alb-ingress-cont_not_null" NOT NULL,
    "GoogleCloudPlatform/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation-addons" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/instrumentation-addo_not_null" NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-network" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/aws-iam-authenticato_not_null" NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/seccomp-operator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null1" NOT NULL,
    "kubernetes-sigs/apiserver-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multicluster-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null2" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-csi-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/container-object-st_not_null1" NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blobfuse-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minibroker" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kube-scheduler-simul_not_null" NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cni-dra-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/k8s-container-image-promoter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/k8s-container-image-_not_null" NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/container-object-st_not_null2" NOT NULL,
    "kubernetes-incubator/reference-docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/structured-merge-dif_not_null" NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/sig-storage-local-st_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null3" NOT NULL,
    "kubernetes/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-bootstra_not_null" NOT NULL,
    "kubernetes-sigs/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kubebuilder-release-_not_null" NOT NULL,
    "kubernetes-sigs/etcdadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/client-python" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/knftables" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-csi/volume-data-source-va_not_null" NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-docker" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null4" NOT NULL,
    "kubernetes-sigs/mdtoc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/usage-metrics-collec_not_null" NOT NULL,
    "kubernetes-sigs/minikube-gui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/apiserver-builder-al_not_null" NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes/committee-security-respon_not_null" NOT NULL,
    "kubernetes-sigs/windows-operational-readiness" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/windows-operational-_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null5" NOT NULL,
    "kubernetes-client/go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/client-go" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-serving" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-containerd" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kubebuilder-declarat_not_null" NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/nfs-subdir-external-_not_null" NOT NULL,
    "kubernetes-sigs/about-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/gcp-filestore-csi-dr_not_null" NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/ingress" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/ingress-controller-c_not_null" NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/apisnoop" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/alibaba-cloud-csi-dr_not_null" NOT NULL,
    "kubernetes-sigs/oci-proxy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubefed" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/apiserver-build_not_null" NOT NULL,
    "kubernetes-sigs/testing_frameworks" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null6" NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/sig-storage-lib-exte_not_null" NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kube-scheduler-wasm-_not_null" NOT NULL,
    "kubernetes/features" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/frakti" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kube-storage-version_not_null" NOT NULL,
    "kubernetes-csi/kubernetes-csi-migration-library" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-csi/kubernetes-csi-migrat_not_null" NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-batch" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-bootcamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-tenancy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/security-profiles-op_not_null" NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-cluster-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/karpenter-provider-c_not_null" NOT NULL,
    "kubernetes/kubernetes-anywhere" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/legacyflag" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/hierarchical-namespaces" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/hierarchical-namespa_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/container-object-st_not_null3" NOT NULL,
    "kubernetes-sigs/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-proportional_not_null" NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-registry" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-device-management" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes.github.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-apis" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cloud-provider-equin_not_null" NOT NULL,
    "kubernetes-csi/csi-lib-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-sync-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/secrets-store-sync-c_not_null" NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/community-images" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kube-network-policie_not_null" NOT NULL,
    "kubernetes-csi/drivers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azurelustre-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/azurelustre-csi-driv_not_null" NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/apiserver-network-pr_not_null" NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dashboard-metrics-scraper" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/dashboard-metrics-sc_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-ipam-provider-in-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-ipam-pro_not_null" NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kargo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/work-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-addon-pr_not_null" NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/node-feature-di_not_null" NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-nested" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null7" NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kernel-module-manage_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cloud-provider-huawe_not_null" NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/node-feature-discove_not_null" NOT NULL,
    "kubernetes/heapster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/aws-encryption-provi_not_null" NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null8" NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/aws-load-balancer-co_not_null" NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-dev-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/sig-windows-dev-tool_not_null" NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/apiserver-buil_not_null1" NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/descheduler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/repo-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-proportiona_not_null1" NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/custom-metrics-apise_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-finalizer" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/network-policy-final_not_null" NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/nfs-ganesha-server-a_not_null" NOT NULL,
    "kubernetes-sigs/sig-multicluster-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/sig-multicluster-sit_not_null" NOT NULL,
    "kubernetes-incubator/external-dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/node-feature-discov_not_null1" NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes/cloud-provider-alibaba-cl_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provide_not_null9" NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/federation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/depstat" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/ruby" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/verify-conformance" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provid_not_null10" NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/provider-ibmcloud-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/provider-ibmcloud-te_not_null" NOT NULL,
    "kubernetes-sigs/crdify" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/secrets-store-csi-dr_not_null" NOT NULL,
    kubernetes double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/security" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/provider-aws-test-in_not_null" NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-csi/external-snapshot-met_not_null" NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gluster-file-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/gluster-file-externa_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/bootkube" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/system-validators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kpng" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/blixt" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/charts" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/service-catalog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provid_not_null11" NOT NULL,
    "kubernetes-sigs/contributor-tweets" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/ibm-vpc-block-csi-dr_not_null" NOT NULL,
    "kubernetes-sigs/cluster-inventory-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-inventory-ap_not_null" NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-deploy" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/ibm-powervs-block-cs_not_null" NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-csi/external-health-monit_not_null" NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cluster-api-provid_not_null12" NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/downloadkubernetes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-azure" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/karpenter-provider-ibm-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/karpenter-provider-i_not_null" NOT NULL,
    "kubernetes-incubator/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/cluster-proport_not_null" NOT NULL,
    "kubernetes-sigs/logtools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/maintainers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-template-project" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes/kubernetes-template-proje_not_null" NOT NULL,
    "kubernetes/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/special-resource-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/special-resource-ope_not_null" NOT NULL,
    "kubernetes-sigs/nat64" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-ai-conformance" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-zh" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubedash" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/etcd-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/go-open-service-broker-client" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/go-open-service-brok_not_null" NOT NULL,
    "kubernetes-sigs/pspmigrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/kindnet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krm-functions-registry" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/krm-functions-regist_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-nvmf" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-ipam-controller" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-fsx-openzfs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/aws-fsx-openzfs-csi-_not_null" NOT NULL,
    "kubernetes-sigs/json" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/pr-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/gluster-block-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/gluster-block-extern_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-zh" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-retired/kubernetes-docs-z_not_null" NOT NULL,
    "kubernetes-sigs/dra-driver-topology" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-fibre-channel" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-csi/csi-driver-fibre-chan_not_null" NOT NULL,
    "kubernetes-sigs/kubectl-check-ownerreferences" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kubectl-check-ownerr_not_null" NOT NULL,
    "kubernetes-sigs/kube-agentic-networking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/kube-agentic-network_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-spec" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/container-object-st_not_null4" NOT NULL,
    "kubernetes-csi/csi-driver-flex" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/ingate" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-cn" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/funding" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-o" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-arbitrator" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-sample" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-actions" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cloud-provider-baiducloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/cloud-provider-baidu_not_null" NOT NULL,
    "kubernetes-sig-testing/frameworks" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/addon-operators" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/perl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/kubernetes-docs-ko" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-retired/kubernetes-docs-k_not_null" NOT NULL,
    "kubernetes-sigs/slack-infra" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/volcano" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-docs-ja" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/cluster-propor_not_null1" NOT NULL,
    "kubernetes/kubernetes-docs-ko" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testgrid-json-exporter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/testgrid-json-export_not_null" NOT NULL,
    "kubernetes-sigs/referencegrant-poc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/release-team-shadow-stats" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/release-team-shadow-_not_null" NOT NULL,
    "kubernetes-incubator/cluster-capacity" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/cluster-capacit_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-ja" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-retired/kubernetes-docs-j_not_null" NOT NULL,
    "kubernetes/sig-testing" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/custom-metrics-_not_null" NOT NULL,
    "kubernetes-sigs/llm-instance-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/kubernetes-csi.github.io" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-csi/kubernetes-csi.github_not_null" NOT NULL,
    "kubernetes-sigs/externalip-webhook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/obscli" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-driver-image-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-csi/csi-driver-image-popu_not_null" NOT NULL,
    "kubernetes-sigs/cve-feed-osv" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/application-images" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/wg-ai-gateway" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/iptables-wrappers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/node-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-usability" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/spartakus" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kms" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-file-cache-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/aws-file-cache-csi-d_not_null" NOT NULL,
    "kubernetes/cluster-bootstrap" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/typescript" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-service-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/windows-service-prox_not_null" NOT NULL,
    "kubernetes-sigs/porche" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-mesos-framework" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-incubator/kube-mesos-fram_not_null" NOT NULL,
    "kubernetes-sigs/relnotes" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/k8s-gsm-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-security/cvelist-public" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/csi-lib-fc" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/contributor-katacoda" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/logical-cluster" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/noderesourcetopology-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/noderesourcetopology_not_null" NOT NULL,
    "kubernetes-retired/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/instrumentation-tool_not_null" NOT NULL,
    "kubernetes-sigs/mutating-trace-admission-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/mutating-trace-admis_not_null" NOT NULL,
    "kubernetes-client/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dra-driver-cpu" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/maintainer-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/signalhound" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sigs-github-actions" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/common" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/node-readiness-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/node-readiness-contr_not_null" NOT NULL,
    "kubernetes-sigs/architecture-tracking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/architecture-trackin_not_null" NOT NULL,
    "kubernetes/component-helpers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dranet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-retired/testing_framework_not_null" NOT NULL,
    "kubernetes-sigs/execution-hook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cel-admission-webhook" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/discuss-theme" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/component-base" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/minikube-preloads" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/csi-translation-lib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sig-auth-tools" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/instrumentation" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes/cluster-proportional-auto_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-samples" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/legacy-cloud-providers" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/mount-utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-retired/community" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/controller-manager" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-csi/resources" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cri-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduling_poseidon" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/clientgofix" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/horizontal-self-scaler" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/alb-ingress-controll_not_null" NOT NULL,
    "kubernetes-sigs/randfill" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/foo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws_encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckno_lgtm_kubernetes-sigs/aws_encryption-provi_not_null" NOT NULL,
    "kubernetes-sigs/apps_application" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/multi-network-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cosi-driver-minio" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-graveyard/md-check" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/md-format" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spreprblckno_lgtm OWNER TO gha_admin;

--
-- Name: spreprblckrelease_note_label_needed; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spreprblckrelease_note_label_needed (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "kubernetes-sigs/cluster-api-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cluster-ap_not_null" NOT NULL,
    "kubernetes-sigs/contributor-tweets" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/contributo_not_null" NOT NULL,
    "kubernetes-sigs/kube-api-linter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kube-api-l_not_null" NOT NULL,
    "kubernetes/kube-deploy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes/kube-deploy_not_null" NOT NULL,
    "kubernetes/repo-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes/repo-infra_not_null" NOT NULL,
    "kubernetes/ingress-nginx" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes/ingress-nginx_not_null" NOT NULL,
    "kubernetes-sigs/cri-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/cri-tools_not_null" NOT NULL,
    "kubernetes-sigs/kwok" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/kwok_not_null" NOT NULL,
    "kubernetes/client-go" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes/client-go_not_null" NOT NULL,
    "kubernetes-sigs/krew-index" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/krew-index_not_null" NOT NULL,
    "kubernetes-sigs/descheduler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/deschedule_not_null" NOT NULL,
    "kubernetes-sigs/alibaba-cloud-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/alibaba-cl_not_null" NOT NULL,
    "kubernetes-csi/external-snapshotter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/external-sn_not_null" NOT NULL,
    "kubernetes-sigs/metrics-server" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/metrics-se_not_null" NOT NULL,
    "kubernetes-sigs/legacyflag" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/legacyflag_not_null" NOT NULL,
    "kubernetes-sigs/sig-storage-local-static-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/sig-storag_not_null" NOT NULL,
    "kubernetes-sigs/sig-storage-lib-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/sig-storag_not_null1" NOT NULL,
    "kubernetes-sigs/sig-multicluster-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/sig-multic_not_null" NOT NULL,
    "kubernetes-sigs/kube-scheduler-wasm-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kube-sched_not_null" NOT NULL,
    "kubernetes/kube-openapi" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes/kube-openapi_not_null" NOT NULL,
    "kubernetes-incubator/cri-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/cri-t_not_null" NOT NULL,
    "kubernetes-sigs/gcp-filestore-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/gcp-filest_not_null" NOT NULL,
    "kubernetes-client/javascript" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-client/javascri_not_null" NOT NULL,
    "kubernetes-sigs/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/node-featu_not_null" NOT NULL,
    "kubernetes-sigs/controller-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/controller_not_null" NOT NULL,
    "kubernetes/org" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/dashboard-metrics-scraper" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/dashboard-_not_null" NOT NULL,
    "kubernetes-csi/csi-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/csi-release_not_null" NOT NULL,
    "kubernetes-sigs/work-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/work-api_not_null" NOT NULL,
    "kubernetes-sigs/inference-perf" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/inference-_not_null" NOT NULL,
    "kubernetes/federation" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes/federation_not_null" NOT NULL,
    "kubernetes-sigs/secrets-store-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/secrets-st_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/container-_not_null" NOT NULL,
    "kubernetes-sigs/kubectl-validate" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kubectl-va_not_null" NOT NULL,
    "kubernetes-csi/external-snapshot-metadata" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/external-sn_not_null1" NOT NULL,
    "kubernetes/gengo" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-containerd" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/cri-c_not_null" NOT NULL,
    "kubernetes-csi/csi-lib-utils" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/csi-lib-uti_not_null" NOT NULL,
    "kubernetes/kubernetes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes/kubernetes_not_null" NOT NULL,
    "kubernetes/frakti" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/node-feature-discovery" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/node-_not_null" NOT NULL,
    "kubernetes-sigs/jobset" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-sigs/jobset_not_null" NOT NULL,
    "kubernetes/kops" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/testing_fr_not_null" NOT NULL,
    "kubernetes-sigs/apiserver-network-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/apiserver-_not_null" NOT NULL,
    "kubernetes-client/csharp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-client/csharp_not_null" NOT NULL,
    "kubernetes-sigs/nfs-ganesha-server-and-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/nfs-ganesh_not_null" NOT NULL,
    "kubernetes-incubator/metrics-server" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/metri_not_null" NOT NULL,
    "kubernetes-sigs/kubeadm-dind-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kubeadm-di_not_null" NOT NULL,
    "kubernetes-sigs/provider-aws-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/provider-a_not_null" NOT NULL,
    "kubernetes-csi/kubernetes-csi-migration-library" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/kubernetes-_not_null" NOT NULL,
    "kubernetes-sigs/gcp-compute-persistent-disk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/gcp-comput_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-bootstrap-provider-kubeadm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null1" NOT NULL,
    "kubernetes-sigs/wg-serving" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/wg-serving_not_null" NOT NULL,
    "kubernetes-sigs/windows-testing" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/windows-te_not_null" NOT NULL,
    "kubernetes/committee-security-response" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/committee-secur_not_null" NOT NULL,
    "kubernetes-sigs/controller-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/controller_not_null1" NOT NULL,
    "kubernetes/perf-tests" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes/perf-tests_not_null" NOT NULL,
    "kubernetes-incubator/descheduler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/desch_not_null" NOT NULL,
    "kubernetes-sigs/external-dns" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/external-d_not_null" NOT NULL,
    "kubernetes-csi/cluster-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/cluster-dri_not_null" NOT NULL,
    "kubernetes-sigs/structured-merge-diff" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/structured_not_null" NOT NULL,
    "kubernetes-incubator/nfs-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/nfs-p_not_null" NOT NULL,
    "kubernetes-csi/node-driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/node-driver_not_null" NOT NULL,
    "kubernetes-sigs/aws-encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-encryp_not_null" NOT NULL,
    "kubernetes-sigs/security-profiles-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/security-p_not_null" NOT NULL,
    "kubernetes-sigs/kui" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes-sigs/kui_not_null" NOT NULL,
    "kubernetes-sigs/cni-dra-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cni-dra-dr_not_null" NOT NULL,
    "kubernetes-client/java" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-client/java_not_null" NOT NULL,
    "kubernetes/cloud-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/cloud-provider-_not_null" NOT NULL,
    "kubernetes-sigs/ibm-vpc-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/ibm-vpc-bl_not_null" NOT NULL,
    "kubernetes-sigs/dra-example-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/dra-exampl_not_null" NOT NULL,
    "kubernetes/ingress" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/kube-_not_null" NOT NULL,
    "kubernetes-sigs/kube-scheduler-simulator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/kube-sched_not_null1" NOT NULL,
    "kubernetes-sigs/reference-docs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/reference-_not_null" NOT NULL,
    "kubernetes-sigs/kueue" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes-sigs/kueue_not_null" NOT NULL,
    "kubernetes-sigs/gluster-file-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/gluster-fi_not_null" NOT NULL,
    "kubernetes/registry.k8s.io" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/registry.k8s.io_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-huaweicloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cloud-prov_not_null" NOT NULL,
    "kubernetes/node-problem-detector" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/node-problem-de_not_null" NOT NULL,
    "kubernetes-sigs/mdtoc" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes-sigs/mdtoc_not_null" NOT NULL,
    "kubernetes/contributor-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/contributor-sit_not_null" NOT NULL,
    "kubernetes-sigs/prow" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/prow_not_null" NOT NULL,
    "kubernetes-incubator/external-storage" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/exter_not_null" NOT NULL,
    "kubernetes-incubator/bootkube" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/bootk_not_null" NOT NULL,
    "kubernetes-sigs/minikube-gui" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/minikube-g_not_null" NOT NULL,
    "kubernetes-sigs/blixt" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes-sigs/blixt_not_null" NOT NULL,
    "kubernetes-sigs/kjob" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/kjob_not_null" NOT NULL,
    "kubernetes-sigs/gwctl" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes-sigs/gwctl_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null2" NOT NULL,
    "kubernetes-sigs/tejolote" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/tejolote_not_null" NOT NULL,
    "kubernetes-sigs/kube-network-policies" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kube-netwo_not_null" NOT NULL,
    "kubernetes/minikube" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/minikube_not_null" NOT NULL,
    "kubernetes/website" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/go" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-client/go_not_null" NOT NULL,
    "kubernetes-sigs/service-apis" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/service-ap_not_null" NOT NULL,
    "kubernetes-sigs/kubetest2" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/kubetest2_not_null" NOT NULL,
    "kubernetes-sigs/ip-masq-agent" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/ip-masq-ag_not_null" NOT NULL,
    "kubernetes-sigs/knftables" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/knftables_not_null" NOT NULL,
    "kubernetes-sigs/cluster-inventory-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cluster-in_not_null" NOT NULL,
    "kubernetes-sigs/service-catalog" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/service-ca_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/network-po_not_null" NOT NULL,
    "kubernetes-sigs/kernel-module-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kernel-mod_not_null" NOT NULL,
    "kubernetes-sigs/community-images" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/community-_not_null" NOT NULL,
    "kubernetes-sigs/wg-device-management" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/wg-device-_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api-inference-extension" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/gateway-ap_not_null" NOT NULL,
    "kubernetes-sigs/aws-fsx-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-fsx-cs_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-iscsi" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/csi-driver-_not_null" NOT NULL,
    "All" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/poseidon" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/poseidon_not_null" NOT NULL,
    "kubernetes-sigs/kube-batch" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kube-batch_not_null" NOT NULL,
    "kubernetes-sigs/krew" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/krew_not_null" NOT NULL,
    "kubernetes/system-validators" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/system-validato_not_null" NOT NULL,
    "kubernetes-sigs/kpng" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/kpng_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-aws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null3" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-packet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null4" NOT NULL,
    "kubernetes/kubeadm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/federation-v2" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/federation_not_null" NOT NULL,
    "kubernetes-sigs/aws-iam-authenticator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-iam-au_not_null" NOT NULL,
    "kubernetes-csi/external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/external-pr_not_null" NOT NULL,
    "kubernetes-sigs/bom" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes-sigs/bom_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-dev-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/sig-window_not_null" NOT NULL,
    "kubernetes/sig-security" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes/sig-security_not_null" NOT NULL,
    "kubernetes-sigs/about-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/about-api_not_null" NOT NULL,
    "kubernetes/k8s.io" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/external-dns" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-incubator/exter_not_null1" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null5" NOT NULL,
    "kubernetes-incubator/reference-docs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/refer_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-smb" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/csi-driver-_not_null1" NOT NULL,
    "kubernetes-sigs/node-feature-discovery-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/node-featu_not_null1" NOT NULL,
    "kubernetes-client/python" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-client/python_not_null" NOT NULL,
    "kubernetes-sigs/aws-efs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-efs-cs_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-csi-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/container-_not_null1" NOT NULL,
    "kubernetes-sigs/headlamp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/headlamp_not_null" NOT NULL,
    "kubernetes-sigs/agent-sandbox" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/agent-sand_not_null" NOT NULL,
    "kubernetes-sigs/secrets-store-sync-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/secrets-st_not_null1" NOT NULL,
    "kubernetes-incubator/kargo" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/kargo_not_null" NOT NULL,
    "kubernetes/autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes/autoscaler_not_null" NOT NULL,
    "kubernetes/cloud-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/cloud-provider-_not_null1" NOT NULL,
    "kubernetes-sigs/prometheus-adapter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/prometheus_not_null" NOT NULL,
    "kubernetes-sigs/blob-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/blob-csi-d_not_null" NOT NULL,
    "kubernetes-csi/volume-data-source-validator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/volume-data_not_null" NOT NULL,
    "kubernetes-csi/driver-registrar" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/driver-regi_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-docker" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null6" NOT NULL,
    "kubernetes-sigs/instrumentation-addons" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/instrument_not_null" NOT NULL,
    "kubernetes-sigs/lws" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes-sigs/lws_not_null" NOT NULL,
    "kubernetes-incubator/kompose" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/kompo_not_null" NOT NULL,
    "kubernetes-csi/drivers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-csi/drivers_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cloud-prov_not_null1" NOT NULL,
    "kubernetes-csi/csi-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-csi/csi-proxy_not_null" NOT NULL,
    "kubernetes-sigs/etcdadm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes-sigs/etcdadm_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubevirt" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null7" NOT NULL,
    "kubernetes-sigs/cluster-api-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null8" NOT NULL,
    "kubernetes-csi/csi-driver-host-path" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/csi-driver-_not_null2" NOT NULL,
    "kubernetes-sigs/azurelustre-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/azurelustr_not_null" NOT NULL,
    "kubernetes-sigs/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/apiserver-_not_null1" NOT NULL,
    "kubernetes-sigs/e2e-framework" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/e2e-framew_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-cloudstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-ap_not_null9" NOT NULL,
    "kubernetes-sigs/cloud-provider-equinix-metal" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cloud-prov_not_null2" NOT NULL,
    "kubernetes-sigs/multi-network" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/multi-netw_not_null" NOT NULL,
    "kubernetes-sigs/multicluster-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/multiclust_not_null" NOT NULL,
    "kubernetes-sigs/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cluster-pr_not_null" NOT NULL,
    "kubernetes/heapster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/heapster_not_null" NOT NULL,
    "kubernetes-incubator/kubespray" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/kubes_not_null" NOT NULL,
    "kubernetes-csi/csi-test" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes-csi/csi-test_not_null" NOT NULL,
    "kubernetes/ingress-gce" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes/ingress-gce_not_null" NOT NULL,
    "kubernetes-sigs/kustomize" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/kustomize_not_null" NOT NULL,
    "kubernetes-sigs/azurefile-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/azurefile-_not_null" NOT NULL,
    "kubernetes-sigs/cluster-addons" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cluster-ad_not_null" NOT NULL,
    "kubernetes-sigs/release-utils" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/release-ut_not_null" NOT NULL,
    "kubernetes-csi/docs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes-csi/docs_not_null" NOT NULL,
    "kubernetes-csi/livenessprobe" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/livenesspro_not_null" NOT NULL,
    "kubernetes-sigs/boskos" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-sigs/boskos_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-nested" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-a_not_null10" NOT NULL,
    "kubernetes-sigs/karpenter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/karpenter_not_null" NOT NULL,
    "kubernetes-sigs/apiserver-runtime" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/apiserver-_not_null2" NOT NULL,
    "kubernetes-incubator/client-python" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/clien_not_null" NOT NULL,
    "kubernetes-incubator/apiserver-builder-alpha" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/apise_not_null" NOT NULL,
    "kubernetes-sigs/bootkube" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/bootkube_not_null" NOT NULL,
    "kubernetes-sigs/depstat" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes-sigs/depstat_not_null" NOT NULL,
    "kubernetes/enhancements" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes/enhancements_not_null" NOT NULL,
    "kubernetes-incubator/apiserver-builder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-incubator/apise_not_null1" NOT NULL,
    "kubernetes-sigs/cri-o" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes-sigs/cri-o_not_null" NOT NULL,
    "kubernetes/cloud-provider-vsphere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/cloud-provider-_not_null2" NOT NULL,
    "kubernetes-sigs/cli-utils" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/cli-utils_not_null" NOT NULL,
    "kubernetes-sigs/wg-policy-prototypes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/wg-policy-_not_null" NOT NULL,
    "kubernetes-sigs/apisnoop" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/apisnoop_not_null" NOT NULL,
    "kubernetes-sigs/kind" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/kind_not_null" NOT NULL,
    "kubernetes-sigs/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-pr_not_null1" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-ibmcloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-a_not_null11" NOT NULL,
    "kubernetes-sigs/zeitgeist" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/zeitgeist_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-nfs" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/csi-driver-_not_null3" NOT NULL,
    "kubernetes-sigs/ibm-powervs-block-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/ibm-powerv_not_null" NOT NULL,
    "kubernetes-sigs/seccomp-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/seccomp-op_not_null" NOT NULL,
    kubernetes double precision DEFAULT 0.0 NOT NULL,
    "GoogleCloudPlatform/kubernetes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_GoogleCloudPlatform/kubern_not_null" NOT NULL,
    "kubernetes/cluster-registry" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/cluster-registr_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/container-_not_null2" NOT NULL,
    "kubernetes/steering" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/steering_not_null" NOT NULL,
    "kubernetes-sigs/mcs-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes-sigs/mcs-api_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-kind" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cloud-prov_not_null3" NOT NULL,
    "kubernetes/test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes/test-infra_not_null" NOT NULL,
    "kubernetes-sigs/kube-storage-version-migrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kube-stora_not_null" NOT NULL,
    "kubernetes-sigs/windows-gmsa" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/windows-gm_not_null" NOT NULL,
    "kubernetes-sigs/release-sdk" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/release-sd_not_null" NOT NULL,
    "kubernetes-sigs/ingress2gateway" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/ingress2ga_not_null" NOT NULL,
    "kubernetes-sigs/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/custom-met_not_null" NOT NULL,
    "kubernetes-sigs/release-notes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/release-no_not_null" NOT NULL,
    "kubernetes-incubator/service-catalog" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/servi_not_null" NOT NULL,
    "kubernetes/sig-release" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes/sig-release_not_null" NOT NULL,
    "kubernetes/contrib" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cluster-api-provider-openstack" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-a_not_null12" NOT NULL,
    "kubernetes-sigs/image-builder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/image-buil_not_null" NOT NULL,
    "kubernetes-sigs/multi-tenancy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/multi-tena_not_null" NOT NULL,
    "kubernetes-sigs/nfs-subdir-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/nfs-subdir_not_null" NOT NULL,
    "kubernetes-sigs/provider-ibmcloud-test-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/provider-i_not_null" NOT NULL,
    "kubernetes/publishing-bot" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes/publishing-bot_not_null" NOT NULL,
    "kubernetes-sigs/scheduler-plugins" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/scheduler-_not_null" NOT NULL,
    "kubernetes-sigs/promo-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/promo-tool_not_null" NOT NULL,
    "kubernetes-sigs/application" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/applicatio_not_null" NOT NULL,
    "kubernetes/cloud-provider-gcp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/cloud-provider-_not_null3" NOT NULL,
    "kubernetes/klog" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/aws-load-balancer-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-load-b_not_null" NOT NULL,
    "kubernetes-sigs/aws-alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-alb-in_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-a_not_null13" NOT NULL,
    "kubernetes/security" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/security_not_null" NOT NULL,
    "kubernetes-sigs/minibroker" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/minibroker_not_null" NOT NULL,
    "kubernetes-sigs/crdify" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-sigs/crdify_not_null" NOT NULL,
    "kubernetes/kubernetes-anywhere" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/kubernetes-anyw_not_null" NOT NULL,
    "kubernetes-csi/external-resizer" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/external-re_not_null" NOT NULL,
    "kubernetes-sigs/cosi-driver-sample" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cosi-drive_not_null" NOT NULL,
    "kubernetes-client/c" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes-client/c_not_null" NOT NULL,
    "kubernetes-client/haskell" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-client/haskell_not_null" NOT NULL,
    "kubernetes-sigs/verify-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/verify-con_not_null" NOT NULL,
    "kubernetes-sigs/hydrophone" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/hydrophone_not_null" NOT NULL,
    "kubernetes/features" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/features_not_null" NOT NULL,
    "kubernetes-sigs/contributor-site" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/contributo_not_null1" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-kubemark" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-a_not_null14" NOT NULL,
    "kubernetes-sigs/windows-operational-readiness" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/windows-op_not_null" NOT NULL,
    "kubernetes/utils" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/cli-experimental" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cli-experi_not_null" NOT NULL,
    "kubernetes-sigs/usage-metrics-collector" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/usage-metr_not_null" NOT NULL,
    "kubernetes-csi/external-attacher" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/external-at_not_null" NOT NULL,
    "kubernetes-sigs/gateway-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/gateway-ap_not_null1" NOT NULL,
    "kubernetes-csi/csi-lib-iscsi" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/csi-lib-isc_not_null" NOT NULL,
    "kubernetes-sigs/yaml" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/yaml_not_null" NOT NULL,
    "kubernetes-sigs/kubefed" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes-sigs/kubefed_not_null" NOT NULL,
    "kubernetes/cloud-provider-alibaba-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/cloud-provider-_not_null4" NOT NULL,
    "kubernetes-client/ruby" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-client/ruby_not_null" NOT NULL,
    "kubernetes-sigs/network-policy-finalizer" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/network-po_not_null1" NOT NULL,
    "kubernetes/kubectl" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/downloadkubernetes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/downloadku_not_null" NOT NULL,
    "kubernetes-csi/lib-volume-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/lib-volume-_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-addon-provider-helm" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-a_not_null15" NOT NULL,
    "kubernetes/community" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes/community_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kubebuilde_not_null" NOT NULL,
    "kubernetes/examples" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/examples_not_null" NOT NULL,
    "kubernetes-sigs/karpenter-provider-cluster-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/karpenter-_not_null" NOT NULL,
    "kubernetes/kubernetes.github.io" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/kubernetes.gith_not_null" NOT NULL,
    "kubernetes-sigs/kubespray" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/kubespray_not_null" NOT NULL,
    "kubernetes-sigs/aws-ebs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-ebs-cs_not_null" NOT NULL,
    "kubernetes-sigs/ingress-controller-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/ingress-co_not_null" NOT NULL,
    "kubernetes-sigs/kro" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes-sigs/kro_not_null" NOT NULL,
    "kubernetes-sigs/testgrid" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/testgrid_not_null" NOT NULL,
    "kubernetes-incubator/ip-masq-agent" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/ip-ma_not_null" NOT NULL,
    "kubernetes-sigs/k8s-container-image-promoter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/k8s-contai_not_null" NOT NULL,
    "kubernetes-sigs/hierarchical-namespaces" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/hierarchic_not_null" NOT NULL,
    "kubernetes-csi/external-health-monitor" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-csi/external-he_not_null" NOT NULL,
    "kubernetes-sigs/lwkd" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/lwkd_not_null" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/container-_not_null3" NOT NULL,
    "kubernetes/release" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/charts" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-client/python-base" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-client/python-b_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder-declarative-pattern" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/kubebuilde_not_null1" NOT NULL,
    "kubernetes-sigs/blobfuse-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/blobfuse-c_not_null" NOT NULL,
    "kubernetes/git-sync" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/git-sync_not_null" NOT NULL,
    "kubernetes-sigs/kubebuilder-release-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/kubebuilde_not_null2" NOT NULL,
    "kubernetes/kube-state-metrics" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/kube-state-metr_not_null" NOT NULL,
    "kubernetes-incubator/rktlet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/rktle_not_null" NOT NULL,
    "kubernetes/helm" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/azuredisk-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/azuredisk-_not_null" NOT NULL,
    "kubernetes-sigs/contributor-playground" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/contributo_not_null2" NOT NULL,
    "kubernetes/dashboard" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes/dashboard_not_null" NOT NULL,
    "kubernetes/dns" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/kubernetes-bootcamp" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/kubernetes-boot_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-provider-digitalocean" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-a_not_null16" NOT NULL,
    "kubernetes-sigs/vsphere-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/vsphere-cs_not_null" NOT NULL,
    "kubernetes-sigs/oci-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-sigs/oci-proxy_not_null" NOT NULL,
    "kubernetes-sigs/cluster-api-ipam-provider-in-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cluster-a_not_null17" NOT NULL,
    "kubernetes-client/gen" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes-client/gen_not_null" NOT NULL,
    "kubernetes/kompose" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/krm-functions-registry" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/krm-functi_not_null" NOT NULL,
    "kubernetes-sigs/go-open-service-broker-client" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/go-open-se_not_null" NOT NULL,
    "kubernetes-sigs/aws-fsx-openzfs-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-fsx-op_not_null" NOT NULL,
    "kubernetes-sigs/kindnet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes-sigs/kindnet_not_null" NOT NULL,
    "kubernetes/rktlet" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/cloud-provider-azure" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/cloud-provider-_not_null5" NOT NULL,
    "kubernetes-sigs/special-resource-operator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/special-re_not_null" NOT NULL,
    "kubernetes-sigs/sig-windows-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/sig-window_not_null1" NOT NULL,
    "kubernetes/kubedash" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/kubedash_not_null" NOT NULL,
    "kubernetes-sigs/nat64" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_nee_kubernetes-sigs/nat64_not_null" NOT NULL,
    "kubernetes/kubernetes-docs-zh" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/kubernetes-docs_not_null" NOT NULL,
    "kubernetes/kubernetes-template-project" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/kubernetes-temp_not_null" NOT NULL,
    "kubernetes-sigs/node-ipam-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/node-ipam-_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-nvmf" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/csi-driver-_not_null4" NOT NULL,
    "kubernetes-sigs/maintainers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/maintainer_not_null" NOT NULL,
    "kubernetes-sigs/wg-ai-conformance" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/wg-ai-conf_not_null" NOT NULL,
    "kubernetes-sigs/cluster-capacity" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cluster-ca_not_null" NOT NULL,
    "kubernetes-sigs/etcd-manager" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/etcd-manag_not_null" NOT NULL,
    "kubernetes-sigs/karpenter-provider-ibm-cloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/karpenter-_not_null1" NOT NULL,
    "kubernetes-incubator/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/clust_not_null" NOT NULL,
    "kubernetes-sigs/pspmigrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/pspmigrato_not_null" NOT NULL,
    "kubernetes-sigs/logtools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/logtools_not_null" NOT NULL,
    "kubernetes-sigs/json" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes-sigs/json_not_null" NOT NULL,
    "kubernetes-sigs/ingate" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-sigs/ingate_not_null" NOT NULL,
    "kubernetes-sigs/kubectl-check-ownerreferences" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kubectl-ch_not_null" NOT NULL,
    "kubernetes/cloud-provider-sample" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/cloud-provider-_not_null6" NOT NULL,
    "kubernetes/kubernetes-docs-cn" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/kubernetes-docs_not_null1" NOT NULL,
    "kubernetes-sigs/gluster-block-external-provisioner" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/gluster-bl_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-zh" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-retired/kuberne_not_null" NOT NULL,
    "kubernetes/funding" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/kube-arbitrator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-incubator/kube-_not_null1" NOT NULL,
    "kubernetes/pr-bot" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-incubator/cri-o" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/cri-o_not_null" NOT NULL,
    "kubernetes-sigs/cloud-provider-baiducloud" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cloud-prov_not_null4" NOT NULL,
    "kubernetes-sigs/kube-agentic-networking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/kube-agent_not_null" NOT NULL,
    "kubernetes-sigs/release-actions" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/release-ac_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-flex" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/csi-driver-_not_null5" NOT NULL,
    "kubernetes-sigs/container-object-storage-interface-spec" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/container-_not_null4" NOT NULL,
    "kubernetes-csi/csi-driver-fibre-channel" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/csi-driver-_not_null6" NOT NULL,
    "kubernetes-sigs/dra-driver-topology" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/dra-driver_not_null" NOT NULL,
    "kubernetes-incubator/cluster-capacity" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-incubator/clust_not_null1" NOT NULL,
    "kubernetes/kubernetes-docs-ko" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/kubernetes-docs_not_null2" NOT NULL,
    "kubernetes-sigs/referencegrant-poc" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/referenceg_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-ja" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-retired/kuberne_not_null1" NOT NULL,
    "kubernetes-client/perl" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-client/perl_not_null" NOT NULL,
    "kubernetes/kubernetes-docs-ja" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes/kubernetes-docs_not_null3" NOT NULL,
    "kubernetes-sigs/slack-infra" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/slack-infr_not_null" NOT NULL,
    "kubernetes-sig-testing/frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sig-testing/fra_not_null" NOT NULL,
    "kubernetes-retired/kubernetes-docs-ko" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-retired/kuberne_not_null2" NOT NULL,
    "kubernetes-sigs/volcano" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes-sigs/volcano_not_null" NOT NULL,
    "kubernetes-sigs/testgrid-json-exporter" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/testgrid-j_not_null" NOT NULL,
    "kubernetes-sigs/release-team-shadow-stats" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/release-te_not_null" NOT NULL,
    "kubernetes/sig-testing" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes/sig-testing_not_null" NOT NULL,
    "kubernetes-sigs/llm-instance-gateway" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/llm-instan_not_null" NOT NULL,
    "kubernetes-csi/kubernetes-csi.github.io" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/kubernetes-_not_null1" NOT NULL,
    "kubernetes-sigs/addon-operators" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/addon-oper_not_null" NOT NULL,
    "kubernetes-incubator/cluster-proportional-vertical-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-incubator/clust_not_null2" NOT NULL,
    "kubernetes-incubator/custom-metrics-apiserver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/custo_not_null" NOT NULL,
    "kubernetes-sigs/iptables-wrappers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/iptables-w_not_null" NOT NULL,
    "kubernetes/node-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/node-api_not_null" NOT NULL,
    "kubernetes-client/go-base" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-client/go-base_not_null" NOT NULL,
    "kubernetes-csi/csi-driver-image-populator" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-csi/csi-driver-_not_null7" NOT NULL,
    "kubernetes-sigs/sig-usability" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/sig-usabil_not_null" NOT NULL,
    "kubernetes-sigs/wg-ai-gateway" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/wg-ai-gate_not_null" NOT NULL,
    "kubernetes/application-images" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/application-ima_not_null" NOT NULL,
    "kubernetes-sigs/cve-feed-osv" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/cve-feed-o_not_null" NOT NULL,
    "kubernetes-sigs/obscli" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-sigs/obscli_not_null" NOT NULL,
    "kubernetes-sigs/externalip-webhook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/externalip_not_null" NOT NULL,
    "kubernetes/cluster-bootstrap" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/cluster-bootstr_not_null" NOT NULL,
    "kubernetes-sigs/aws-file-cache-csi-driver" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws-file-c_not_null" NOT NULL,
    "kubernetes-sigs/porche" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-sigs/porche_not_null" NOT NULL,
    "kubernetes-sigs/relnotes" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/relnotes_not_null" NOT NULL,
    "kubernetes-incubator/spartakus" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-incubator/spart_not_null" NOT NULL,
    "kubernetes-client/typescript" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-client/typescri_not_null" NOT NULL,
    "kubernetes-incubator/kube-mesos-framework" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-incubator/kube-_not_null2" NOT NULL,
    "kubernetes-security/cvelist-public" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-security/cvelis_not_null" NOT NULL,
    "kubernetes/kms" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/k8s-gsm-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/k8s-gsm-to_not_null" NOT NULL,
    "kubernetes/kube-ui" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/windows-service-proxy" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/windows-se_not_null" NOT NULL,
    "kubernetes-sigs/logical-cluster" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/logical-cl_not_null" NOT NULL,
    "kubernetes/console" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/md-check" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes/md-check_not_null" NOT NULL,
    "kubernetes-sigs/noderesourcetopology-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/noderesour_not_null" NOT NULL,
    "kubernetes-csi/csi-lib-fc" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes-csi/csi-lib-fc_not_null" NOT NULL,
    "kubernetes-retired/kube-ui" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-retired/kube-ui_not_null" NOT NULL,
    "kubernetes-sigs/contributor-katacoda" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/contributo_not_null3" NOT NULL,
    "kubernetes/kubernetes-console" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/kubernetes-cons_not_null" NOT NULL,
    "kubernetes-sigs/dra-driver-cpu" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/dra-driver_not_null1" NOT NULL,
    "kubernetes-client/community" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-client/communit_not_null" NOT NULL,
    "kubernetes-sigs/instrumentation-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/instrument_not_null1" NOT NULL,
    "kubernetes-sigs/mutating-trace-admission-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/mutating-t_not_null" NOT NULL,
    "kubernetes/common" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/sigs-github-actions" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/sigs-githu_not_null" NOT NULL,
    "kubernetes-sigs/signalhound" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/signalhoun_not_null" NOT NULL,
    "kubernetes-sigs/node-readiness-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/node-readi_not_null" NOT NULL,
    "kubernetes-sigs/maintainer-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/maintainer_not_null1" NOT NULL,
    "kubernetes/cloud-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes/cloud-provider_not_null" NOT NULL,
    "kubernetes/component-helpers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/component-helpe_not_null" NOT NULL,
    "kubernetes-sigs/dranet" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes-sigs/dranet_not_null" NOT NULL,
    "kubernetes-retired/testing_frameworks" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-retired/testing_not_null" NOT NULL,
    "kubernetes-sigs/architecture-tracking" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/architectu_not_null" NOT NULL,
    "kubernetes-sigs/execution-hook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/execution-_not_null" NOT NULL,
    "kubernetes/cel-admission-webhook" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/cel-admission-w_not_null" NOT NULL,
    "kubernetes-sigs/discuss-theme" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/discuss-th_not_null" NOT NULL,
    "kubernetes/component-base" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_kubernetes/component-base_not_null" NOT NULL,
    "kubernetes-sigs/minikube-preloads" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/minikube-p_not_null" NOT NULL,
    "kubernetes/csi-translation-lib" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/csi-translation_not_null" NOT NULL,
    "kubernetes-sigs/sig-auth-tools" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/sig-auth-t_not_null" NOT NULL,
    "kubernetes-sigs/instrumentation" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/instrument_not_null2" NOT NULL,
    "kubernetes-sigs/sig-windows-samples" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/sig-window_not_null2" NOT NULL,
    "kubernetes/cluster-proportional-autoscaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/cluster-proport_not_null" NOT NULL,
    "kubernetes/.github" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes/legacy-cloud-providers" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/legacy-cloud-pr_not_null" NOT NULL,
    "kubernetes/mount-utils" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_ne_kubernetes/mount-utils_not_null" NOT NULL,
    "kubernetes/controller-manager" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/controller-mana_not_null" NOT NULL,
    "kubernetes-csi/resources" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-csi/resources_not_null" NOT NULL,
    "kubernetes-retired/community" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-retired/communi_not_null" NOT NULL,
    "kubernetes/cri-api" double precision DEFAULT 0.0 NOT NULL,
    "kubernetes-sigs/scheduling_poseidon" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/scheduling_not_null" NOT NULL,
    "kubernetes-sigs/clientgofix" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/clientgofi_not_null" NOT NULL,
    "kubernetes-sigs/randfill" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label__kubernetes-sigs/randfill_not_null" NOT NULL,
    "kubernetes/horizontal-self-scaler" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes/horizontal-self_not_null" NOT NULL,
    "kubernetes-sigs/alb-ingress-controller" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/alb-ingres_not_null" NOT NULL,
    "kubernetes-sigs/.github" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_n_kubernetes-sigs/.github_not_null" NOT NULL,
    "kubernetes-sigs/foo" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_neede_kubernetes-sigs/foo_not_null" NOT NULL,
    "kubernetes-sigs/multi-network-api" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/multi-netw_not_null1" NOT NULL,
    "kubernetes-sigs/aws_encryption-provider" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/aws_encryp_not_null" NOT NULL,
    "kubernetes-sigs/apps_application" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-sigs/apps_appli_not_null" NOT NULL,
    "kubernetes-sigs/cosi-driver-minio" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_lab_kubernetes-sigs/cosi-drive_not_null1" NOT NULL,
    "kubernetes-graveyard/md-check" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_labe_kubernetes-graveyard/md-ch_not_null" NOT NULL,
    "kubernetes/md-format" double precision DEFAULT 0.0 CONSTRAINT "spreprblckrelease_note_label_need_kubernetes/md-format_not_null" NOT NULL
);


ALTER TABLE public.spreprblckrelease_note_label_needed OWNER TO gha_admin;

--
-- Name: sprs_age; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprs_age (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    descr text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.sprs_age OWNER TO gha_admin;

--
-- Name: sprs_age_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprs_age_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    descr text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.sprs_age_repos OWNER TO gha_admin;

--
-- Name: sprs_labels; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprs_labels (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprs_labels OWNER TO gha_admin;

--
-- Name: sprs_labels_by_sig; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprs_labels_by_sig (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprs_labels_by_sig OWNER TO gha_admin;

--
-- Name: sprs_labels_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprs_labels_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprs_labels_repos OWNER TO gha_admin;

--
-- Name: sprs_milestones; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.sprs_milestones (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.sprs_milestones OWNER TO gha_admin;

--
-- Name: spstat; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spstat (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    name text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.spstat OWNER TO gha_admin;

--
-- Name: spstat_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.spstat_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    name text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.spstat_repos OWNER TO gha_admin;

--
-- Name: ssig_pr_wlabs; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssig_pr_wlabs (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssig_pr_wlabs OWNER TO gha_admin;

--
-- Name: ssig_pr_wliss; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssig_pr_wliss (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssig_pr_wliss OWNER TO gha_admin;

--
-- Name: ssig_pr_wlrel; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssig_pr_wlrel (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssig_pr_wlrel OWNER TO gha_admin;

--
-- Name: ssig_pr_wlrev; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssig_pr_wlrev (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssig_pr_wlrev OWNER TO gha_admin;

--
-- Name: ssig_prs_open; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssig_prs_open (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssig_prs_open OWNER TO gha_admin;

--
-- Name: ssig_prs_open_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssig_prs_open_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    apps double precision DEFAULT 0.0 NOT NULL,
    "cloud-provider" double precision DEFAULT 0.0 NOT NULL,
    storage double precision DEFAULT 0.0 NOT NULL,
    auth double precision DEFAULT 0.0 NOT NULL,
    cli double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    multicluster double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience" double precision DEFAULT 0.0 NOT NULL,
    testing double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    "cluster-lifecycle" double precision DEFAULT 0.0 NOT NULL,
    scalability double precision DEFAULT 0.0 NOT NULL,
    docs double precision DEFAULT 0.0 NOT NULL,
    windows double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    instrumentation double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    autoscaling double precision DEFAULT 0.0 NOT NULL,
    security double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra" double precision DEFAULT 0.0 NOT NULL,
    etcd double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssig_prs_open_repos OWNER TO gha_admin;

--
-- Name: ssigm_lsk; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssigm_lsk (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssigm_lsk OWNER TO gha_admin;

--
-- Name: ssigm_lskr; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssigm_lskr (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssigm_lskr OWNER TO gha_admin;

--
-- Name: ssigm_txt; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ssigm_txt (
    "time" timestamp without time zone NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    "auth-leads" double precision DEFAULT 0.0 NOT NULL,
    scheduling double precision DEFAULT 0.0 NOT NULL,
    "api-machinery" double precision DEFAULT 0.0 NOT NULL,
    network double precision DEFAULT 0.0 NOT NULL,
    node double precision DEFAULT 0.0 NOT NULL,
    "docs-en" double precision DEFAULT 0.0 NOT NULL,
    "storage-leads" double precision DEFAULT 0.0 NOT NULL,
    release double precision DEFAULT 0.0 NOT NULL,
    "scheduling-leads" double precision DEFAULT 0.0 NOT NULL,
    "node-leads" double precision DEFAULT 0.0 NOT NULL,
    "node-cri-o-test-maintainers" double precision DEFAULT 0.0 NOT NULL,
    "docs-leads" double precision DEFAULT 0.0 NOT NULL,
    "release-leads" double precision DEFAULT 0.0 NOT NULL,
    "instrumentation-leads" double precision DEFAULT 0.0 NOT NULL,
    "scheduling-approvers" double precision DEFAULT 0.0 NOT NULL,
    "k8s-infra-leads" double precision DEFAULT 0.0 NOT NULL,
    architecture double precision DEFAULT 0.0 NOT NULL,
    "docs-id-reviews" double precision DEFAULT 0.0 NOT NULL,
    "testing-leads" double precision DEFAULT 0.0 NOT NULL,
    "contributor-experience-leads" double precision DEFAULT 0.0 NOT NULL,
    "api-machinery-leads" double precision DEFAULT 0.0 NOT NULL,
    "apps-leads" double precision DEFAULT 0.0 NOT NULL,
    "architecture-leads" double precision DEFAULT 0.0 NOT NULL,
    "network-leads" double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.ssigm_txt OWNER TO gha_admin;

--
-- Name: stime_metrics; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.stime_metrics (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    descr text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.stime_metrics OWNER TO gha_admin;

--
-- Name: stime_metrics_repos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.stime_metrics_repos (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL,
    descr text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.stime_metrics_repos OWNER TO gha_admin;

--
-- Name: suser_reviews; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.suser_reviews (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    pohly double precision DEFAULT 0.0 NOT NULL,
    yliaog double precision DEFAULT 0.0 NOT NULL,
    thockin double precision DEFAULT 0.0 NOT NULL,
    liggitt double precision DEFAULT 0.0 NOT NULL,
    janetkuo double precision DEFAULT 0.0 NOT NULL,
    ahmetb double precision DEFAULT 0.0 NOT NULL,
    danwinship double precision DEFAULT 0.0 NOT NULL,
    andyzhangx double precision DEFAULT 0.0 NOT NULL,
    neolit123 double precision DEFAULT 0.0 NOT NULL,
    "xing-yang" double precision DEFAULT 0.0 NOT NULL,
    "wojtek-t" double precision DEFAULT 0.0 NOT NULL,
    brendandburns double precision DEFAULT 0.0 NOT NULL,
    soltysh double precision DEFAULT 0.0 NOT NULL,
    yue9944882 double precision DEFAULT 0.0 NOT NULL,
    cpanato double precision DEFAULT 0.0 NOT NULL,
    "BenTheElder" double precision DEFAULT 0.0 NOT NULL,
    enj double precision DEFAULT 0.0 NOT NULL,
    jpbetz double precision DEFAULT 0.0 NOT NULL,
    serathius double precision DEFAULT 0.0 NOT NULL,
    bart0sh double precision DEFAULT 0.0 NOT NULL,
    justinsb double precision DEFAULT 0.0 NOT NULL,
    dims double precision DEFAULT 0.0 NOT NULL,
    gnufied double precision DEFAULT 0.0 NOT NULL,
    tallclair double precision DEFAULT 0.0 NOT NULL,
    fabriziopandini double precision DEFAULT 0.0 NOT NULL,
    tengqm double precision DEFAULT 0.0 NOT NULL,
    olekzabl double precision DEFAULT 0.0 NOT NULL,
    "aaron-prindle" double precision DEFAULT 0.0 NOT NULL,
    johnbelamaric double precision DEFAULT 0.0 NOT NULL,
    rikatz double precision DEFAULT 0.0 NOT NULL,
    stmcginnis double precision DEFAULT 0.0 NOT NULL,
    "AkihiroSuda" double precision DEFAULT 0.0 NOT NULL,
    divyenpatel double precision DEFAULT 0.0 NOT NULL,
    jackfrancis double precision DEFAULT 0.0 NOT NULL,
    "JoelSpeed" double precision DEFAULT 0.0 NOT NULL,
    mortent double precision DEFAULT 0.0 NOT NULL,
    aojea double precision DEFAULT 0.0 NOT NULL,
    saschagrunert double precision DEFAULT 0.0 NOT NULL,
    "ahg-g" double precision DEFAULT 0.0 NOT NULL,
    robscott double precision DEFAULT 0.0 NOT NULL,
    mboersma double precision DEFAULT 0.0 NOT NULL,
    ameukam double precision DEFAULT 0.0 NOT NULL,
    sbueringer double precision DEFAULT 0.0 NOT NULL,
    "barney-s" double precision DEFAULT 0.0 NOT NULL,
    "seokho-son" double precision DEFAULT 0.0 NOT NULL,
    camilamacedo86 double precision DEFAULT 0.0 NOT NULL,
    medyagh double precision DEFAULT 0.0 NOT NULL,
    haircommander double precision DEFAULT 0.0 NOT NULL,
    hakman double precision DEFAULT 0.0 NOT NULL,
    chrischdi double precision DEFAULT 0.0 NOT NULL,
    elmiko double precision DEFAULT 0.0 NOT NULL,
    "SergeyKanzhelev" double precision DEFAULT 0.0 NOT NULL,
    ellistarn double precision DEFAULT 0.0 NOT NULL,
    youngnick double precision DEFAULT 0.0 NOT NULL,
    helayoty double precision DEFAULT 0.0 NOT NULL,
    natasha41575 double precision DEFAULT 0.0 NOT NULL,
    alaypatel07 double precision DEFAULT 0.0 NOT NULL,
    andreyvelich double precision DEFAULT 0.0 NOT NULL,
    "Priyankasaggu11929" double precision DEFAULT 0.0 NOT NULL,
    "capri-xiyue" double precision DEFAULT 0.0 NOT NULL,
    "t-inu" double precision DEFAULT 0.0 NOT NULL,
    lentzi90 double precision DEFAULT 0.0 NOT NULL,
    sanposhiho double precision DEFAULT 0.0 NOT NULL,
    "Karthik-K-N" double precision DEFAULT 0.0 NOT NULL,
    upodroid double precision DEFAULT 0.0 NOT NULL,
    adrianmoisey double precision DEFAULT 0.0 NOT NULL,
    windsonsea double precision DEFAULT 0.0 NOT NULL,
    "tenzen-y" double precision DEFAULT 0.0 NOT NULL,
    "LiorLieberman" double precision DEFAULT 0.0 NOT NULL,
    nojnhuh double precision DEFAULT 0.0 NOT NULL,
    kannon92 double precision DEFAULT 0.0 NOT NULL,
    mimowo double precision DEFAULT 0.0 NOT NULL,
    sunnylovestiramisu double precision DEFAULT 0.0 NOT NULL,
    "HirazawaUi" double precision DEFAULT 0.0 NOT NULL,
    "Gacko" double precision DEFAULT 0.0 NOT NULL,
    "dipesh-rawat" double precision DEFAULT 0.0 NOT NULL,
    ffromani double precision DEFAULT 0.0 NOT NULL,
    nirs double precision DEFAULT 0.0 NOT NULL,
    mloiseleur double precision DEFAULT 0.0 NOT NULL,
    zhanggbj double precision DEFAULT 0.0 NOT NULL,
    michaelasp double precision DEFAULT 0.0 NOT NULL,
    huww98 double precision DEFAULT 0.0 NOT NULL,
    "a-hilaly" double precision DEFAULT 0.0 NOT NULL,
    vicentefb double precision DEFAULT 0.0 NOT NULL,
    "PBundyra" double precision DEFAULT 0.0 NOT NULL,
    jakobmoellerdev double precision DEFAULT 0.0 NOT NULL,
    larhauga double precision DEFAULT 0.0 NOT NULL,
    shraddhabang double precision DEFAULT 0.0 NOT NULL,
    jmdeal double precision DEFAULT 0.0 NOT NULL,
    tico88612 double precision DEFAULT 0.0 NOT NULL,
    "Andygol" double precision DEFAULT 0.0 NOT NULL,
    richabanker double precision DEFAULT 0.0 NOT NULL,
    mszadkow double precision DEFAULT 0.0 NOT NULL,
    mbobrovskyi double precision DEFAULT 0.0 NOT NULL,
    omerap12 double precision DEFAULT 0.0 NOT NULL,
    esotsal double precision DEFAULT 0.0 NOT NULL,
    "IrvingMg" double precision DEFAULT 0.0 NOT NULL,
    macsko double precision DEFAULT 0.0 NOT NULL,
    yongruilin double precision DEFAULT 0.0 NOT NULL,
    dom4ha double precision DEFAULT 0.0 NOT NULL,
    kfswain double precision DEFAULT 0.0 NOT NULL,
    xirehat double precision DEFAULT 0.0 NOT NULL,
    "GiuseppeTT" double precision DEFAULT 0.0 NOT NULL,
    ivankatliarchuk double precision DEFAULT 0.0 NOT NULL,
    "zac-nixon" double precision DEFAULT 0.0 NOT NULL,
    lmktfy double precision DEFAULT 0.0 NOT NULL,
    "KevinTMtz" double precision DEFAULT 0.0 NOT NULL,
    illume double precision DEFAULT 0.0 NOT NULL,
    "BenjaminBraunDev" double precision DEFAULT 0.0 NOT NULL,
    "Copilot" double precision DEFAULT 0.0 NOT NULL,
    "DerekFrank" double precision DEFAULT 0.0 NOT NULL,
    "graz-dev" double precision DEFAULT 0.0 NOT NULL,
    skoeva double precision DEFAULT 0.0 NOT NULL,
    nirrozenbaum double precision DEFAULT 0.0 NOT NULL,
    pravk03 double precision DEFAULT 0.0 NOT NULL,
    lalitc375 double precision DEFAULT 0.0 NOT NULL,
    bwsalmon double precision DEFAULT 0.0 NOT NULL,
    peterzhongyi double precision DEFAULT 0.0 NOT NULL,
    kshalot double precision DEFAULT 0.0 NOT NULL,
    "JesusMtnez" double precision DEFAULT 0.0 NOT NULL,
    kfess double precision DEFAULT 0.0 NOT NULL,
    pfeifferj double precision DEFAULT 0.0 NOT NULL,
    "ConnorJC3" double precision DEFAULT 0.0 NOT NULL,
    ardaguclu double precision DEFAULT 0.0 NOT NULL,
    igooch double precision DEFAULT 0.0 NOT NULL,
    ianychoi double precision DEFAULT 0.0 NOT NULL,
    carlory double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.suser_reviews OWNER TO gha_admin;

--
-- Name: swatchers; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.swatchers (
    "time" timestamp without time zone NOT NULL,
    series text NOT NULL,
    period text DEFAULT ''::text NOT NULL,
    value double precision DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.swatchers OWNER TO gha_admin;

--
-- Name: tall_combined_repo_groups; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tall_combined_repo_groups (
    "time" timestamp without time zone NOT NULL,
    all_combined_repo_group_name text,
    all_combined_repo_group_value text
);


ALTER TABLE public.tall_combined_repo_groups OWNER TO gha_admin;

--
-- Name: tall_milestones; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tall_milestones (
    "time" timestamp without time zone NOT NULL,
    all_milestones_value text,
    all_milestones_name text
);


ALTER TABLE public.tall_milestones OWNER TO gha_admin;

--
-- Name: tall_repo_groups; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tall_repo_groups (
    "time" timestamp without time zone NOT NULL,
    all_repo_group_value text,
    all_repo_group_name text
);


ALTER TABLE public.tall_repo_groups OWNER TO gha_admin;

--
-- Name: tall_repo_names; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tall_repo_names (
    "time" timestamp without time zone NOT NULL,
    all_repo_names_value text,
    all_repo_names_name text
);


ALTER TABLE public.tall_repo_names OWNER TO gha_admin;

--
-- Name: tbot_commands; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tbot_commands (
    "time" timestamp without time zone NOT NULL,
    bot_command_name text
);


ALTER TABLE public.tbot_commands OWNER TO gha_admin;

--
-- Name: tcompanies; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tcompanies (
    "time" timestamp without time zone NOT NULL,
    companies_name text,
    companies_value text
);


ALTER TABLE public.tcompanies OWNER TO gha_admin;

--
-- Name: tcountries; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tcountries (
    "time" timestamp without time zone NOT NULL,
    country_value text,
    country_name text
);


ALTER TABLE public.tcountries OWNER TO gha_admin;

--
-- Name: tcumperiods; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tcumperiods (
    "time" timestamp without time zone NOT NULL,
    cumperiod_name text
);


ALTER TABLE public.tcumperiods OWNER TO gha_admin;

--
-- Name: tlanguages; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tlanguages (
    "time" timestamp without time zone NOT NULL,
    lang_name text
);


ALTER TABLE public.tlanguages OWNER TO gha_admin;

--
-- Name: tlicenses; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tlicenses (
    "time" timestamp without time zone NOT NULL,
    license_name text
);


ALTER TABLE public.tlicenses OWNER TO gha_admin;

--
-- Name: tpr_labels_tags; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tpr_labels_tags (
    "time" timestamp without time zone NOT NULL,
    pr_labels_tags_name text,
    pr_labels_tags_value text
);


ALTER TABLE public.tpr_labels_tags OWNER TO gha_admin;

--
-- Name: tpriority_labels_with_all; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tpriority_labels_with_all (
    "time" timestamp without time zone NOT NULL,
    priority_labels_value_with_all text,
    priority_labels_name_with_all text
);


ALTER TABLE public.tpriority_labels_with_all OWNER TO gha_admin;

--
-- Name: tquick_ranges; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tquick_ranges (
    "time" timestamp without time zone NOT NULL,
    quick_ranges_data text,
    quick_ranges_suffix text,
    quick_ranges_name text
);


ALTER TABLE public.tquick_ranges OWNER TO gha_admin;

--
-- Name: trepo_groups; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.trepo_groups (
    "time" timestamp without time zone NOT NULL,
    repo_group_name text,
    repo_group_value text
);


ALTER TABLE public.trepo_groups OWNER TO gha_admin;

--
-- Name: trepos; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.trepos (
    "time" timestamp without time zone NOT NULL,
    repo_name text,
    repo_value text
);


ALTER TABLE public.trepos OWNER TO gha_admin;

--
-- Name: treviewers; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.treviewers (
    "time" timestamp without time zone NOT NULL,
    reviewers_name text
);


ALTER TABLE public.treviewers OWNER TO gha_admin;

--
-- Name: tsig_mentions_labels; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tsig_mentions_labels (
    "time" timestamp without time zone NOT NULL,
    sig_mentions_labels_name text,
    sig_mentions_labels_value text
);


ALTER TABLE public.tsig_mentions_labels OWNER TO gha_admin;

--
-- Name: tsig_mentions_labels_with_all; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tsig_mentions_labels_with_all (
    "time" timestamp without time zone NOT NULL,
    sig_mentions_labels_name_with_all text,
    sig_mentions_labels_value_with_all text
);


ALTER TABLE public.tsig_mentions_labels_with_all OWNER TO gha_admin;

--
-- Name: tsig_mentions_texts; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tsig_mentions_texts (
    "time" timestamp without time zone NOT NULL,
    sig_mentions_texts_name text,
    sig_mentions_texts_value text
);


ALTER TABLE public.tsig_mentions_texts OWNER TO gha_admin;

--
-- Name: tsigm_lbl_kinds; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tsigm_lbl_kinds (
    "time" timestamp without time zone NOT NULL,
    sigm_lbl_kind_name text,
    sigm_lbl_kind_value text
);


ALTER TABLE public.tsigm_lbl_kinds OWNER TO gha_admin;

--
-- Name: tsigm_lbl_kinds_with_all; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tsigm_lbl_kinds_with_all (
    "time" timestamp without time zone NOT NULL,
    sigm_lbl_kind_name_with_all text,
    sigm_lbl_kind_value_with_all text
);


ALTER TABLE public.tsigm_lbl_kinds_with_all OWNER TO gha_admin;

--
-- Name: tsize_labels_with_all; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tsize_labels_with_all (
    "time" timestamp without time zone NOT NULL,
    size_labels_name_with_all text,
    size_labels_value_with_all text
);


ALTER TABLE public.tsize_labels_with_all OWNER TO gha_admin;

--
-- Name: ttop_repo_names; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ttop_repo_names (
    "time" timestamp without time zone NOT NULL,
    top_repo_names_name text,
    top_repo_names_value text
);


ALTER TABLE public.ttop_repo_names OWNER TO gha_admin;

--
-- Name: ttop_repo_names_with_all; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ttop_repo_names_with_all (
    "time" timestamp without time zone NOT NULL,
    top_repo_names_value_with_all text,
    top_repo_names_name_with_all text
);


ALTER TABLE public.ttop_repo_names_with_all OWNER TO gha_admin;

--
-- Name: ttop_repos_with_all; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.ttop_repos_with_all (
    "time" timestamp without time zone NOT NULL,
    top_repos_name_with_all text,
    top_repos_value_with_all text
);


ALTER TABLE public.ttop_repos_with_all OWNER TO gha_admin;

--
-- Name: tusers; Type: TABLE; Schema: public; Owner: gha_admin
--

CREATE TABLE public.tusers (
    "time" timestamp without time zone NOT NULL,
    users_name text
);


ALTER TABLE public.tusers OWNER TO gha_admin;

--
-- Name: gha_logs id; Type: DEFAULT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_logs ALTER COLUMN id SET DEFAULT nextval('public.gha_logs_id_seq'::regclass);


--
-- Name: gha_actors_affiliations gha_actors_affiliations_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_actors_affiliations
    ADD CONSTRAINT gha_actors_affiliations_pkey PRIMARY KEY (actor_id, company_name, dt_from, dt_to);


--
-- Name: gha_actors_emails gha_actors_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_actors_emails
    ADD CONSTRAINT gha_actors_emails_pkey PRIMARY KEY (actor_id, email);


--
-- Name: gha_actors_names gha_actors_names_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_actors_names
    ADD CONSTRAINT gha_actors_names_pkey PRIMARY KEY (actor_id, name);


--
-- Name: gha_actors gha_actors_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_actors
    ADD CONSTRAINT gha_actors_pkey PRIMARY KEY (id, login);


--
-- Name: gha_assets gha_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_assets
    ADD CONSTRAINT gha_assets_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_bot_logins gha_bot_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_bot_logins
    ADD CONSTRAINT gha_bot_logins_pkey PRIMARY KEY (pattern);


--
-- Name: gha_branches gha_branches_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_branches
    ADD CONSTRAINT gha_branches_pkey PRIMARY KEY (sha, event_id);


--
-- Name: gha_comments gha_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_comments
    ADD CONSTRAINT gha_comments_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_commits_files gha_commits_files_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_commits_files
    ADD CONSTRAINT gha_commits_files_pkey PRIMARY KEY (sha, path);


--
-- Name: gha_commits gha_commits_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_commits
    ADD CONSTRAINT gha_commits_pkey PRIMARY KEY (sha, event_id);


--
-- Name: gha_commits_roles gha_commits_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_commits_roles
    ADD CONSTRAINT gha_commits_roles_pkey PRIMARY KEY (sha, event_id, role);


--
-- Name: gha_companies gha_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_companies
    ADD CONSTRAINT gha_companies_pkey PRIMARY KEY (name);


--
-- Name: gha_computed gha_computed_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_computed
    ADD CONSTRAINT gha_computed_pkey PRIMARY KEY (metric, dt);


--
-- Name: gha_countries gha_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_countries
    ADD CONSTRAINT gha_countries_pkey PRIMARY KEY (code);


--
-- Name: gha_events_commits_files gha_events_commits_files_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_events_commits_files
    ADD CONSTRAINT gha_events_commits_files_pkey PRIMARY KEY (sha, event_id, path);


--
-- Name: gha_events gha_events_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_events
    ADD CONSTRAINT gha_events_pkey PRIMARY KEY (id);


--
-- Name: gha_forkees gha_forkees_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_forkees
    ADD CONSTRAINT gha_forkees_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_imported_shas gha_imported_shas_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_imported_shas
    ADD CONSTRAINT gha_imported_shas_pkey PRIMARY KEY (sha);


--
-- Name: gha_issues_assignees gha_issues_assignees_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_issues_assignees
    ADD CONSTRAINT gha_issues_assignees_pkey PRIMARY KEY (issue_id, event_id, assignee_id);


--
-- Name: gha_issues_events_labels gha_issues_events_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_issues_events_labels
    ADD CONSTRAINT gha_issues_events_labels_pkey PRIMARY KEY (issue_id, event_id, label_id);


--
-- Name: gha_issues_labels gha_issues_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_issues_labels
    ADD CONSTRAINT gha_issues_labels_pkey PRIMARY KEY (issue_id, event_id, label_id);


--
-- Name: gha_issues gha_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_issues
    ADD CONSTRAINT gha_issues_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_labels gha_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_labels
    ADD CONSTRAINT gha_labels_pkey PRIMARY KEY (id);


--
-- Name: gha_last_computed gha_last_computed_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_last_computed
    ADD CONSTRAINT gha_last_computed_pkey PRIMARY KEY (metric);


--
-- Name: gha_milestones gha_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_milestones
    ADD CONSTRAINT gha_milestones_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_orgs gha_orgs_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_orgs
    ADD CONSTRAINT gha_orgs_pkey PRIMARY KEY (id);


--
-- Name: gha_pages gha_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_pages
    ADD CONSTRAINT gha_pages_pkey PRIMARY KEY (sha, event_id, action, title);


--
-- Name: gha_parsed gha_parsed_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_parsed
    ADD CONSTRAINT gha_parsed_pkey PRIMARY KEY (dt);


--
-- Name: gha_payloads gha_payloads_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_payloads
    ADD CONSTRAINT gha_payloads_pkey PRIMARY KEY (event_id);


--
-- Name: gha_postprocess_scripts gha_postprocess_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_postprocess_scripts
    ADD CONSTRAINT gha_postprocess_scripts_pkey PRIMARY KEY (ord, path);


--
-- Name: gha_pull_requests_assignees gha_pull_requests_assignees_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_pull_requests_assignees
    ADD CONSTRAINT gha_pull_requests_assignees_pkey PRIMARY KEY (pull_request_id, event_id, assignee_id);


--
-- Name: gha_pull_requests gha_pull_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_pull_requests
    ADD CONSTRAINT gha_pull_requests_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_pull_requests_requested_reviewers gha_pull_requests_requested_reviewers_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_pull_requests_requested_reviewers
    ADD CONSTRAINT gha_pull_requests_requested_reviewers_pkey PRIMARY KEY (pull_request_id, event_id, requested_reviewer_id);


--
-- Name: gha_releases_assets gha_releases_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_releases_assets
    ADD CONSTRAINT gha_releases_assets_pkey PRIMARY KEY (release_id, event_id, asset_id);


--
-- Name: gha_releases gha_releases_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_releases
    ADD CONSTRAINT gha_releases_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_repo_groups gha_repo_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_repo_groups
    ADD CONSTRAINT gha_repo_groups_pkey PRIMARY KEY (id, name, repo_group);


--
-- Name: gha_repos_langs gha_repos_langs_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_repos_langs
    ADD CONSTRAINT gha_repos_langs_pkey PRIMARY KEY (repo_name, lang_name);


--
-- Name: gha_repos gha_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_repos
    ADD CONSTRAINT gha_repos_pkey PRIMARY KEY (id, name);


--
-- Name: gha_reviews gha_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_reviews
    ADD CONSTRAINT gha_reviews_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_skip_commits gha_skip_commits_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_skip_commits
    ADD CONSTRAINT gha_skip_commits_pkey PRIMARY KEY (sha, reason);


--
-- Name: gha_teams gha_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_teams
    ADD CONSTRAINT gha_teams_pkey PRIMARY KEY (id, event_id);


--
-- Name: gha_teams_repositories gha_teams_repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_teams_repositories
    ADD CONSTRAINT gha_teams_repositories_pkey PRIMARY KEY (team_id, event_id, repository_id);


--
-- Name: gha_vars gha_vars_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.gha_vars
    ADD CONSTRAINT gha_vars_pkey PRIMARY KEY (name);


--
-- Name: sannotations sannotations_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sannotations
    ADD CONSTRAINT sannotations_pkey PRIMARY KEY ("time", period);


--
-- Name: sawaiting_prs_by_sig_repos sawaiting_prs_by_sig_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sawaiting_prs_by_sig_repos
    ADD CONSTRAINT sawaiting_prs_by_sig_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sawaiting_prs_by_sigd10 sawaiting_prs_by_sigd10_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sawaiting_prs_by_sigd10
    ADD CONSTRAINT sawaiting_prs_by_sigd10_pkey PRIMARY KEY ("time", period);


--
-- Name: sawaiting_prs_by_sigd30 sawaiting_prs_by_sigd30_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sawaiting_prs_by_sigd30
    ADD CONSTRAINT sawaiting_prs_by_sigd30_pkey PRIMARY KEY ("time", period);


--
-- Name: sawaiting_prs_by_sigd60 sawaiting_prs_by_sigd60_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sawaiting_prs_by_sigd60
    ADD CONSTRAINT sawaiting_prs_by_sigd60_pkey PRIMARY KEY ("time", period);


--
-- Name: sawaiting_prs_by_sigd90 sawaiting_prs_by_sigd90_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sawaiting_prs_by_sigd90
    ADD CONSTRAINT sawaiting_prs_by_sigd90_pkey PRIMARY KEY ("time", period);


--
-- Name: sawaiting_prs_by_sigy sawaiting_prs_by_sigy_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sawaiting_prs_by_sigy
    ADD CONSTRAINT sawaiting_prs_by_sigy_pkey PRIMARY KEY ("time", period);


--
-- Name: sbot_commands sbot_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sbot_commands
    ADD CONSTRAINT sbot_commands_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sbot_commands_repos sbot_commands_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sbot_commands_repos
    ADD CONSTRAINT sbot_commands_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: scntrs_and_orgs scntrs_and_orgs_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.scntrs_and_orgs
    ADD CONSTRAINT scntrs_and_orgs_pkey PRIMARY KEY ("time", series, period);


--
-- Name: scompany_activity scompany_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.scompany_activity
    ADD CONSTRAINT scompany_activity_pkey PRIMARY KEY ("time", series, period);


--
-- Name: scompany_activity_repos scompany_activity_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.scompany_activity_repos
    ADD CONSTRAINT scompany_activity_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: scompany_prs_repos scompany_prs_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.scompany_prs_repos
    ADD CONSTRAINT scompany_prs_repos_pkey PRIMARY KEY ("time", period);


--
-- Name: scountries scountries_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.scountries
    ADD CONSTRAINT scountries_pkey PRIMARY KEY ("time", series, period);


--
-- Name: scountriescum scountriescum_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.scountriescum
    ADD CONSTRAINT scountriescum_pkey PRIMARY KEY ("time", series, period);


--
-- Name: scs scs_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.scs
    ADD CONSTRAINT scs_pkey PRIMARY KEY ("time", series, period);


--
-- Name: scsr scsr_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.scsr
    ADD CONSTRAINT scsr_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sepisodic_contributors sepisodic_contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sepisodic_contributors
    ADD CONSTRAINT sepisodic_contributors_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sepisodic_contributors_repos sepisodic_contributors_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sepisodic_contributors_repos
    ADD CONSTRAINT sepisodic_contributors_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sepisodic_issues sepisodic_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sepisodic_issues
    ADD CONSTRAINT sepisodic_issues_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sepisodic_issues_repos sepisodic_issues_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sepisodic_issues_repos
    ADD CONSTRAINT sepisodic_issues_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sevents_h sevents_h_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sevents_h
    ADD CONSTRAINT sevents_h_pkey PRIMARY KEY ("time", period);


--
-- Name: sfirst_non_author sfirst_non_author_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sfirst_non_author
    ADD CONSTRAINT sfirst_non_author_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sfirst_non_author_repos sfirst_non_author_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sfirst_non_author_repos
    ADD CONSTRAINT sfirst_non_author_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sgh_stats_r sgh_stats_r_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sgh_stats_r
    ADD CONSTRAINT sgh_stats_r_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sgh_stats_rgrp sgh_stats_rgrp_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sgh_stats_rgrp
    ADD CONSTRAINT sgh_stats_rgrp_pkey PRIMARY KEY ("time", series, period);


--
-- Name: shcom shcom_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.shcom
    ADD CONSTRAINT shcom_pkey PRIMARY KEY ("time", series, period);


--
-- Name: shdev shdev_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.shdev
    ADD CONSTRAINT shdev_pkey PRIMARY KEY ("time", series, period);


--
-- Name: shdev_repos shdev_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.shdev_repos
    ADD CONSTRAINT shdev_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: shpr_mergers shpr_mergers_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.shpr_mergers
    ADD CONSTRAINT shpr_mergers_pkey PRIMARY KEY ("time", series, period);


--
-- Name: shpr_wlsigs shpr_wlsigs_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.shpr_wlsigs
    ADD CONSTRAINT shpr_wlsigs_pkey PRIMARY KEY ("time", period);


--
-- Name: shpr_wrlsigs shpr_wrlsigs_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.shpr_wrlsigs
    ADD CONSTRAINT shpr_wrlsigs_pkey PRIMARY KEY ("time", period);


--
-- Name: siclosed_lsk siclosed_lsk_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.siclosed_lsk
    ADD CONSTRAINT siclosed_lsk_pkey PRIMARY KEY ("time", series, period);


--
-- Name: siclosed_lskr siclosed_lskr_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.siclosed_lskr
    ADD CONSTRAINT siclosed_lskr_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sinactive_issues_by_sig_repos sinactive_issues_by_sig_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sinactive_issues_by_sig_repos
    ADD CONSTRAINT sinactive_issues_by_sig_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sinactive_issues_by_sigd30 sinactive_issues_by_sigd30_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sinactive_issues_by_sigd30
    ADD CONSTRAINT sinactive_issues_by_sigd30_pkey PRIMARY KEY ("time", period);


--
-- Name: sinactive_issues_by_sigd90 sinactive_issues_by_sigd90_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sinactive_issues_by_sigd90
    ADD CONSTRAINT sinactive_issues_by_sigd90_pkey PRIMARY KEY ("time", period);


--
-- Name: sinactive_issues_by_sigw2 sinactive_issues_by_sigw2_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sinactive_issues_by_sigw2
    ADD CONSTRAINT sinactive_issues_by_sigw2_pkey PRIMARY KEY ("time", period);


--
-- Name: sinactive_prs_by_sig_repos sinactive_prs_by_sig_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sinactive_prs_by_sig_repos
    ADD CONSTRAINT sinactive_prs_by_sig_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sinactive_prs_by_sigd30 sinactive_prs_by_sigd30_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sinactive_prs_by_sigd30
    ADD CONSTRAINT sinactive_prs_by_sigd30_pkey PRIMARY KEY ("time", period);


--
-- Name: sinactive_prs_by_sigd90 sinactive_prs_by_sigd90_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sinactive_prs_by_sigd90
    ADD CONSTRAINT sinactive_prs_by_sigd90_pkey PRIMARY KEY ("time", period);


--
-- Name: sinactive_prs_by_sigw2 sinactive_prs_by_sigw2_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sinactive_prs_by_sigw2
    ADD CONSTRAINT sinactive_prs_by_sigw2_pkey PRIMARY KEY ("time", period);


--
-- Name: sissues_age sissues_age_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sissues_age
    ADD CONSTRAINT sissues_age_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sissues_age_repos sissues_age_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sissues_age_repos
    ADD CONSTRAINT sissues_age_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sissues_milestones sissues_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sissues_milestones
    ADD CONSTRAINT sissues_milestones_pkey PRIMARY KEY ("time", series, period);


--
-- Name: snew_contributors_data snew_contributors_data_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.snew_contributors_data
    ADD CONSTRAINT snew_contributors_data_pkey PRIMARY KEY ("time", series, period);


--
-- Name: snew_contributors_data_repos snew_contributors_data_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.snew_contributors_data_repos
    ADD CONSTRAINT snew_contributors_data_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: snew_contributors snew_contributors_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.snew_contributors
    ADD CONSTRAINT snew_contributors_pkey PRIMARY KEY ("time", series, period);


--
-- Name: snew_contributors_repos snew_contributors_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.snew_contributors_repos
    ADD CONSTRAINT snew_contributors_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: snew_issues snew_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.snew_issues
    ADD CONSTRAINT snew_issues_pkey PRIMARY KEY ("time", series, period);


--
-- Name: snew_issues_repos snew_issues_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.snew_issues_repos
    ADD CONSTRAINT snew_issues_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: snum_stats snum_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.snum_stats
    ADD CONSTRAINT snum_stats_pkey PRIMARY KEY ("time", series, period);


--
-- Name: snum_stats_repos snum_stats_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.snum_stats_repos
    ADD CONSTRAINT snum_stats_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: spr_apprappr spr_apprappr_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_apprappr
    ADD CONSTRAINT spr_apprappr_pkey PRIMARY KEY ("time", period);


--
-- Name: spr_apprwait spr_apprwait_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_apprwait
    ADD CONSTRAINT spr_apprwait_pkey PRIMARY KEY ("time", period);


--
-- Name: spr_auth spr_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_auth
    ADD CONSTRAINT spr_auth_pkey PRIMARY KEY ("time", series, period);


--
-- Name: spr_auth_repos spr_auth_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_auth_repos
    ADD CONSTRAINT spr_auth_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: spr_comms_med spr_comms_med_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_comms_med
    ADD CONSTRAINT spr_comms_med_pkey PRIMARY KEY ("time", period);


--
-- Name: spr_comms_p85 spr_comms_p85_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_comms_p85
    ADD CONSTRAINT spr_comms_p85_pkey PRIMARY KEY ("time", period);


--
-- Name: spr_comms_p95 spr_comms_p95_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_comms_p95
    ADD CONSTRAINT spr_comms_p95_pkey PRIMARY KEY ("time", period);


--
-- Name: spr_repapprappr spr_repapprappr_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_repapprappr
    ADD CONSTRAINT spr_repapprappr_pkey PRIMARY KEY ("time", period);


--
-- Name: spr_repapprwait spr_repapprwait_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_repapprwait
    ADD CONSTRAINT spr_repapprwait_pkey PRIMARY KEY ("time", period);


--
-- Name: spr_workload_repos spr_workload_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spr_workload_repos
    ADD CONSTRAINT spr_workload_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sprblckall sprblckall_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprblckall
    ADD CONSTRAINT sprblckall_pkey PRIMARY KEY ("time", period);


--
-- Name: sprblckdo_not_merge sprblckdo_not_merge_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprblckdo_not_merge
    ADD CONSTRAINT sprblckdo_not_merge_pkey PRIMARY KEY ("time", period);


--
-- Name: sprblckneeds_ok_to_test sprblckneeds_ok_to_test_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprblckneeds_ok_to_test
    ADD CONSTRAINT sprblckneeds_ok_to_test_pkey PRIMARY KEY ("time", period);


--
-- Name: sprblckno_approve sprblckno_approve_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprblckno_approve
    ADD CONSTRAINT sprblckno_approve_pkey PRIMARY KEY ("time", period);


--
-- Name: sprblckno_lgtm sprblckno_lgtm_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprblckno_lgtm
    ADD CONSTRAINT sprblckno_lgtm_pkey PRIMARY KEY ("time", period);


--
-- Name: sprblckrelease_note_label_needed sprblckrelease_note_label_needed_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprblckrelease_note_label_needed
    ADD CONSTRAINT sprblckrelease_note_label_needed_pkey PRIMARY KEY ("time", period);


--
-- Name: spreprblckall spreprblckall_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spreprblckall
    ADD CONSTRAINT spreprblckall_pkey PRIMARY KEY ("time", period);


--
-- Name: spreprblckdo_not_merge spreprblckdo_not_merge_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spreprblckdo_not_merge
    ADD CONSTRAINT spreprblckdo_not_merge_pkey PRIMARY KEY ("time", period);


--
-- Name: spreprblckneeds_ok_to_test spreprblckneeds_ok_to_test_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spreprblckneeds_ok_to_test
    ADD CONSTRAINT spreprblckneeds_ok_to_test_pkey PRIMARY KEY ("time", period);


--
-- Name: spreprblckno_approve spreprblckno_approve_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spreprblckno_approve
    ADD CONSTRAINT spreprblckno_approve_pkey PRIMARY KEY ("time", period);


--
-- Name: spreprblckno_lgtm spreprblckno_lgtm_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spreprblckno_lgtm
    ADD CONSTRAINT spreprblckno_lgtm_pkey PRIMARY KEY ("time", period);


--
-- Name: spreprblckrelease_note_label_needed spreprblckrelease_note_label_needed_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spreprblckrelease_note_label_needed
    ADD CONSTRAINT spreprblckrelease_note_label_needed_pkey PRIMARY KEY ("time", period);


--
-- Name: sprs_age sprs_age_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprs_age
    ADD CONSTRAINT sprs_age_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sprs_age_repos sprs_age_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprs_age_repos
    ADD CONSTRAINT sprs_age_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sprs_labels_by_sig sprs_labels_by_sig_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprs_labels_by_sig
    ADD CONSTRAINT sprs_labels_by_sig_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sprs_labels sprs_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprs_labels
    ADD CONSTRAINT sprs_labels_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sprs_labels_repos sprs_labels_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprs_labels_repos
    ADD CONSTRAINT sprs_labels_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: sprs_milestones sprs_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.sprs_milestones
    ADD CONSTRAINT sprs_milestones_pkey PRIMARY KEY ("time", series, period);


--
-- Name: spstat spstat_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spstat
    ADD CONSTRAINT spstat_pkey PRIMARY KEY ("time", series, period);


--
-- Name: spstat_repos spstat_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.spstat_repos
    ADD CONSTRAINT spstat_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: ssig_pr_wlabs ssig_pr_wlabs_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssig_pr_wlabs
    ADD CONSTRAINT ssig_pr_wlabs_pkey PRIMARY KEY ("time", period);


--
-- Name: ssig_pr_wliss ssig_pr_wliss_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssig_pr_wliss
    ADD CONSTRAINT ssig_pr_wliss_pkey PRIMARY KEY ("time", period);


--
-- Name: ssig_pr_wlrel ssig_pr_wlrel_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssig_pr_wlrel
    ADD CONSTRAINT ssig_pr_wlrel_pkey PRIMARY KEY ("time", period);


--
-- Name: ssig_pr_wlrev ssig_pr_wlrev_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssig_pr_wlrev
    ADD CONSTRAINT ssig_pr_wlrev_pkey PRIMARY KEY ("time", period);


--
-- Name: ssig_prs_open ssig_prs_open_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssig_prs_open
    ADD CONSTRAINT ssig_prs_open_pkey PRIMARY KEY ("time", period);


--
-- Name: ssig_prs_open_repos ssig_prs_open_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssig_prs_open_repos
    ADD CONSTRAINT ssig_prs_open_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: ssigm_lsk ssigm_lsk_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssigm_lsk
    ADD CONSTRAINT ssigm_lsk_pkey PRIMARY KEY ("time", series, period);


--
-- Name: ssigm_lskr ssigm_lskr_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssigm_lskr
    ADD CONSTRAINT ssigm_lskr_pkey PRIMARY KEY ("time", series, period);


--
-- Name: ssigm_txt ssigm_txt_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ssigm_txt
    ADD CONSTRAINT ssigm_txt_pkey PRIMARY KEY ("time", period);


--
-- Name: stime_metrics stime_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.stime_metrics
    ADD CONSTRAINT stime_metrics_pkey PRIMARY KEY ("time", series, period);


--
-- Name: stime_metrics_repos stime_metrics_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.stime_metrics_repos
    ADD CONSTRAINT stime_metrics_repos_pkey PRIMARY KEY ("time", series, period);


--
-- Name: suser_reviews suser_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.suser_reviews
    ADD CONSTRAINT suser_reviews_pkey PRIMARY KEY ("time", series, period);


--
-- Name: swatchers swatchers_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.swatchers
    ADD CONSTRAINT swatchers_pkey PRIMARY KEY ("time", series, period);


--
-- Name: tall_combined_repo_groups tall_combined_repo_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tall_combined_repo_groups
    ADD CONSTRAINT tall_combined_repo_groups_pkey PRIMARY KEY ("time");


--
-- Name: tall_milestones tall_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tall_milestones
    ADD CONSTRAINT tall_milestones_pkey PRIMARY KEY ("time");


--
-- Name: tall_repo_groups tall_repo_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tall_repo_groups
    ADD CONSTRAINT tall_repo_groups_pkey PRIMARY KEY ("time");


--
-- Name: tall_repo_names tall_repo_names_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tall_repo_names
    ADD CONSTRAINT tall_repo_names_pkey PRIMARY KEY ("time");


--
-- Name: tbot_commands tbot_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tbot_commands
    ADD CONSTRAINT tbot_commands_pkey PRIMARY KEY ("time");


--
-- Name: tcompanies tcompanies_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tcompanies
    ADD CONSTRAINT tcompanies_pkey PRIMARY KEY ("time");


--
-- Name: tcountries tcountries_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tcountries
    ADD CONSTRAINT tcountries_pkey PRIMARY KEY ("time");


--
-- Name: tcumperiods tcumperiods_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tcumperiods
    ADD CONSTRAINT tcumperiods_pkey PRIMARY KEY ("time");


--
-- Name: tlanguages tlanguages_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tlanguages
    ADD CONSTRAINT tlanguages_pkey PRIMARY KEY ("time");


--
-- Name: tlicenses tlicenses_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tlicenses
    ADD CONSTRAINT tlicenses_pkey PRIMARY KEY ("time");


--
-- Name: tpr_labels_tags tpr_labels_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tpr_labels_tags
    ADD CONSTRAINT tpr_labels_tags_pkey PRIMARY KEY ("time");


--
-- Name: tpriority_labels_with_all tpriority_labels_with_all_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tpriority_labels_with_all
    ADD CONSTRAINT tpriority_labels_with_all_pkey PRIMARY KEY ("time");


--
-- Name: tquick_ranges tquick_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tquick_ranges
    ADD CONSTRAINT tquick_ranges_pkey PRIMARY KEY ("time");


--
-- Name: trepo_groups trepo_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.trepo_groups
    ADD CONSTRAINT trepo_groups_pkey PRIMARY KEY ("time");


--
-- Name: trepos trepos_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.trepos
    ADD CONSTRAINT trepos_pkey PRIMARY KEY ("time");


--
-- Name: treviewers treviewers_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.treviewers
    ADD CONSTRAINT treviewers_pkey PRIMARY KEY ("time");


--
-- Name: tsig_mentions_labels tsig_mentions_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tsig_mentions_labels
    ADD CONSTRAINT tsig_mentions_labels_pkey PRIMARY KEY ("time");


--
-- Name: tsig_mentions_labels_with_all tsig_mentions_labels_with_all_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tsig_mentions_labels_with_all
    ADD CONSTRAINT tsig_mentions_labels_with_all_pkey PRIMARY KEY ("time");


--
-- Name: tsig_mentions_texts tsig_mentions_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tsig_mentions_texts
    ADD CONSTRAINT tsig_mentions_texts_pkey PRIMARY KEY ("time");


--
-- Name: tsigm_lbl_kinds tsigm_lbl_kinds_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tsigm_lbl_kinds
    ADD CONSTRAINT tsigm_lbl_kinds_pkey PRIMARY KEY ("time");


--
-- Name: tsigm_lbl_kinds_with_all tsigm_lbl_kinds_with_all_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tsigm_lbl_kinds_with_all
    ADD CONSTRAINT tsigm_lbl_kinds_with_all_pkey PRIMARY KEY ("time");


--
-- Name: tsize_labels_with_all tsize_labels_with_all_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tsize_labels_with_all
    ADD CONSTRAINT tsize_labels_with_all_pkey PRIMARY KEY ("time");


--
-- Name: ttop_repo_names ttop_repo_names_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ttop_repo_names
    ADD CONSTRAINT ttop_repo_names_pkey PRIMARY KEY ("time");


--
-- Name: ttop_repo_names_with_all ttop_repo_names_with_all_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ttop_repo_names_with_all
    ADD CONSTRAINT ttop_repo_names_with_all_pkey PRIMARY KEY ("time");


--
-- Name: ttop_repos_with_all ttop_repos_with_all_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.ttop_repos_with_all
    ADD CONSTRAINT ttop_repos_with_all_pkey PRIMARY KEY ("time");


--
-- Name: tusers tusers_pkey; Type: CONSTRAINT; Schema: public; Owner: gha_admin
--

ALTER TABLE ONLY public.tusers
    ADD CONSTRAINT tusers_pkey PRIMARY KEY ("time");


--
-- Name: actors_affiliations_actor_from_to_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_affiliations_actor_from_to_idx ON public.gha_actors_affiliations USING btree (actor_id, dt_from, dt_to);


--
-- Name: actors_affiliations_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_affiliations_actor_id_idx ON public.gha_actors_affiliations USING btree (actor_id);


--
-- Name: actors_affiliations_company_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_affiliations_company_name_idx ON public.gha_actors_affiliations USING btree (company_name);


--
-- Name: actors_affiliations_dt_from_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_affiliations_dt_from_idx ON public.gha_actors_affiliations USING btree (dt_from);


--
-- Name: actors_affiliations_dt_to_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_affiliations_dt_to_idx ON public.gha_actors_affiliations USING btree (dt_to);


--
-- Name: actors_affiliations_original_company_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_affiliations_original_company_name_idx ON public.gha_actors_affiliations USING btree (original_company_name);


--
-- Name: actors_affiliations_source_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_affiliations_source_idx ON public.gha_actors_affiliations USING btree (source);


--
-- Name: actors_age_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_age_idx ON public.gha_actors USING btree (age);


--
-- Name: actors_country_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_country_id_idx ON public.gha_actors USING btree (country_id);


--
-- Name: actors_country_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_country_name_idx ON public.gha_actors USING btree (country_name);


--
-- Name: actors_emails_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_emails_actor_id_idx ON public.gha_actors_emails USING btree (actor_id);


--
-- Name: actors_emails_email_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_emails_email_idx ON public.gha_actors_emails USING btree (email);


--
-- Name: actors_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_id_idx ON public.gha_actors USING btree (id);


--
-- Name: actors_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_login_idx ON public.gha_actors USING btree (login);


--
-- Name: actors_lower_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_lower_login_idx ON public.gha_actors USING btree (lower((login)::text));


--
-- Name: actors_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_name_idx ON public.gha_actors USING btree (name);


--
-- Name: actors_names_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_names_actor_id_idx ON public.gha_actors_names USING btree (actor_id);


--
-- Name: actors_names_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_names_name_idx ON public.gha_actors_names USING btree (name);


--
-- Name: actors_sex_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_sex_idx ON public.gha_actors USING btree (sex);


--
-- Name: actors_sex_prob_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_sex_prob_idx ON public.gha_actors USING btree (sex_prob);


--
-- Name: actors_tz_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_tz_idx ON public.gha_actors USING btree (tz);


--
-- Name: actors_tz_offset; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX actors_tz_offset ON public.gha_actors USING btree (tz_offset);


--
-- Name: assets_content_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_content_type_idx ON public.gha_assets USING btree (content_type);


--
-- Name: assets_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_created_at_idx ON public.gha_assets USING btree (created_at);


--
-- Name: assets_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_dup_actor_id_idx ON public.gha_assets USING btree (dup_actor_id);


--
-- Name: assets_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_dup_actor_login_idx ON public.gha_assets USING btree (dup_actor_login);


--
-- Name: assets_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_dup_created_at_idx ON public.gha_assets USING btree (dup_created_at);


--
-- Name: assets_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_dup_repo_id_idx ON public.gha_assets USING btree (dup_repo_id);


--
-- Name: assets_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_dup_repo_name_idx ON public.gha_assets USING btree (dup_repo_name);


--
-- Name: assets_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_dup_type_idx ON public.gha_assets USING btree (dup_type);


--
-- Name: assets_dup_uploader_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_dup_uploader_login_idx ON public.gha_assets USING btree (dup_uploader_login);


--
-- Name: assets_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_event_id_idx ON public.gha_assets USING btree (event_id);


--
-- Name: assets_state_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_state_idx ON public.gha_assets USING btree (state);


--
-- Name: assets_updated_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_updated_at_idx ON public.gha_assets USING btree (updated_at);


--
-- Name: assets_uploader_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX assets_uploader_id_idx ON public.gha_assets USING btree (uploader_id);


--
-- Name: branches_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX branches_dup_created_at_idx ON public.gha_branches USING btree (dup_created_at);


--
-- Name: branches_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX branches_dup_type_idx ON public.gha_branches USING btree (dup_type);


--
-- Name: branches_dupn_forkee_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX branches_dupn_forkee_name_idx ON public.gha_branches USING btree (dupn_forkee_name);


--
-- Name: branches_dupn_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX branches_dupn_user_login_idx ON public.gha_branches USING btree (dupn_user_login);


--
-- Name: branches_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX branches_event_id_idx ON public.gha_branches USING btree (event_id);


--
-- Name: branches_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX branches_repo_id_idx ON public.gha_branches USING btree (repo_id);


--
-- Name: branches_user_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX branches_user_id_idx ON public.gha_branches USING btree (user_id);


--
-- Name: comments_commit_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_commit_id_idx ON public.gha_comments USING btree (commit_id);


--
-- Name: comments_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_created_at_idx ON public.gha_comments USING btree (created_at);


--
-- Name: comments_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_dup_actor_id_idx ON public.gha_comments USING btree (dup_actor_id);


--
-- Name: comments_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_dup_actor_login_idx ON public.gha_comments USING btree (dup_actor_login);


--
-- Name: comments_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_dup_created_at_idx ON public.gha_comments USING btree (dup_created_at);


--
-- Name: comments_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_dup_repo_id_idx ON public.gha_comments USING btree (dup_repo_id);


--
-- Name: comments_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_dup_repo_name_idx ON public.gha_comments USING btree (dup_repo_name);


--
-- Name: comments_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_dup_type_idx ON public.gha_comments USING btree (dup_type);


--
-- Name: comments_dup_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_dup_user_login_idx ON public.gha_comments USING btree (dup_user_login);


--
-- Name: comments_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_event_id_idx ON public.gha_comments USING btree (event_id);


--
-- Name: comments_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_id_idx ON public.gha_comments USING btree (id);


--
-- Name: comments_lower_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_lower_dup_actor_login_idx ON public.gha_comments USING btree (lower((dup_actor_login)::text));


--
-- Name: comments_lower_dup_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_lower_dup_user_login_idx ON public.gha_comments USING btree (lower((dup_user_login)::text));


--
-- Name: comments_pull_request_review_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_pull_request_review_id_idx ON public.gha_comments USING btree (pull_request_review_id);


--
-- Name: comments_repo_name_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_repo_name_created_at_idx ON public.gha_comments USING btree (dup_repo_id, dup_repo_name, created_at);


--
-- Name: comments_updated_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_updated_at_idx ON public.gha_comments USING btree (updated_at);


--
-- Name: comments_user_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX comments_user_id_idx ON public.gha_comments USING btree (user_id);


--
-- Name: commits_author_email_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_author_email_idx ON public.gha_commits USING btree (author_email);


--
-- Name: commits_author_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_author_id_idx ON public.gha_commits USING btree (author_id);


--
-- Name: commits_author_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_author_name_idx ON public.gha_commits USING btree (author_name);


--
-- Name: commits_committer_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_committer_id_idx ON public.gha_commits USING btree (committer_id);


--
-- Name: commits_committers_email_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_committers_email_idx ON public.gha_commits USING btree (committer_email);


--
-- Name: commits_committers_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_committers_name_idx ON public.gha_commits USING btree (committer_name);


--
-- Name: commits_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_dup_actor_id_idx ON public.gha_commits USING btree (dup_actor_id);


--
-- Name: commits_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_dup_actor_login_idx ON public.gha_commits USING btree (dup_actor_login);


--
-- Name: commits_dup_author_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_dup_author_login_idx ON public.gha_commits USING btree (dup_author_login);


--
-- Name: commits_dup_committer_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_dup_committer_login_idx ON public.gha_commits USING btree (dup_committer_login);


--
-- Name: commits_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_dup_created_at_idx ON public.gha_commits USING btree (dup_created_at);


--
-- Name: commits_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_dup_repo_id_idx ON public.gha_commits USING btree (dup_repo_id);


--
-- Name: commits_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_dup_repo_name_idx ON public.gha_commits USING btree (dup_repo_name);


--
-- Name: commits_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_dup_type_idx ON public.gha_commits USING btree (dup_type);


--
-- Name: commits_encrypted_email_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_encrypted_email_idx ON public.gha_commits USING btree (encrypted_email);


--
-- Name: commits_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_event_id_idx ON public.gha_commits USING btree (event_id);


--
-- Name: commits_files_changed_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_files_changed_idx ON public.gha_commits USING btree (files_changed);


--
-- Name: commits_files_dt_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_files_dt_idx ON public.gha_commits_files USING btree (dt);


--
-- Name: commits_files_ext_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_files_ext_idx ON public.gha_commits_files USING btree (ext);


--
-- Name: commits_files_path_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_files_path_idx ON public.gha_commits_files USING btree (path);


--
-- Name: commits_files_sha_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_files_sha_idx ON public.gha_commits_files USING btree (sha);


--
-- Name: commits_files_size_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_files_size_idx ON public.gha_commits_files USING btree (size);


--
-- Name: commits_loc_added_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_loc_added_idx ON public.gha_commits USING btree (loc_added);


--
-- Name: commits_loc_removed_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_loc_removed_idx ON public.gha_commits USING btree (loc_removed);


--
-- Name: commits_lower_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_lower_dup_actor_login_idx ON public.gha_commits USING btree (lower((dup_actor_login)::text));


--
-- Name: commits_lower_dup_author_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_lower_dup_author_login_idx ON public.gha_commits USING btree (lower((dup_author_login)::text));


--
-- Name: commits_lower_dup_committer_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_lower_dup_committer_login_idx ON public.gha_commits USING btree (lower((dup_committer_login)::text));


--
-- Name: commits_repo_name_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_repo_name_created_at_idx ON public.gha_commits USING btree (dup_repo_id, dup_repo_name, dup_created_at);


--
-- Name: commits_roles_actor_email_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_actor_email_idx ON public.gha_commits_roles USING btree (actor_email);


--
-- Name: commits_roles_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_actor_id_idx ON public.gha_commits_roles USING btree (actor_id);


--
-- Name: commits_roles_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_actor_login_idx ON public.gha_commits_roles USING btree (actor_login);


--
-- Name: commits_roles_actor_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_actor_name_idx ON public.gha_commits_roles USING btree (actor_name);


--
-- Name: commits_roles_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_dup_created_at_idx ON public.gha_commits_roles USING btree (dup_created_at);


--
-- Name: commits_roles_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_dup_repo_id_idx ON public.gha_commits_roles USING btree (dup_repo_id);


--
-- Name: commits_roles_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_dup_repo_name_idx ON public.gha_commits_roles USING btree (dup_repo_name);


--
-- Name: commits_roles_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_event_id_idx ON public.gha_commits_roles USING btree (event_id);


--
-- Name: commits_roles_role_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_role_idx ON public.gha_commits_roles USING btree (role);


--
-- Name: commits_roles_sha_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_roles_sha_idx ON public.gha_commits_roles USING btree (sha);


--
-- Name: commits_sha_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX commits_sha_idx ON public.gha_commits USING btree (sha);


--
-- Name: computed_dt_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX computed_dt_idx ON public.gha_computed USING btree (dt);


--
-- Name: computed_metric_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX computed_metric_idx ON public.gha_computed USING btree (metric);


--
-- Name: countries_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX countries_name_idx ON public.gha_countries USING btree (name);


--
-- Name: events_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_actor_id_idx ON public.gha_events USING btree (actor_id);


--
-- Name: events_commits_files_dt_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_dt_idx ON public.gha_events_commits_files USING btree (dt);


--
-- Name: events_commits_files_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_dup_created_at_idx ON public.gha_events_commits_files USING btree (dup_created_at);


--
-- Name: events_commits_files_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_dup_repo_id_idx ON public.gha_events_commits_files USING btree (dup_repo_id);


--
-- Name: events_commits_files_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_dup_repo_name_idx ON public.gha_events_commits_files USING btree (dup_repo_name);


--
-- Name: events_commits_files_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_dup_type_idx ON public.gha_events_commits_files USING btree (dup_type);


--
-- Name: events_commits_files_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_event_id_idx ON public.gha_events_commits_files USING btree (event_id);


--
-- Name: events_commits_files_ext_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_ext_idx ON public.gha_events_commits_files USING btree (ext);


--
-- Name: events_commits_files_path_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_path_idx ON public.gha_events_commits_files USING btree (path);


--
-- Name: events_commits_files_repo_group_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_repo_group_idx ON public.gha_events_commits_files USING btree (repo_group);


--
-- Name: events_commits_files_sha_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_sha_idx ON public.gha_events_commits_files USING btree (sha);


--
-- Name: events_commits_files_size_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_commits_files_size_idx ON public.gha_events_commits_files USING btree (size);


--
-- Name: events_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_created_at_idx ON public.gha_events USING btree (created_at);


--
-- Name: events_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_dup_actor_login_idx ON public.gha_events USING btree (dup_actor_login);


--
-- Name: events_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_dup_repo_name_idx ON public.gha_events USING btree (dup_repo_name);


--
-- Name: events_forkee_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_forkee_id_idx ON public.gha_events USING btree (forkee_id);


--
-- Name: events_lower_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_lower_dup_actor_login_idx ON public.gha_events USING btree (lower((dup_actor_login)::text));


--
-- Name: events_org_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_org_id_idx ON public.gha_events USING btree (org_id);


--
-- Name: events_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_repo_id_idx ON public.gha_events USING btree (repo_id);


--
-- Name: events_repo_name_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_repo_name_created_at_idx ON public.gha_events USING btree (repo_id, dup_repo_name, created_at);


--
-- Name: events_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX events_type_idx ON public.gha_events USING btree (type);


--
-- Name: forkees_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_created_at_idx ON public.gha_forkees USING btree (created_at);


--
-- Name: forkees_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_dup_actor_id_idx ON public.gha_forkees USING btree (dup_actor_id);


--
-- Name: forkees_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_dup_actor_login_idx ON public.gha_forkees USING btree (dup_actor_login);


--
-- Name: forkees_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_dup_created_at_idx ON public.gha_forkees USING btree (dup_created_at);


--
-- Name: forkees_dup_owner_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_dup_owner_login_idx ON public.gha_forkees USING btree (dup_owner_login);


--
-- Name: forkees_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_dup_repo_id_idx ON public.gha_forkees USING btree (dup_repo_id);


--
-- Name: forkees_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_dup_repo_name_idx ON public.gha_forkees USING btree (dup_repo_name);


--
-- Name: forkees_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_dup_type_idx ON public.gha_forkees USING btree (dup_type);


--
-- Name: forkees_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_event_id_idx ON public.gha_forkees USING btree (event_id);


--
-- Name: forkees_language_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_language_idx ON public.gha_forkees USING btree (language);


--
-- Name: forkees_organization_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_organization_idx ON public.gha_forkees USING btree (organization);


--
-- Name: forkees_owner_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_owner_id_idx ON public.gha_forkees USING btree (owner_id);


--
-- Name: forkees_updated_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX forkees_updated_at_idx ON public.gha_forkees USING btree (updated_at);


--
-- Name: gha_bot_logins_pattern_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX gha_bot_logins_pattern_idx ON public.gha_bot_logins USING btree (pattern);


--
-- Name: iall_combined_repo_groupsall_combined_repo_group_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iall_combined_repo_groupsall_combined_repo_group_name ON public.tall_combined_repo_groups USING btree (all_combined_repo_group_name);


--
-- Name: iall_combined_repo_groupsall_combined_repo_group_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iall_combined_repo_groupsall_combined_repo_group_value ON public.tall_combined_repo_groups USING btree (all_combined_repo_group_value);


--
-- Name: iall_milestonesall_milestones_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iall_milestonesall_milestones_name ON public.tall_milestones USING btree (all_milestones_name);


--
-- Name: iall_milestonesall_milestones_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iall_milestonesall_milestones_value ON public.tall_milestones USING btree (all_milestones_value);


--
-- Name: iall_repo_groupsall_repo_group_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iall_repo_groupsall_repo_group_name ON public.tall_repo_groups USING btree (all_repo_group_name);


--
-- Name: iall_repo_groupsall_repo_group_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iall_repo_groupsall_repo_group_value ON public.tall_repo_groups USING btree (all_repo_group_value);


--
-- Name: iall_repo_namesall_repo_names_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iall_repo_namesall_repo_names_name ON public.tall_repo_names USING btree (all_repo_names_name);


--
-- Name: iall_repo_namesall_repo_names_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iall_repo_namesall_repo_names_value ON public.tall_repo_names USING btree (all_repo_names_value);


--
-- Name: iannotationsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iannotationsp ON public.sannotations USING btree (period);


--
-- Name: iannotationst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iannotationst ON public.sannotations USING btree ("time");


--
-- Name: iawaiting_prs_by_sig_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sig_reposp ON public.sawaiting_prs_by_sig_repos USING btree (period);


--
-- Name: iawaiting_prs_by_sig_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sig_reposs ON public.sawaiting_prs_by_sig_repos USING btree (series);


--
-- Name: iawaiting_prs_by_sig_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sig_repost ON public.sawaiting_prs_by_sig_repos USING btree ("time");


--
-- Name: iawaiting_prs_by_sigd10p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigd10p ON public.sawaiting_prs_by_sigd10 USING btree (period);


--
-- Name: iawaiting_prs_by_sigd10t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigd10t ON public.sawaiting_prs_by_sigd10 USING btree ("time");


--
-- Name: iawaiting_prs_by_sigd30p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigd30p ON public.sawaiting_prs_by_sigd30 USING btree (period);


--
-- Name: iawaiting_prs_by_sigd30t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigd30t ON public.sawaiting_prs_by_sigd30 USING btree ("time");


--
-- Name: iawaiting_prs_by_sigd60p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigd60p ON public.sawaiting_prs_by_sigd60 USING btree (period);


--
-- Name: iawaiting_prs_by_sigd60t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigd60t ON public.sawaiting_prs_by_sigd60 USING btree ("time");


--
-- Name: iawaiting_prs_by_sigd90p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigd90p ON public.sawaiting_prs_by_sigd90 USING btree (period);


--
-- Name: iawaiting_prs_by_sigd90t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigd90t ON public.sawaiting_prs_by_sigd90 USING btree ("time");


--
-- Name: iawaiting_prs_by_sigyp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigyp ON public.sawaiting_prs_by_sigy USING btree (period);


--
-- Name: iawaiting_prs_by_sigyt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iawaiting_prs_by_sigyt ON public.sawaiting_prs_by_sigy USING btree ("time");


--
-- Name: ibot_commands_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ibot_commands_reposp ON public.sbot_commands_repos USING btree (period);


--
-- Name: ibot_commands_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ibot_commands_reposs ON public.sbot_commands_repos USING btree (series);


--
-- Name: ibot_commands_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ibot_commands_repost ON public.sbot_commands_repos USING btree ("time");


--
-- Name: ibot_commandsbot_command_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ibot_commandsbot_command_name ON public.tbot_commands USING btree (bot_command_name);


--
-- Name: ibot_commandsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ibot_commandsp ON public.sbot_commands USING btree (period);


--
-- Name: ibot_commandss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ibot_commandss ON public.sbot_commands USING btree (series);


--
-- Name: ibot_commandst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ibot_commandst ON public.sbot_commands USING btree ("time");


--
-- Name: icntrs_and_orgsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icntrs_and_orgsp ON public.scntrs_and_orgs USING btree (period);


--
-- Name: icntrs_and_orgss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icntrs_and_orgss ON public.scntrs_and_orgs USING btree (series);


--
-- Name: icntrs_and_orgst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icntrs_and_orgst ON public.scntrs_and_orgs USING btree ("time");


--
-- Name: icompaniescompanies_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompaniescompanies_name ON public.tcompanies USING btree (companies_name);


--
-- Name: icompaniescompanies_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompaniescompanies_value ON public.tcompanies USING btree (companies_value);


--
-- Name: icompany_activity_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompany_activity_reposp ON public.scompany_activity_repos USING btree (period);


--
-- Name: icompany_activity_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompany_activity_reposs ON public.scompany_activity_repos USING btree (series);


--
-- Name: icompany_activity_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompany_activity_repost ON public.scompany_activity_repos USING btree ("time");


--
-- Name: icompany_activityp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompany_activityp ON public.scompany_activity USING btree (period);


--
-- Name: icompany_activitys; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompany_activitys ON public.scompany_activity USING btree (series);


--
-- Name: icompany_activityt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompany_activityt ON public.scompany_activity USING btree ("time");


--
-- Name: icompany_prs_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompany_prs_reposp ON public.scompany_prs_repos USING btree (period);


--
-- Name: icompany_prs_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icompany_prs_repost ON public.scompany_prs_repos USING btree ("time");


--
-- Name: icountriescountry_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icountriescountry_name ON public.tcountries USING btree (country_name);


--
-- Name: icountriescountry_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icountriescountry_value ON public.tcountries USING btree (country_value);


--
-- Name: icountriescump; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icountriescump ON public.scountriescum USING btree (period);


--
-- Name: icountriescums; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icountriescums ON public.scountriescum USING btree (series);


--
-- Name: icountriescumt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icountriescumt ON public.scountriescum USING btree ("time");


--
-- Name: icountriesp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icountriesp ON public.scountries USING btree (period);


--
-- Name: icountriess; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icountriess ON public.scountries USING btree (series);


--
-- Name: icountriest; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icountriest ON public.scountries USING btree ("time");


--
-- Name: icsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icsp ON public.scs USING btree (period);


--
-- Name: icsrp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icsrp ON public.scsr USING btree (period);


--
-- Name: icsrs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icsrs ON public.scsr USING btree (series);


--
-- Name: icsrt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icsrt ON public.scsr USING btree ("time");


--
-- Name: icss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icss ON public.scs USING btree (series);


--
-- Name: icst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icst ON public.scs USING btree ("time");


--
-- Name: icumperiodscumperiod_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX icumperiodscumperiod_name ON public.tcumperiods USING btree (cumperiod_name);


--
-- Name: iepisodic_contributors_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_contributors_reposp ON public.sepisodic_contributors_repos USING btree (period);


--
-- Name: iepisodic_contributors_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_contributors_reposs ON public.sepisodic_contributors_repos USING btree (series);


--
-- Name: iepisodic_contributors_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_contributors_repost ON public.sepisodic_contributors_repos USING btree ("time");


--
-- Name: iepisodic_contributorsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_contributorsp ON public.sepisodic_contributors USING btree (period);


--
-- Name: iepisodic_contributorss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_contributorss ON public.sepisodic_contributors USING btree (series);


--
-- Name: iepisodic_contributorst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_contributorst ON public.sepisodic_contributors USING btree ("time");


--
-- Name: iepisodic_issues_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_issues_reposp ON public.sepisodic_issues_repos USING btree (period);


--
-- Name: iepisodic_issues_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_issues_reposs ON public.sepisodic_issues_repos USING btree (series);


--
-- Name: iepisodic_issues_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_issues_repost ON public.sepisodic_issues_repos USING btree ("time");


--
-- Name: iepisodic_issuesp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_issuesp ON public.sepisodic_issues USING btree (period);


--
-- Name: iepisodic_issuess; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_issuess ON public.sepisodic_issues USING btree (series);


--
-- Name: iepisodic_issuest; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iepisodic_issuest ON public.sepisodic_issues USING btree ("time");


--
-- Name: ievents_hp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ievents_hp ON public.sevents_h USING btree (period);


--
-- Name: ievents_ht; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ievents_ht ON public.sevents_h USING btree ("time");


--
-- Name: ifirst_non_author_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ifirst_non_author_reposp ON public.sfirst_non_author_repos USING btree (period);


--
-- Name: ifirst_non_author_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ifirst_non_author_reposs ON public.sfirst_non_author_repos USING btree (series);


--
-- Name: ifirst_non_author_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ifirst_non_author_repost ON public.sfirst_non_author_repos USING btree ("time");


--
-- Name: ifirst_non_authorp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ifirst_non_authorp ON public.sfirst_non_author USING btree (period);


--
-- Name: ifirst_non_authors; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ifirst_non_authors ON public.sfirst_non_author USING btree (series);


--
-- Name: ifirst_non_authort; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ifirst_non_authort ON public.sfirst_non_author USING btree ("time");


--
-- Name: igh_stats_rgrpp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX igh_stats_rgrpp ON public.sgh_stats_rgrp USING btree (period);


--
-- Name: igh_stats_rgrps; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX igh_stats_rgrps ON public.sgh_stats_rgrp USING btree (series);


--
-- Name: igh_stats_rgrpt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX igh_stats_rgrpt ON public.sgh_stats_rgrp USING btree ("time");


--
-- Name: igh_stats_rp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX igh_stats_rp ON public.sgh_stats_r USING btree (period);


--
-- Name: igh_stats_rs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX igh_stats_rs ON public.sgh_stats_r USING btree (series);


--
-- Name: igh_stats_rt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX igh_stats_rt ON public.sgh_stats_r USING btree ("time");


--
-- Name: ihcomp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihcomp ON public.shcom USING btree (period);


--
-- Name: ihcoms; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihcoms ON public.shcom USING btree (series);


--
-- Name: ihcomt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihcomt ON public.shcom USING btree ("time");


--
-- Name: ihdev_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihdev_reposp ON public.shdev_repos USING btree (period);


--
-- Name: ihdev_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihdev_reposs ON public.shdev_repos USING btree (series);


--
-- Name: ihdev_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihdev_repost ON public.shdev_repos USING btree ("time");


--
-- Name: ihdevp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihdevp ON public.shdev USING btree (period);


--
-- Name: ihdevs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihdevs ON public.shdev USING btree (series);


--
-- Name: ihdevt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihdevt ON public.shdev USING btree ("time");


--
-- Name: ihpr_mergersp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihpr_mergersp ON public.shpr_mergers USING btree (period);


--
-- Name: ihpr_mergerss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihpr_mergerss ON public.shpr_mergers USING btree (series);


--
-- Name: ihpr_mergerst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihpr_mergerst ON public.shpr_mergers USING btree ("time");


--
-- Name: ihpr_wlsigsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihpr_wlsigsp ON public.shpr_wlsigs USING btree (period);


--
-- Name: ihpr_wlsigst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihpr_wlsigst ON public.shpr_wlsigs USING btree ("time");


--
-- Name: ihpr_wrlsigsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihpr_wrlsigsp ON public.shpr_wrlsigs USING btree (period);


--
-- Name: ihpr_wrlsigst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ihpr_wrlsigst ON public.shpr_wrlsigs USING btree ("time");


--
-- Name: iiclosed_lskp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iiclosed_lskp ON public.siclosed_lsk USING btree (period);


--
-- Name: iiclosed_lskrp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iiclosed_lskrp ON public.siclosed_lskr USING btree (period);


--
-- Name: iiclosed_lskrs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iiclosed_lskrs ON public.siclosed_lskr USING btree (series);


--
-- Name: iiclosed_lskrt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iiclosed_lskrt ON public.siclosed_lskr USING btree ("time");


--
-- Name: iiclosed_lsks; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iiclosed_lsks ON public.siclosed_lsk USING btree (series);


--
-- Name: iiclosed_lskt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iiclosed_lskt ON public.siclosed_lsk USING btree ("time");


--
-- Name: iinactive_issues_by_sig_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sig_reposp ON public.sinactive_issues_by_sig_repos USING btree (period);


--
-- Name: iinactive_issues_by_sig_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sig_reposs ON public.sinactive_issues_by_sig_repos USING btree (series);


--
-- Name: iinactive_issues_by_sig_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sig_repost ON public.sinactive_issues_by_sig_repos USING btree ("time");


--
-- Name: iinactive_issues_by_sigd30p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sigd30p ON public.sinactive_issues_by_sigd30 USING btree (period);


--
-- Name: iinactive_issues_by_sigd30t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sigd30t ON public.sinactive_issues_by_sigd30 USING btree ("time");


--
-- Name: iinactive_issues_by_sigd90p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sigd90p ON public.sinactive_issues_by_sigd90 USING btree (period);


--
-- Name: iinactive_issues_by_sigd90t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sigd90t ON public.sinactive_issues_by_sigd90 USING btree ("time");


--
-- Name: iinactive_issues_by_sigw2p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sigw2p ON public.sinactive_issues_by_sigw2 USING btree (period);


--
-- Name: iinactive_issues_by_sigw2t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_issues_by_sigw2t ON public.sinactive_issues_by_sigw2 USING btree ("time");


--
-- Name: iinactive_prs_by_sig_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sig_reposp ON public.sinactive_prs_by_sig_repos USING btree (period);


--
-- Name: iinactive_prs_by_sig_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sig_reposs ON public.sinactive_prs_by_sig_repos USING btree (series);


--
-- Name: iinactive_prs_by_sig_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sig_repost ON public.sinactive_prs_by_sig_repos USING btree ("time");


--
-- Name: iinactive_prs_by_sigd30p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sigd30p ON public.sinactive_prs_by_sigd30 USING btree (period);


--
-- Name: iinactive_prs_by_sigd30t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sigd30t ON public.sinactive_prs_by_sigd30 USING btree ("time");


--
-- Name: iinactive_prs_by_sigd90p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sigd90p ON public.sinactive_prs_by_sigd90 USING btree (period);


--
-- Name: iinactive_prs_by_sigd90t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sigd90t ON public.sinactive_prs_by_sigd90 USING btree ("time");


--
-- Name: iinactive_prs_by_sigw2p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sigw2p ON public.sinactive_prs_by_sigw2 USING btree (period);


--
-- Name: iinactive_prs_by_sigw2t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iinactive_prs_by_sigw2t ON public.sinactive_prs_by_sigw2 USING btree ("time");


--
-- Name: iissues_age_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_age_reposp ON public.sissues_age_repos USING btree (period);


--
-- Name: iissues_age_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_age_reposs ON public.sissues_age_repos USING btree (series);


--
-- Name: iissues_age_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_age_repost ON public.sissues_age_repos USING btree ("time");


--
-- Name: iissues_agep; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_agep ON public.sissues_age USING btree (period);


--
-- Name: iissues_ages; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_ages ON public.sissues_age USING btree (series);


--
-- Name: iissues_aget; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_aget ON public.sissues_age USING btree ("time");


--
-- Name: iissues_milestonesp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_milestonesp ON public.sissues_milestones USING btree (period);


--
-- Name: iissues_milestoness; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_milestoness ON public.sissues_milestones USING btree (series);


--
-- Name: iissues_milestonest; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iissues_milestonest ON public.sissues_milestones USING btree ("time");


--
-- Name: ilanguageslang_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ilanguageslang_name ON public.tlanguages USING btree (lang_name);


--
-- Name: ilicenseslicense_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ilicenseslicense_name ON public.tlicenses USING btree (license_name);


--
-- Name: inew_contributors_data_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_data_reposp ON public.snew_contributors_data_repos USING btree (period);


--
-- Name: inew_contributors_data_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_data_reposs ON public.snew_contributors_data_repos USING btree (series);


--
-- Name: inew_contributors_data_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_data_repost ON public.snew_contributors_data_repos USING btree ("time");


--
-- Name: inew_contributors_datap; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_datap ON public.snew_contributors_data USING btree (period);


--
-- Name: inew_contributors_datas; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_datas ON public.snew_contributors_data USING btree (series);


--
-- Name: inew_contributors_datat; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_datat ON public.snew_contributors_data USING btree ("time");


--
-- Name: inew_contributors_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_reposp ON public.snew_contributors_repos USING btree (period);


--
-- Name: inew_contributors_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_reposs ON public.snew_contributors_repos USING btree (series);


--
-- Name: inew_contributors_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributors_repost ON public.snew_contributors_repos USING btree ("time");


--
-- Name: inew_contributorsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributorsp ON public.snew_contributors USING btree (period);


--
-- Name: inew_contributorss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributorss ON public.snew_contributors USING btree (series);


--
-- Name: inew_contributorst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_contributorst ON public.snew_contributors USING btree ("time");


--
-- Name: inew_issues_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_issues_reposp ON public.snew_issues_repos USING btree (period);


--
-- Name: inew_issues_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_issues_reposs ON public.snew_issues_repos USING btree (series);


--
-- Name: inew_issues_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_issues_repost ON public.snew_issues_repos USING btree ("time");


--
-- Name: inew_issuesp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_issuesp ON public.snew_issues USING btree (period);


--
-- Name: inew_issuess; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_issuess ON public.snew_issues USING btree (series);


--
-- Name: inew_issuest; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inew_issuest ON public.snew_issues USING btree ("time");


--
-- Name: inum_stats_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inum_stats_reposp ON public.snum_stats_repos USING btree (period);


--
-- Name: inum_stats_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inum_stats_reposs ON public.snum_stats_repos USING btree (series);


--
-- Name: inum_stats_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inum_stats_repost ON public.snum_stats_repos USING btree ("time");


--
-- Name: inum_statsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inum_statsp ON public.snum_stats USING btree (period);


--
-- Name: inum_statss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inum_statss ON public.snum_stats USING btree (series);


--
-- Name: inum_statst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX inum_statst ON public.snum_stats USING btree ("time");


--
-- Name: ipr_apprapprp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_apprapprp ON public.spr_apprappr USING btree (period);


--
-- Name: ipr_apprapprt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_apprapprt ON public.spr_apprappr USING btree ("time");


--
-- Name: ipr_apprwaitp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_apprwaitp ON public.spr_apprwait USING btree (period);


--
-- Name: ipr_apprwaitt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_apprwaitt ON public.spr_apprwait USING btree ("time");


--
-- Name: ipr_auth_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_auth_reposp ON public.spr_auth_repos USING btree (period);


--
-- Name: ipr_auth_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_auth_reposs ON public.spr_auth_repos USING btree (series);


--
-- Name: ipr_auth_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_auth_repost ON public.spr_auth_repos USING btree ("time");


--
-- Name: ipr_authp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_authp ON public.spr_auth USING btree (period);


--
-- Name: ipr_auths; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_auths ON public.spr_auth USING btree (series);


--
-- Name: ipr_autht; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_autht ON public.spr_auth USING btree ("time");


--
-- Name: ipr_comms_medp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_comms_medp ON public.spr_comms_med USING btree (period);


--
-- Name: ipr_comms_medt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_comms_medt ON public.spr_comms_med USING btree ("time");


--
-- Name: ipr_comms_p85p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_comms_p85p ON public.spr_comms_p85 USING btree (period);


--
-- Name: ipr_comms_p85t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_comms_p85t ON public.spr_comms_p85 USING btree ("time");


--
-- Name: ipr_comms_p95p; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_comms_p95p ON public.spr_comms_p95 USING btree (period);


--
-- Name: ipr_comms_p95t; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_comms_p95t ON public.spr_comms_p95 USING btree ("time");


--
-- Name: ipr_labels_tagspr_labels_tags_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_labels_tagspr_labels_tags_name ON public.tpr_labels_tags USING btree (pr_labels_tags_name);


--
-- Name: ipr_labels_tagspr_labels_tags_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_labels_tagspr_labels_tags_value ON public.tpr_labels_tags USING btree (pr_labels_tags_value);


--
-- Name: ipr_repapprapprp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_repapprapprp ON public.spr_repapprappr USING btree (period);


--
-- Name: ipr_repapprapprt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_repapprapprt ON public.spr_repapprappr USING btree ("time");


--
-- Name: ipr_repapprwaitp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_repapprwaitp ON public.spr_repapprwait USING btree (period);


--
-- Name: ipr_repapprwaitt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_repapprwaitt ON public.spr_repapprwait USING btree ("time");


--
-- Name: ipr_workload_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_workload_reposp ON public.spr_workload_repos USING btree (period);


--
-- Name: ipr_workload_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_workload_reposs ON public.spr_workload_repos USING btree (series);


--
-- Name: ipr_workload_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipr_workload_repost ON public.spr_workload_repos USING btree ("time");


--
-- Name: iprblckallp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckallp ON public.sprblckall USING btree (period);


--
-- Name: iprblckallt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckallt ON public.sprblckall USING btree ("time");


--
-- Name: iprblckdo_not_mergep; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckdo_not_mergep ON public.sprblckdo_not_merge USING btree (period);


--
-- Name: iprblckdo_not_merget; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckdo_not_merget ON public.sprblckdo_not_merge USING btree ("time");


--
-- Name: iprblckneeds_ok_to_testp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckneeds_ok_to_testp ON public.sprblckneeds_ok_to_test USING btree (period);


--
-- Name: iprblckneeds_ok_to_testt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckneeds_ok_to_testt ON public.sprblckneeds_ok_to_test USING btree ("time");


--
-- Name: iprblckno_approvep; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckno_approvep ON public.sprblckno_approve USING btree (period);


--
-- Name: iprblckno_approvet; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckno_approvet ON public.sprblckno_approve USING btree ("time");


--
-- Name: iprblckno_lgtmp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckno_lgtmp ON public.sprblckno_lgtm USING btree (period);


--
-- Name: iprblckno_lgtmt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckno_lgtmt ON public.sprblckno_lgtm USING btree ("time");


--
-- Name: iprblckrelease_note_label_neededp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckrelease_note_label_neededp ON public.sprblckrelease_note_label_needed USING btree (period);


--
-- Name: iprblckrelease_note_label_neededt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprblckrelease_note_label_neededt ON public.sprblckrelease_note_label_needed USING btree ("time");


--
-- Name: ipreprblckallp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckallp ON public.spreprblckall USING btree (period);


--
-- Name: ipreprblckallt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckallt ON public.spreprblckall USING btree ("time");


--
-- Name: ipreprblckdo_not_mergep; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckdo_not_mergep ON public.spreprblckdo_not_merge USING btree (period);


--
-- Name: ipreprblckdo_not_merget; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckdo_not_merget ON public.spreprblckdo_not_merge USING btree ("time");


--
-- Name: ipreprblckneeds_ok_to_testp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckneeds_ok_to_testp ON public.spreprblckneeds_ok_to_test USING btree (period);


--
-- Name: ipreprblckneeds_ok_to_testt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckneeds_ok_to_testt ON public.spreprblckneeds_ok_to_test USING btree ("time");


--
-- Name: ipreprblckno_approvep; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckno_approvep ON public.spreprblckno_approve USING btree (period);


--
-- Name: ipreprblckno_approvet; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckno_approvet ON public.spreprblckno_approve USING btree ("time");


--
-- Name: ipreprblckno_lgtmp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckno_lgtmp ON public.spreprblckno_lgtm USING btree (period);


--
-- Name: ipreprblckno_lgtmt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckno_lgtmt ON public.spreprblckno_lgtm USING btree ("time");


--
-- Name: ipreprblckrelease_note_label_neededp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckrelease_note_label_neededp ON public.spreprblckrelease_note_label_needed USING btree (period);


--
-- Name: ipreprblckrelease_note_label_neededt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipreprblckrelease_note_label_neededt ON public.spreprblckrelease_note_label_needed USING btree ("time");


--
-- Name: ipriority_labels_with_allpriority_labels_name_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipriority_labels_with_allpriority_labels_name_with_all ON public.tpriority_labels_with_all USING btree (priority_labels_name_with_all);


--
-- Name: ipriority_labels_with_allpriority_labels_value_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipriority_labels_with_allpriority_labels_value_with_all ON public.tpriority_labels_with_all USING btree (priority_labels_value_with_all);


--
-- Name: iprs_age_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_age_reposp ON public.sprs_age_repos USING btree (period);


--
-- Name: iprs_age_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_age_reposs ON public.sprs_age_repos USING btree (series);


--
-- Name: iprs_age_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_age_repost ON public.sprs_age_repos USING btree ("time");


--
-- Name: iprs_agep; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_agep ON public.sprs_age USING btree (period);


--
-- Name: iprs_ages; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_ages ON public.sprs_age USING btree (series);


--
-- Name: iprs_aget; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_aget ON public.sprs_age USING btree ("time");


--
-- Name: iprs_labels_by_sigp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labels_by_sigp ON public.sprs_labels_by_sig USING btree (period);


--
-- Name: iprs_labels_by_sigs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labels_by_sigs ON public.sprs_labels_by_sig USING btree (series);


--
-- Name: iprs_labels_by_sigt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labels_by_sigt ON public.sprs_labels_by_sig USING btree ("time");


--
-- Name: iprs_labels_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labels_reposp ON public.sprs_labels_repos USING btree (period);


--
-- Name: iprs_labels_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labels_reposs ON public.sprs_labels_repos USING btree (series);


--
-- Name: iprs_labels_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labels_repost ON public.sprs_labels_repos USING btree ("time");


--
-- Name: iprs_labelsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labelsp ON public.sprs_labels USING btree (period);


--
-- Name: iprs_labelss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labelss ON public.sprs_labels USING btree (series);


--
-- Name: iprs_labelst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_labelst ON public.sprs_labels USING btree ("time");


--
-- Name: iprs_milestonesp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_milestonesp ON public.sprs_milestones USING btree (period);


--
-- Name: iprs_milestoness; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_milestoness ON public.sprs_milestones USING btree (series);


--
-- Name: iprs_milestonest; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iprs_milestonest ON public.sprs_milestones USING btree ("time");


--
-- Name: ipstat_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipstat_reposp ON public.spstat_repos USING btree (period);


--
-- Name: ipstat_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipstat_reposs ON public.spstat_repos USING btree (series);


--
-- Name: ipstat_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipstat_repost ON public.spstat_repos USING btree ("time");


--
-- Name: ipstatp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipstatp ON public.spstat USING btree (period);


--
-- Name: ipstats; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipstats ON public.spstat USING btree (series);


--
-- Name: ipstatt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ipstatt ON public.spstat USING btree ("time");


--
-- Name: iquick_rangesquick_ranges_data; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iquick_rangesquick_ranges_data ON public.tquick_ranges USING btree (quick_ranges_data);


--
-- Name: iquick_rangesquick_ranges_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iquick_rangesquick_ranges_name ON public.tquick_ranges USING btree (quick_ranges_name);


--
-- Name: iquick_rangesquick_ranges_suffix; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iquick_rangesquick_ranges_suffix ON public.tquick_ranges USING btree (quick_ranges_suffix);


--
-- Name: irepo_groupsrepo_group_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX irepo_groupsrepo_group_name ON public.trepo_groups USING btree (repo_group_name);


--
-- Name: irepo_groupsrepo_group_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX irepo_groupsrepo_group_value ON public.trepo_groups USING btree (repo_group_value);


--
-- Name: ireposrepo_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ireposrepo_name ON public.trepos USING btree (repo_name);


--
-- Name: ireposrepo_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ireposrepo_value ON public.trepos USING btree (repo_value);


--
-- Name: ireviewersreviewers_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX ireviewersreviewers_name ON public.treviewers USING btree (reviewers_name);


--
-- Name: isig_mentions_labels_with_allsig_mentions_labels_name_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_mentions_labels_with_allsig_mentions_labels_name_with_all ON public.tsig_mentions_labels_with_all USING btree (sig_mentions_labels_name_with_all);


--
-- Name: isig_mentions_labels_with_allsig_mentions_labels_value_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_mentions_labels_with_allsig_mentions_labels_value_with_all ON public.tsig_mentions_labels_with_all USING btree (sig_mentions_labels_value_with_all);


--
-- Name: isig_mentions_labelssig_mentions_labels_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_mentions_labelssig_mentions_labels_name ON public.tsig_mentions_labels USING btree (sig_mentions_labels_name);


--
-- Name: isig_mentions_labelssig_mentions_labels_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_mentions_labelssig_mentions_labels_value ON public.tsig_mentions_labels USING btree (sig_mentions_labels_value);


--
-- Name: isig_mentions_textssig_mentions_texts_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_mentions_textssig_mentions_texts_name ON public.tsig_mentions_texts USING btree (sig_mentions_texts_name);


--
-- Name: isig_mentions_textssig_mentions_texts_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_mentions_textssig_mentions_texts_value ON public.tsig_mentions_texts USING btree (sig_mentions_texts_value);


--
-- Name: isig_pr_wlabsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_pr_wlabsp ON public.ssig_pr_wlabs USING btree (period);


--
-- Name: isig_pr_wlabst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_pr_wlabst ON public.ssig_pr_wlabs USING btree ("time");


--
-- Name: isig_pr_wlissp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_pr_wlissp ON public.ssig_pr_wliss USING btree (period);


--
-- Name: isig_pr_wlisst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_pr_wlisst ON public.ssig_pr_wliss USING btree ("time");


--
-- Name: isig_pr_wlrelp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_pr_wlrelp ON public.ssig_pr_wlrel USING btree (period);


--
-- Name: isig_pr_wlrelt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_pr_wlrelt ON public.ssig_pr_wlrel USING btree ("time");


--
-- Name: isig_pr_wlrevp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_pr_wlrevp ON public.ssig_pr_wlrev USING btree (period);


--
-- Name: isig_pr_wlrevt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_pr_wlrevt ON public.ssig_pr_wlrev USING btree ("time");


--
-- Name: isig_prs_open_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_prs_open_reposp ON public.ssig_prs_open_repos USING btree (period);


--
-- Name: isig_prs_open_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_prs_open_reposs ON public.ssig_prs_open_repos USING btree (series);


--
-- Name: isig_prs_open_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_prs_open_repost ON public.ssig_prs_open_repos USING btree ("time");


--
-- Name: isig_prs_openp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_prs_openp ON public.ssig_prs_open USING btree (period);


--
-- Name: isig_prs_opent; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isig_prs_opent ON public.ssig_prs_open USING btree ("time");


--
-- Name: isigm_lbl_kinds_with_allsigm_lbl_kind_name_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lbl_kinds_with_allsigm_lbl_kind_name_with_all ON public.tsigm_lbl_kinds_with_all USING btree (sigm_lbl_kind_name_with_all);


--
-- Name: isigm_lbl_kinds_with_allsigm_lbl_kind_value_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lbl_kinds_with_allsigm_lbl_kind_value_with_all ON public.tsigm_lbl_kinds_with_all USING btree (sigm_lbl_kind_value_with_all);


--
-- Name: isigm_lbl_kindssigm_lbl_kind_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lbl_kindssigm_lbl_kind_name ON public.tsigm_lbl_kinds USING btree (sigm_lbl_kind_name);


--
-- Name: isigm_lbl_kindssigm_lbl_kind_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lbl_kindssigm_lbl_kind_value ON public.tsigm_lbl_kinds USING btree (sigm_lbl_kind_value);


--
-- Name: isigm_lskp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lskp ON public.ssigm_lsk USING btree (period);


--
-- Name: isigm_lskrp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lskrp ON public.ssigm_lskr USING btree (period);


--
-- Name: isigm_lskrs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lskrs ON public.ssigm_lskr USING btree (series);


--
-- Name: isigm_lskrt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lskrt ON public.ssigm_lskr USING btree ("time");


--
-- Name: isigm_lsks; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lsks ON public.ssigm_lsk USING btree (series);


--
-- Name: isigm_lskt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_lskt ON public.ssigm_lsk USING btree ("time");


--
-- Name: isigm_txtp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_txtp ON public.ssigm_txt USING btree (period);


--
-- Name: isigm_txtt; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isigm_txtt ON public.ssigm_txt USING btree ("time");


--
-- Name: isize_labels_with_allsize_labels_name_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isize_labels_with_allsize_labels_name_with_all ON public.tsize_labels_with_all USING btree (size_labels_name_with_all);


--
-- Name: isize_labels_with_allsize_labels_value_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX isize_labels_with_allsize_labels_value_with_all ON public.tsize_labels_with_all USING btree (size_labels_value_with_all);


--
-- Name: issues_assignee_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_assignee_id_idx ON public.gha_issues USING btree (assignee_id);


--
-- Name: issues_closed_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_closed_at_idx ON public.gha_issues USING btree (closed_at);


--
-- Name: issues_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_created_at_idx ON public.gha_issues USING btree (created_at);


--
-- Name: issues_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_dup_actor_id_idx ON public.gha_issues USING btree (dup_actor_id);


--
-- Name: issues_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_dup_actor_login_idx ON public.gha_issues USING btree (dup_actor_login);


--
-- Name: issues_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_dup_created_at_idx ON public.gha_issues USING btree (dup_created_at);


--
-- Name: issues_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_dup_repo_id_idx ON public.gha_issues USING btree (dup_repo_id);


--
-- Name: issues_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_dup_repo_name_idx ON public.gha_issues USING btree (dup_repo_name);


--
-- Name: issues_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_dup_type_idx ON public.gha_issues USING btree (dup_type);


--
-- Name: issues_dup_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_dup_user_login_idx ON public.gha_issues USING btree (dup_user_login);


--
-- Name: issues_dupn_assignee_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_dupn_assignee_login_idx ON public.gha_issues USING btree (dupn_assignee_login);


--
-- Name: issues_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_event_id_idx ON public.gha_issues USING btree (event_id);


--
-- Name: issues_events_labels_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_actor_id_idx ON public.gha_issues_events_labels USING btree (actor_id);


--
-- Name: issues_events_labels_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_actor_login_idx ON public.gha_issues_events_labels USING btree (actor_login);


--
-- Name: issues_events_labels_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_created_at_idx ON public.gha_issues_events_labels USING btree (created_at);


--
-- Name: issues_events_labels_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_event_id_idx ON public.gha_issues_events_labels USING btree (event_id);


--
-- Name: issues_events_labels_issue_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_issue_id_idx ON public.gha_issues_events_labels USING btree (issue_id);


--
-- Name: issues_events_labels_issue_number_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_issue_number_idx ON public.gha_issues_events_labels USING btree (issue_number);


--
-- Name: issues_events_labels_label_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_label_id_idx ON public.gha_issues_events_labels USING btree (label_id);


--
-- Name: issues_events_labels_label_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_label_name_idx ON public.gha_issues_events_labels USING btree (label_name);


--
-- Name: issues_events_labels_lower_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_lower_actor_login_idx ON public.gha_issues_events_labels USING btree (lower((actor_login)::text));


--
-- Name: issues_events_labels_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_repo_id_idx ON public.gha_issues_events_labels USING btree (repo_id);


--
-- Name: issues_events_labels_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_repo_name_idx ON public.gha_issues_events_labels USING btree (repo_name);


--
-- Name: issues_events_labels_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_events_labels_type_idx ON public.gha_issues_events_labels USING btree (type);


--
-- Name: issues_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_id_idx ON public.gha_issues USING btree (id);


--
-- Name: issues_is_pull_request_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_is_pull_request_idx ON public.gha_issues USING btree (is_pull_request);


--
-- Name: issues_labels_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_dup_actor_id_idx ON public.gha_issues_labels USING btree (dup_actor_id);


--
-- Name: issues_labels_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_dup_actor_login_idx ON public.gha_issues_labels USING btree (dup_actor_login);


--
-- Name: issues_labels_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_dup_created_at_idx ON public.gha_issues_labels USING btree (dup_created_at);


--
-- Name: issues_labels_dup_issue_number_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_dup_issue_number_idx ON public.gha_issues_labels USING btree (dup_issue_number);


--
-- Name: issues_labels_dup_label_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_dup_label_name_idx ON public.gha_issues_labels USING btree (dup_label_name);


--
-- Name: issues_labels_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_dup_repo_id_idx ON public.gha_issues_labels USING btree (dup_repo_id);


--
-- Name: issues_labels_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_dup_repo_name_idx ON public.gha_issues_labels USING btree (dup_repo_name);


--
-- Name: issues_labels_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_dup_type_idx ON public.gha_issues_labels USING btree (dup_type);


--
-- Name: issues_labels_lower_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_labels_lower_dup_actor_login_idx ON public.gha_issues_labels USING btree (lower((dup_actor_login)::text));


--
-- Name: issues_lower_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_lower_dup_actor_login_idx ON public.gha_issues USING btree (lower((dup_actor_login)::text));


--
-- Name: issues_lower_dup_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_lower_dup_user_login_idx ON public.gha_issues USING btree (lower((dup_user_login)::text));


--
-- Name: issues_milestone_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_milestone_id_idx ON public.gha_issues USING btree (milestone_id);


--
-- Name: issues_number_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_number_idx ON public.gha_issues USING btree (number);


--
-- Name: issues_pull_requests_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_pull_requests_created_at_idx ON public.gha_issues_pull_requests USING btree (created_at);


--
-- Name: issues_pull_requests_issue_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_pull_requests_issue_id_idx ON public.gha_issues_pull_requests USING btree (issue_id);


--
-- Name: issues_pull_requests_number_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_pull_requests_number_idx ON public.gha_issues_pull_requests USING btree (number);


--
-- Name: issues_pull_requests_pull_request_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_pull_requests_pull_request_id_idx ON public.gha_issues_pull_requests USING btree (pull_request_id);


--
-- Name: issues_pull_requests_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_pull_requests_repo_id_idx ON public.gha_issues_pull_requests USING btree (repo_id);


--
-- Name: issues_pull_requests_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_pull_requests_repo_name_idx ON public.gha_issues_pull_requests USING btree (repo_name);


--
-- Name: issues_repo_created_at_issues_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_repo_created_at_issues_idx ON public.gha_issues USING btree (dup_repo_id, dup_repo_name, created_at) WHERE (is_pull_request = false);


--
-- Name: issues_repo_created_at_prs_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_repo_created_at_prs_idx ON public.gha_issues USING btree (dup_repo_id, dup_repo_name, created_at) WHERE (is_pull_request = true);


--
-- Name: issues_state_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_state_idx ON public.gha_issues USING btree (state);


--
-- Name: issues_updated_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_updated_at_idx ON public.gha_issues USING btree (updated_at);


--
-- Name: issues_user_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX issues_user_id_idx ON public.gha_issues USING btree (user_id);


--
-- Name: itime_metrics_reposp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itime_metrics_reposp ON public.stime_metrics_repos USING btree (period);


--
-- Name: itime_metrics_reposs; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itime_metrics_reposs ON public.stime_metrics_repos USING btree (series);


--
-- Name: itime_metrics_repost; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itime_metrics_repost ON public.stime_metrics_repos USING btree ("time");


--
-- Name: itime_metricsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itime_metricsp ON public.stime_metrics USING btree (period);


--
-- Name: itime_metricss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itime_metricss ON public.stime_metrics USING btree (series);


--
-- Name: itime_metricst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itime_metricst ON public.stime_metrics USING btree ("time");


--
-- Name: itop_repo_names_with_alltop_repo_names_name_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itop_repo_names_with_alltop_repo_names_name_with_all ON public.ttop_repo_names_with_all USING btree (top_repo_names_name_with_all);


--
-- Name: itop_repo_names_with_alltop_repo_names_value_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itop_repo_names_with_alltop_repo_names_value_with_all ON public.ttop_repo_names_with_all USING btree (top_repo_names_value_with_all);


--
-- Name: itop_repo_namestop_repo_names_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itop_repo_namestop_repo_names_name ON public.ttop_repo_names USING btree (top_repo_names_name);


--
-- Name: itop_repo_namestop_repo_names_value; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itop_repo_namestop_repo_names_value ON public.ttop_repo_names USING btree (top_repo_names_value);


--
-- Name: itop_repos_with_alltop_repos_name_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itop_repos_with_alltop_repos_name_with_all ON public.ttop_repos_with_all USING btree (top_repos_name_with_all);


--
-- Name: itop_repos_with_alltop_repos_value_with_all; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX itop_repos_with_alltop_repos_value_with_all ON public.ttop_repos_with_all USING btree (top_repos_value_with_all);


--
-- Name: iuser_reviewsp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iuser_reviewsp ON public.suser_reviews USING btree (period);


--
-- Name: iuser_reviewss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iuser_reviewss ON public.suser_reviews USING btree (series);


--
-- Name: iuser_reviewst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iuser_reviewst ON public.suser_reviews USING btree ("time");


--
-- Name: iusersusers_name; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iusersusers_name ON public.tusers USING btree (users_name);


--
-- Name: iwatchersp; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iwatchersp ON public.swatchers USING btree (period);


--
-- Name: iwatcherss; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iwatcherss ON public.swatchers USING btree (series);


--
-- Name: iwatcherst; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX iwatcherst ON public.swatchers USING btree ("time");


--
-- Name: labels_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX labels_name_idx ON public.gha_labels USING btree (name);


--
-- Name: logs_dt_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX logs_dt_idx ON public.gha_logs USING btree (dt);


--
-- Name: logs_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX logs_id_idx ON public.gha_logs USING btree (id);


--
-- Name: logs_prog_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX logs_prog_idx ON public.gha_logs USING btree (prog);


--
-- Name: logs_proj_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX logs_proj_idx ON public.gha_logs USING btree (proj);


--
-- Name: logs_run_dt_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX logs_run_dt_idx ON public.gha_logs USING btree (run_dt);


--
-- Name: milestones_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_created_at_idx ON public.gha_milestones USING btree (created_at);


--
-- Name: milestones_creator_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_creator_id_idx ON public.gha_milestones USING btree (creator_id);


--
-- Name: milestones_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_dup_actor_id_idx ON public.gha_milestones USING btree (dup_actor_id);


--
-- Name: milestones_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_dup_actor_login_idx ON public.gha_milestones USING btree (dup_actor_login);


--
-- Name: milestones_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_dup_created_at_idx ON public.gha_milestones USING btree (dup_created_at);


--
-- Name: milestones_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_dup_repo_id_idx ON public.gha_milestones USING btree (dup_repo_id);


--
-- Name: milestones_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_dup_repo_name_idx ON public.gha_milestones USING btree (dup_repo_name);


--
-- Name: milestones_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_dup_type_idx ON public.gha_milestones USING btree (dup_type);


--
-- Name: milestones_dupn_creator_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_dupn_creator_login_idx ON public.gha_milestones USING btree (dupn_creator_login);


--
-- Name: milestones_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_event_id_idx ON public.gha_milestones USING btree (event_id);


--
-- Name: milestones_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_id_idx ON public.gha_milestones USING btree (id);


--
-- Name: milestones_state_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_state_idx ON public.gha_milestones USING btree (state);


--
-- Name: milestones_updated_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX milestones_updated_at_idx ON public.gha_milestones USING btree (updated_at);


--
-- Name: orgs_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX orgs_login_idx ON public.gha_orgs USING btree (login);


--
-- Name: pages_action_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pages_action_idx ON public.gha_pages USING btree (action);


--
-- Name: pages_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pages_dup_actor_id_idx ON public.gha_pages USING btree (dup_actor_id);


--
-- Name: pages_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pages_dup_actor_login_idx ON public.gha_pages USING btree (dup_actor_login);


--
-- Name: pages_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pages_dup_created_at_idx ON public.gha_pages USING btree (dup_created_at);


--
-- Name: pages_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pages_dup_repo_id_idx ON public.gha_pages USING btree (dup_repo_id);


--
-- Name: pages_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pages_dup_repo_name_idx ON public.gha_pages USING btree (dup_repo_name);


--
-- Name: pages_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pages_dup_type_idx ON public.gha_pages USING btree (dup_type);


--
-- Name: pages_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pages_event_id_idx ON public.gha_pages USING btree (event_id);


--
-- Name: parsed_dt_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX parsed_dt_idx ON public.gha_parsed USING btree (dt);


--
-- Name: payloads_action_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_action_idx ON public.gha_payloads USING btree (action);


--
-- Name: payloads_comment_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_comment_id_idx ON public.gha_payloads USING btree (comment_id);


--
-- Name: payloads_commit_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_commit_idx ON public.gha_payloads USING btree (commit);


--
-- Name: payloads_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_dup_actor_id_idx ON public.gha_payloads USING btree (dup_actor_id);


--
-- Name: payloads_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_dup_actor_login_idx ON public.gha_payloads USING btree (dup_actor_login);


--
-- Name: payloads_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_dup_created_at_idx ON public.gha_payloads USING btree (dup_created_at);


--
-- Name: payloads_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_dup_repo_id_idx ON public.gha_payloads USING btree (dup_repo_id);


--
-- Name: payloads_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_dup_repo_name_idx ON public.gha_payloads USING btree (dup_repo_name);


--
-- Name: payloads_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_dup_type_idx ON public.gha_payloads USING btree (dup_type);


--
-- Name: payloads_forkee_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_forkee_id_idx ON public.gha_payloads USING btree (forkee_id);


--
-- Name: payloads_head_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_head_idx ON public.gha_payloads USING btree (head);


--
-- Name: payloads_issue_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_issue_id_idx ON public.gha_payloads USING btree (issue_id);


--
-- Name: payloads_member_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_member_id_idx ON public.gha_payloads USING btree (member_id);


--
-- Name: payloads_pull_request_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_pull_request_id_idx ON public.gha_payloads USING btree (issue_id);


--
-- Name: payloads_ref_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_ref_type_idx ON public.gha_payloads USING btree (ref_type);


--
-- Name: payloads_release_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX payloads_release_id_idx ON public.gha_payloads USING btree (release_id);


--
-- Name: pull_requests_assignee_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_assignee_id_idx ON public.gha_pull_requests USING btree (assignee_id);


--
-- Name: pull_requests_base_sha_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_base_sha_idx ON public.gha_pull_requests USING btree (base_sha);


--
-- Name: pull_requests_closed_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_closed_at_idx ON public.gha_pull_requests USING btree (closed_at);


--
-- Name: pull_requests_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_created_at_idx ON public.gha_pull_requests USING btree (created_at);


--
-- Name: pull_requests_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dup_actor_id_idx ON public.gha_pull_requests USING btree (dup_actor_id);


--
-- Name: pull_requests_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dup_actor_login_idx ON public.gha_pull_requests USING btree (dup_actor_login);


--
-- Name: pull_requests_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dup_created_at_idx ON public.gha_pull_requests USING btree (dup_created_at);


--
-- Name: pull_requests_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dup_repo_id_idx ON public.gha_pull_requests USING btree (dup_repo_id);


--
-- Name: pull_requests_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dup_repo_name_idx ON public.gha_pull_requests USING btree (dup_repo_name);


--
-- Name: pull_requests_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dup_type_idx ON public.gha_pull_requests USING btree (dup_type);


--
-- Name: pull_requests_dup_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dup_user_login_idx ON public.gha_pull_requests USING btree (dup_user_login);


--
-- Name: pull_requests_dupn_assignee_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dupn_assignee_login_idx ON public.gha_pull_requests USING btree (dupn_assignee_login);


--
-- Name: pull_requests_dupn_merged_by_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_dupn_merged_by_login_idx ON public.gha_pull_requests USING btree (dupn_merged_by_login);


--
-- Name: pull_requests_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_event_id_idx ON public.gha_pull_requests USING btree (event_id);


--
-- Name: pull_requests_head_sha_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_head_sha_idx ON public.gha_pull_requests USING btree (head_sha);


--
-- Name: pull_requests_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_id_idx ON public.gha_pull_requests USING btree (id);


--
-- Name: pull_requests_lower_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_lower_dup_actor_login_idx ON public.gha_pull_requests USING btree (lower((dup_actor_login)::text));


--
-- Name: pull_requests_lower_dup_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_lower_dup_user_login_idx ON public.gha_pull_requests USING btree (lower((dup_user_login)::text));


--
-- Name: pull_requests_lower_dupn_merged_by_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_lower_dupn_merged_by_login_idx ON public.gha_pull_requests USING btree (lower((dupn_merged_by_login)::text));


--
-- Name: pull_requests_merged_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_merged_at_idx ON public.gha_pull_requests USING btree (merged_at);


--
-- Name: pull_requests_merged_by_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_merged_by_id_idx ON public.gha_pull_requests USING btree (merged_by_id);


--
-- Name: pull_requests_milestone_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_milestone_id_idx ON public.gha_pull_requests USING btree (milestone_id);


--
-- Name: pull_requests_number_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_number_idx ON public.gha_pull_requests USING btree (number);


--
-- Name: pull_requests_repo_merged_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_repo_merged_at_idx ON public.gha_pull_requests USING btree (dup_repo_id, dup_repo_name, merged_at) WHERE (merged_at IS NOT NULL);


--
-- Name: pull_requests_state_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_state_idx ON public.gha_pull_requests USING btree (state);


--
-- Name: pull_requests_updated_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_updated_at_idx ON public.gha_pull_requests USING btree (updated_at);


--
-- Name: pull_requests_user_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX pull_requests_user_id_idx ON public.gha_pull_requests USING btree (user_id);


--
-- Name: releases_author_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_author_id_idx ON public.gha_releases USING btree (author_id);


--
-- Name: releases_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_created_at_idx ON public.gha_releases USING btree (created_at);


--
-- Name: releases_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_dup_actor_id_idx ON public.gha_releases USING btree (dup_actor_id);


--
-- Name: releases_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_dup_actor_login_idx ON public.gha_releases USING btree (dup_actor_login);


--
-- Name: releases_dup_author_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_dup_author_login_idx ON public.gha_releases USING btree (dup_author_login);


--
-- Name: releases_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_dup_created_at_idx ON public.gha_releases USING btree (dup_created_at);


--
-- Name: releases_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_dup_repo_id_idx ON public.gha_releases USING btree (dup_repo_id);


--
-- Name: releases_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_dup_repo_name_idx ON public.gha_releases USING btree (dup_repo_name);


--
-- Name: releases_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_dup_type_idx ON public.gha_releases USING btree (dup_type);


--
-- Name: releases_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX releases_event_id_idx ON public.gha_releases USING btree (event_id);


--
-- Name: repo_groups_alias_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repo_groups_alias_idx ON public.gha_repo_groups USING btree (alias);


--
-- Name: repo_groups_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repo_groups_id_idx ON public.gha_repo_groups USING btree (id);


--
-- Name: repo_groups_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repo_groups_name_idx ON public.gha_repo_groups USING btree (name);


--
-- Name: repo_groups_org_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repo_groups_org_id_idx ON public.gha_repo_groups USING btree (org_id);


--
-- Name: repo_groups_org_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repo_groups_org_login_idx ON public.gha_repo_groups USING btree (org_login);


--
-- Name: repo_groups_repo_group_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repo_groups_repo_group_idx ON public.gha_repo_groups USING btree (repo_group);


--
-- Name: repos_alias_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_alias_idx ON public.gha_repos USING btree (alias);


--
-- Name: repos_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_created_at_idx ON public.gha_repos USING btree (created_at);


--
-- Name: repos_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_id_idx ON public.gha_repos USING btree (id);


--
-- Name: repos_langs_lang_loc_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_langs_lang_loc_idx ON public.gha_repos_langs USING btree (lang_loc);


--
-- Name: repos_langs_lang_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_langs_lang_name_idx ON public.gha_repos_langs USING btree (lang_name);


--
-- Name: repos_langs_lang_perc_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_langs_lang_perc_idx ON public.gha_repos_langs USING btree (lang_perc);


--
-- Name: repos_langs_narepo_me_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_langs_narepo_me_idx ON public.gha_repos_langs USING btree (repo_name);


--
-- Name: repos_license_key_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_license_key_idx ON public.gha_repos USING btree (license_key);


--
-- Name: repos_license_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_license_name_idx ON public.gha_repos USING btree (license_name);


--
-- Name: repos_license_prob_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_license_prob_idx ON public.gha_repos USING btree (license_prob);


--
-- Name: repos_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_name_idx ON public.gha_repos USING btree (name);


--
-- Name: repos_org_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_org_id_idx ON public.gha_repos USING btree (org_id);


--
-- Name: repos_org_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_org_login_idx ON public.gha_repos USING btree (org_login);


--
-- Name: repos_repo_group_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_repo_group_idx ON public.gha_repos USING btree (repo_group);


--
-- Name: repos_updated_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX repos_updated_at_idx ON public.gha_repos USING btree (updated_at);


--
-- Name: reviews_commit_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_commit_id_idx ON public.gha_reviews USING btree (commit_id);


--
-- Name: reviews_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_dup_actor_id_idx ON public.gha_reviews USING btree (dup_actor_id);


--
-- Name: reviews_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_dup_actor_login_idx ON public.gha_reviews USING btree (dup_actor_login);


--
-- Name: reviews_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_dup_created_at_idx ON public.gha_reviews USING btree (dup_created_at);


--
-- Name: reviews_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_dup_repo_id_idx ON public.gha_reviews USING btree (dup_repo_id);


--
-- Name: reviews_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_dup_repo_name_idx ON public.gha_reviews USING btree (dup_repo_name);


--
-- Name: reviews_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_dup_type_idx ON public.gha_reviews USING btree (dup_type);


--
-- Name: reviews_dup_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_dup_user_login_idx ON public.gha_reviews USING btree (dup_user_login);


--
-- Name: reviews_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_event_id_idx ON public.gha_reviews USING btree (event_id);


--
-- Name: reviews_lower_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_lower_dup_actor_login_idx ON public.gha_reviews USING btree (lower((dup_actor_login)::text));


--
-- Name: reviews_lower_dup_user_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_lower_dup_user_login_idx ON public.gha_reviews USING btree (lower((dup_user_login)::text));


--
-- Name: reviews_submitted_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_submitted_at_idx ON public.gha_reviews USING btree (submitted_at);


--
-- Name: reviews_user_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX reviews_user_id_idx ON public.gha_reviews USING btree (user_id);


--
-- Name: skip_commits_dt_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX skip_commits_dt_idx ON public.gha_skip_commits USING btree (dt);


--
-- Name: skip_commits_reason_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX skip_commits_reason_idx ON public.gha_skip_commits USING btree (reason);


--
-- Name: skip_commits_sha_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX skip_commits_sha_idx ON public.gha_skip_commits USING btree (sha);


--
-- Name: teams_dup_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_dup_actor_id_idx ON public.gha_teams USING btree (dup_actor_id);


--
-- Name: teams_dup_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_dup_actor_login_idx ON public.gha_teams USING btree (dup_actor_login);


--
-- Name: teams_dup_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_dup_created_at_idx ON public.gha_teams USING btree (dup_created_at);


--
-- Name: teams_dup_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_dup_repo_id_idx ON public.gha_teams USING btree (dup_repo_id);


--
-- Name: teams_dup_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_dup_repo_name_idx ON public.gha_teams USING btree (dup_repo_name);


--
-- Name: teams_dup_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_dup_type_idx ON public.gha_teams USING btree (dup_type);


--
-- Name: teams_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_event_id_idx ON public.gha_teams USING btree (event_id);


--
-- Name: teams_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_name_idx ON public.gha_teams USING btree (name);


--
-- Name: teams_permission_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_permission_idx ON public.gha_teams USING btree (permission);


--
-- Name: teams_slug_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX teams_slug_idx ON public.gha_teams USING btree (slug);


--
-- Name: texts_actor_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX texts_actor_id_idx ON public.gha_texts USING btree (actor_id);


--
-- Name: texts_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX texts_actor_login_idx ON public.gha_texts USING btree (actor_login);


--
-- Name: texts_created_at_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX texts_created_at_idx ON public.gha_texts USING btree (created_at);


--
-- Name: texts_event_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX texts_event_id_idx ON public.gha_texts USING btree (event_id);


--
-- Name: texts_lower_actor_login_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX texts_lower_actor_login_idx ON public.gha_texts USING btree (lower((actor_login)::text));


--
-- Name: texts_repo_id_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX texts_repo_id_idx ON public.gha_texts USING btree (repo_id);


--
-- Name: texts_repo_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX texts_repo_name_idx ON public.gha_texts USING btree (repo_name);


--
-- Name: texts_type_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX texts_type_idx ON public.gha_texts USING btree (type);


--
-- Name: vars_name_idx; Type: INDEX; Schema: public; Owner: gha_admin
--

CREATE INDEX vars_name_idx ON public.gha_vars USING btree (name);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO gha_admin;


--
-- Name: TABLE gha_actors; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_actors TO ro_user;
GRANT SELECT ON TABLE public.gha_actors TO devstats_team;


--
-- Name: TABLE gha_actors_affiliations; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_actors_affiliations TO ro_user;
GRANT SELECT ON TABLE public.gha_actors_affiliations TO devstats_team;


--
-- Name: TABLE gha_actors_emails; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_actors_emails TO ro_user;
GRANT SELECT ON TABLE public.gha_actors_emails TO devstats_team;


--
-- Name: TABLE gha_actors_names; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_actors_names TO ro_user;
GRANT SELECT ON TABLE public.gha_actors_names TO devstats_team;


--
-- Name: TABLE gha_assets; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_assets TO ro_user;
GRANT SELECT ON TABLE public.gha_assets TO devstats_team;


--
-- Name: TABLE gha_bot_logins; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_bot_logins TO ro_user;
GRANT SELECT ON TABLE public.gha_bot_logins TO devstats_team;


--
-- Name: TABLE gha_branches; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_branches TO ro_user;
GRANT SELECT ON TABLE public.gha_branches TO devstats_team;


--
-- Name: TABLE gha_comments; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_comments TO ro_user;
GRANT SELECT ON TABLE public.gha_comments TO devstats_team;


--
-- Name: TABLE gha_commits; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_commits TO ro_user;
GRANT SELECT ON TABLE public.gha_commits TO devstats_team;


--
-- Name: TABLE gha_commits_files; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_commits_files TO ro_user;
GRANT SELECT ON TABLE public.gha_commits_files TO devstats_team;


--
-- Name: TABLE gha_commits_roles; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_commits_roles TO ro_user;
GRANT SELECT ON TABLE public.gha_commits_roles TO devstats_team;


--
-- Name: TABLE gha_companies; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_companies TO ro_user;
GRANT SELECT ON TABLE public.gha_companies TO devstats_team;


--
-- Name: TABLE gha_computed; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_computed TO ro_user;
GRANT SELECT ON TABLE public.gha_computed TO devstats_team;


--
-- Name: TABLE gha_countries; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_countries TO ro_user;
GRANT SELECT ON TABLE public.gha_countries TO devstats_team;


--
-- Name: TABLE gha_events; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_events TO ro_user;
GRANT SELECT ON TABLE public.gha_events TO devstats_team;


--
-- Name: TABLE gha_events_commits_files; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_events_commits_files TO ro_user;
GRANT SELECT ON TABLE public.gha_events_commits_files TO devstats_team;


--
-- Name: TABLE gha_forkees; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_forkees TO ro_user;
GRANT SELECT ON TABLE public.gha_forkees TO devstats_team;


--
-- Name: TABLE gha_imported_shas; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_imported_shas TO ro_user;
GRANT SELECT ON TABLE public.gha_imported_shas TO devstats_team;


--
-- Name: TABLE gha_issues; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_issues TO ro_user;
GRANT SELECT ON TABLE public.gha_issues TO devstats_team;


--
-- Name: TABLE gha_issues_assignees; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_issues_assignees TO ro_user;
GRANT SELECT ON TABLE public.gha_issues_assignees TO devstats_team;


--
-- Name: TABLE gha_issues_events_labels; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_issues_events_labels TO ro_user;
GRANT SELECT ON TABLE public.gha_issues_events_labels TO devstats_team;


--
-- Name: TABLE gha_issues_labels; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_issues_labels TO ro_user;
GRANT SELECT ON TABLE public.gha_issues_labels TO devstats_team;


--
-- Name: TABLE gha_issues_pull_requests; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_issues_pull_requests TO ro_user;
GRANT SELECT ON TABLE public.gha_issues_pull_requests TO devstats_team;


--
-- Name: TABLE gha_labels; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_labels TO ro_user;
GRANT SELECT ON TABLE public.gha_labels TO devstats_team;


--
-- Name: TABLE gha_last_computed; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_last_computed TO ro_user;
GRANT SELECT ON TABLE public.gha_last_computed TO devstats_team;


--
-- Name: TABLE gha_logs; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_logs TO ro_user;
GRANT SELECT ON TABLE public.gha_logs TO devstats_team;


--
-- Name: TABLE gha_milestones; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_milestones TO ro_user;
GRANT SELECT ON TABLE public.gha_milestones TO devstats_team;


--
-- Name: TABLE gha_orgs; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_orgs TO ro_user;
GRANT SELECT ON TABLE public.gha_orgs TO devstats_team;


--
-- Name: TABLE gha_pages; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_pages TO ro_user;
GRANT SELECT ON TABLE public.gha_pages TO devstats_team;


--
-- Name: TABLE gha_parsed; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_parsed TO ro_user;
GRANT SELECT ON TABLE public.gha_parsed TO devstats_team;


--
-- Name: TABLE gha_payloads; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_payloads TO ro_user;
GRANT SELECT ON TABLE public.gha_payloads TO devstats_team;


--
-- Name: TABLE gha_postprocess_scripts; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_postprocess_scripts TO ro_user;
GRANT SELECT ON TABLE public.gha_postprocess_scripts TO devstats_team;


--
-- Name: TABLE gha_pull_requests; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_pull_requests TO ro_user;
GRANT SELECT ON TABLE public.gha_pull_requests TO devstats_team;


--
-- Name: TABLE gha_pull_requests_assignees; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_pull_requests_assignees TO ro_user;
GRANT SELECT ON TABLE public.gha_pull_requests_assignees TO devstats_team;


--
-- Name: TABLE gha_pull_requests_requested_reviewers; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_pull_requests_requested_reviewers TO ro_user;
GRANT SELECT ON TABLE public.gha_pull_requests_requested_reviewers TO devstats_team;


--
-- Name: TABLE gha_releases; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_releases TO ro_user;
GRANT SELECT ON TABLE public.gha_releases TO devstats_team;


--
-- Name: TABLE gha_releases_assets; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_releases_assets TO ro_user;
GRANT SELECT ON TABLE public.gha_releases_assets TO devstats_team;


--
-- Name: TABLE gha_repo_groups; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_repo_groups TO ro_user;
GRANT SELECT ON TABLE public.gha_repo_groups TO devstats_team;


--
-- Name: TABLE gha_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_repos TO ro_user;
GRANT SELECT ON TABLE public.gha_repos TO devstats_team;


--
-- Name: TABLE gha_repos_langs; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_repos_langs TO ro_user;
GRANT SELECT ON TABLE public.gha_repos_langs TO devstats_team;


--
-- Name: TABLE gha_reviews; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_reviews TO ro_user;
GRANT SELECT ON TABLE public.gha_reviews TO devstats_team;


--
-- Name: TABLE gha_skip_commits; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_skip_commits TO ro_user;
GRANT SELECT ON TABLE public.gha_skip_commits TO devstats_team;


--
-- Name: TABLE gha_teams; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_teams TO ro_user;
GRANT SELECT ON TABLE public.gha_teams TO devstats_team;


--
-- Name: TABLE gha_teams_repositories; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_teams_repositories TO ro_user;
GRANT SELECT ON TABLE public.gha_teams_repositories TO devstats_team;


--
-- Name: TABLE gha_texts; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_texts TO ro_user;
GRANT SELECT ON TABLE public.gha_texts TO devstats_team;


--
-- Name: TABLE gha_vars; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.gha_vars TO ro_user;
GRANT SELECT ON TABLE public.gha_vars TO devstats_team;


--
-- Name: TABLE sannotations; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sannotations TO ro_user;
GRANT SELECT ON TABLE public.sannotations TO devstats_team;


--
-- Name: TABLE sawaiting_prs_by_sig_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sawaiting_prs_by_sig_repos TO ro_user;
GRANT SELECT ON TABLE public.sawaiting_prs_by_sig_repos TO devstats_team;


--
-- Name: TABLE sawaiting_prs_by_sigd10; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sawaiting_prs_by_sigd10 TO ro_user;
GRANT SELECT ON TABLE public.sawaiting_prs_by_sigd10 TO devstats_team;


--
-- Name: TABLE sawaiting_prs_by_sigd30; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sawaiting_prs_by_sigd30 TO ro_user;
GRANT SELECT ON TABLE public.sawaiting_prs_by_sigd30 TO devstats_team;


--
-- Name: TABLE sawaiting_prs_by_sigd60; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sawaiting_prs_by_sigd60 TO ro_user;
GRANT SELECT ON TABLE public.sawaiting_prs_by_sigd60 TO devstats_team;


--
-- Name: TABLE sawaiting_prs_by_sigd90; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sawaiting_prs_by_sigd90 TO ro_user;
GRANT SELECT ON TABLE public.sawaiting_prs_by_sigd90 TO devstats_team;


--
-- Name: TABLE sawaiting_prs_by_sigy; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sawaiting_prs_by_sigy TO ro_user;
GRANT SELECT ON TABLE public.sawaiting_prs_by_sigy TO devstats_team;


--
-- Name: TABLE sbot_commands; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sbot_commands TO ro_user;
GRANT SELECT ON TABLE public.sbot_commands TO devstats_team;


--
-- Name: TABLE sbot_commands_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sbot_commands_repos TO ro_user;
GRANT SELECT ON TABLE public.sbot_commands_repos TO devstats_team;


--
-- Name: TABLE scntrs_and_orgs; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.scntrs_and_orgs TO ro_user;
GRANT SELECT ON TABLE public.scntrs_and_orgs TO devstats_team;


--
-- Name: TABLE scompany_activity; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.scompany_activity TO ro_user;
GRANT SELECT ON TABLE public.scompany_activity TO devstats_team;


--
-- Name: TABLE scompany_activity_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.scompany_activity_repos TO ro_user;
GRANT SELECT ON TABLE public.scompany_activity_repos TO devstats_team;


--
-- Name: TABLE scompany_prs_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.scompany_prs_repos TO ro_user;
GRANT SELECT ON TABLE public.scompany_prs_repos TO devstats_team;


--
-- Name: TABLE scountries; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.scountries TO ro_user;
GRANT SELECT ON TABLE public.scountries TO devstats_team;


--
-- Name: TABLE scountriescum; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.scountriescum TO ro_user;
GRANT SELECT ON TABLE public.scountriescum TO devstats_team;


--
-- Name: TABLE scs; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.scs TO ro_user;
GRANT SELECT ON TABLE public.scs TO devstats_team;


--
-- Name: TABLE scsr; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.scsr TO ro_user;
GRANT SELECT ON TABLE public.scsr TO devstats_team;


--
-- Name: TABLE sepisodic_contributors; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sepisodic_contributors TO ro_user;
GRANT SELECT ON TABLE public.sepisodic_contributors TO devstats_team;


--
-- Name: TABLE sepisodic_contributors_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sepisodic_contributors_repos TO ro_user;
GRANT SELECT ON TABLE public.sepisodic_contributors_repos TO devstats_team;


--
-- Name: TABLE sepisodic_issues; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sepisodic_issues TO ro_user;
GRANT SELECT ON TABLE public.sepisodic_issues TO devstats_team;


--
-- Name: TABLE sepisodic_issues_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sepisodic_issues_repos TO ro_user;
GRANT SELECT ON TABLE public.sepisodic_issues_repos TO devstats_team;


--
-- Name: TABLE sevents_h; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sevents_h TO ro_user;
GRANT SELECT ON TABLE public.sevents_h TO devstats_team;


--
-- Name: TABLE sfirst_non_author; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sfirst_non_author TO ro_user;
GRANT SELECT ON TABLE public.sfirst_non_author TO devstats_team;


--
-- Name: TABLE sfirst_non_author_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sfirst_non_author_repos TO ro_user;
GRANT SELECT ON TABLE public.sfirst_non_author_repos TO devstats_team;


--
-- Name: TABLE sgh_stats_r; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sgh_stats_r TO ro_user;
GRANT SELECT ON TABLE public.sgh_stats_r TO devstats_team;


--
-- Name: TABLE sgh_stats_rgrp; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sgh_stats_rgrp TO ro_user;
GRANT SELECT ON TABLE public.sgh_stats_rgrp TO devstats_team;


--
-- Name: TABLE shcom; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.shcom TO ro_user;
GRANT SELECT ON TABLE public.shcom TO devstats_team;


--
-- Name: TABLE shdev; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.shdev TO ro_user;
GRANT SELECT ON TABLE public.shdev TO devstats_team;


--
-- Name: TABLE shdev_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.shdev_repos TO ro_user;
GRANT SELECT ON TABLE public.shdev_repos TO devstats_team;


--
-- Name: TABLE shpr_mergers; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.shpr_mergers TO ro_user;
GRANT SELECT ON TABLE public.shpr_mergers TO devstats_team;


--
-- Name: TABLE shpr_wlsigs; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.shpr_wlsigs TO ro_user;
GRANT SELECT ON TABLE public.shpr_wlsigs TO devstats_team;


--
-- Name: TABLE shpr_wrlsigs; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.shpr_wrlsigs TO ro_user;
GRANT SELECT ON TABLE public.shpr_wrlsigs TO devstats_team;


--
-- Name: TABLE siclosed_lsk; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.siclosed_lsk TO ro_user;
GRANT SELECT ON TABLE public.siclosed_lsk TO devstats_team;


--
-- Name: TABLE siclosed_lskr; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.siclosed_lskr TO ro_user;
GRANT SELECT ON TABLE public.siclosed_lskr TO devstats_team;


--
-- Name: TABLE sinactive_issues_by_sig_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sinactive_issues_by_sig_repos TO ro_user;
GRANT SELECT ON TABLE public.sinactive_issues_by_sig_repos TO devstats_team;


--
-- Name: TABLE sinactive_issues_by_sigd30; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sinactive_issues_by_sigd30 TO ro_user;
GRANT SELECT ON TABLE public.sinactive_issues_by_sigd30 TO devstats_team;


--
-- Name: TABLE sinactive_issues_by_sigd90; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sinactive_issues_by_sigd90 TO ro_user;
GRANT SELECT ON TABLE public.sinactive_issues_by_sigd90 TO devstats_team;


--
-- Name: TABLE sinactive_issues_by_sigw2; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sinactive_issues_by_sigw2 TO ro_user;
GRANT SELECT ON TABLE public.sinactive_issues_by_sigw2 TO devstats_team;


--
-- Name: TABLE sinactive_prs_by_sig_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sinactive_prs_by_sig_repos TO ro_user;
GRANT SELECT ON TABLE public.sinactive_prs_by_sig_repos TO devstats_team;


--
-- Name: TABLE sinactive_prs_by_sigd30; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sinactive_prs_by_sigd30 TO ro_user;
GRANT SELECT ON TABLE public.sinactive_prs_by_sigd30 TO devstats_team;


--
-- Name: TABLE sinactive_prs_by_sigd90; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sinactive_prs_by_sigd90 TO ro_user;
GRANT SELECT ON TABLE public.sinactive_prs_by_sigd90 TO devstats_team;


--
-- Name: TABLE sinactive_prs_by_sigw2; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sinactive_prs_by_sigw2 TO ro_user;
GRANT SELECT ON TABLE public.sinactive_prs_by_sigw2 TO devstats_team;


--
-- Name: TABLE sissues_age; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sissues_age TO ro_user;
GRANT SELECT ON TABLE public.sissues_age TO devstats_team;


--
-- Name: TABLE sissues_age_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sissues_age_repos TO ro_user;
GRANT SELECT ON TABLE public.sissues_age_repos TO devstats_team;


--
-- Name: TABLE sissues_milestones; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sissues_milestones TO ro_user;
GRANT SELECT ON TABLE public.sissues_milestones TO devstats_team;


--
-- Name: TABLE snew_contributors; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.snew_contributors TO ro_user;
GRANT SELECT ON TABLE public.snew_contributors TO devstats_team;


--
-- Name: TABLE snew_contributors_data; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.snew_contributors_data TO ro_user;
GRANT SELECT ON TABLE public.snew_contributors_data TO devstats_team;


--
-- Name: TABLE snew_contributors_data_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.snew_contributors_data_repos TO ro_user;
GRANT SELECT ON TABLE public.snew_contributors_data_repos TO devstats_team;


--
-- Name: TABLE snew_contributors_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.snew_contributors_repos TO ro_user;
GRANT SELECT ON TABLE public.snew_contributors_repos TO devstats_team;


--
-- Name: TABLE snew_issues; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.snew_issues TO ro_user;
GRANT SELECT ON TABLE public.snew_issues TO devstats_team;


--
-- Name: TABLE snew_issues_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.snew_issues_repos TO ro_user;
GRANT SELECT ON TABLE public.snew_issues_repos TO devstats_team;


--
-- Name: TABLE snum_stats; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.snum_stats TO ro_user;
GRANT SELECT ON TABLE public.snum_stats TO devstats_team;


--
-- Name: TABLE snum_stats_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.snum_stats_repos TO ro_user;
GRANT SELECT ON TABLE public.snum_stats_repos TO devstats_team;


--
-- Name: TABLE spr_apprappr; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_apprappr TO ro_user;
GRANT SELECT ON TABLE public.spr_apprappr TO devstats_team;


--
-- Name: TABLE spr_apprwait; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_apprwait TO ro_user;
GRANT SELECT ON TABLE public.spr_apprwait TO devstats_team;


--
-- Name: TABLE spr_auth; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_auth TO ro_user;
GRANT SELECT ON TABLE public.spr_auth TO devstats_team;


--
-- Name: TABLE spr_auth_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_auth_repos TO ro_user;
GRANT SELECT ON TABLE public.spr_auth_repos TO devstats_team;


--
-- Name: TABLE spr_comms_med; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_comms_med TO ro_user;
GRANT SELECT ON TABLE public.spr_comms_med TO devstats_team;


--
-- Name: TABLE spr_comms_p85; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_comms_p85 TO ro_user;
GRANT SELECT ON TABLE public.spr_comms_p85 TO devstats_team;


--
-- Name: TABLE spr_comms_p95; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_comms_p95 TO ro_user;
GRANT SELECT ON TABLE public.spr_comms_p95 TO devstats_team;


--
-- Name: TABLE spr_repapprappr; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_repapprappr TO ro_user;
GRANT SELECT ON TABLE public.spr_repapprappr TO devstats_team;


--
-- Name: TABLE spr_repapprwait; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_repapprwait TO ro_user;
GRANT SELECT ON TABLE public.spr_repapprwait TO devstats_team;


--
-- Name: TABLE spr_workload_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spr_workload_repos TO ro_user;
GRANT SELECT ON TABLE public.spr_workload_repos TO devstats_team;


--
-- Name: TABLE sprblckall; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprblckall TO ro_user;
GRANT SELECT ON TABLE public.sprblckall TO devstats_team;


--
-- Name: TABLE sprblckdo_not_merge; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprblckdo_not_merge TO ro_user;
GRANT SELECT ON TABLE public.sprblckdo_not_merge TO devstats_team;


--
-- Name: TABLE sprblckneeds_ok_to_test; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprblckneeds_ok_to_test TO ro_user;
GRANT SELECT ON TABLE public.sprblckneeds_ok_to_test TO devstats_team;


--
-- Name: TABLE sprblckno_approve; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprblckno_approve TO ro_user;
GRANT SELECT ON TABLE public.sprblckno_approve TO devstats_team;


--
-- Name: TABLE sprblckno_lgtm; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprblckno_lgtm TO ro_user;
GRANT SELECT ON TABLE public.sprblckno_lgtm TO devstats_team;


--
-- Name: TABLE sprblckrelease_note_label_needed; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprblckrelease_note_label_needed TO ro_user;
GRANT SELECT ON TABLE public.sprblckrelease_note_label_needed TO devstats_team;


--
-- Name: TABLE spreprblckall; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spreprblckall TO ro_user;
GRANT SELECT ON TABLE public.spreprblckall TO devstats_team;


--
-- Name: TABLE spreprblckdo_not_merge; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spreprblckdo_not_merge TO ro_user;
GRANT SELECT ON TABLE public.spreprblckdo_not_merge TO devstats_team;


--
-- Name: TABLE spreprblckneeds_ok_to_test; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spreprblckneeds_ok_to_test TO ro_user;
GRANT SELECT ON TABLE public.spreprblckneeds_ok_to_test TO devstats_team;


--
-- Name: TABLE spreprblckno_approve; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spreprblckno_approve TO ro_user;
GRANT SELECT ON TABLE public.spreprblckno_approve TO devstats_team;


--
-- Name: TABLE spreprblckno_lgtm; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spreprblckno_lgtm TO ro_user;
GRANT SELECT ON TABLE public.spreprblckno_lgtm TO devstats_team;


--
-- Name: TABLE spreprblckrelease_note_label_needed; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spreprblckrelease_note_label_needed TO ro_user;
GRANT SELECT ON TABLE public.spreprblckrelease_note_label_needed TO devstats_team;


--
-- Name: TABLE sprs_age; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprs_age TO ro_user;
GRANT SELECT ON TABLE public.sprs_age TO devstats_team;


--
-- Name: TABLE sprs_age_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprs_age_repos TO ro_user;
GRANT SELECT ON TABLE public.sprs_age_repos TO devstats_team;


--
-- Name: TABLE sprs_labels; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprs_labels TO ro_user;
GRANT SELECT ON TABLE public.sprs_labels TO devstats_team;


--
-- Name: TABLE sprs_labels_by_sig; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprs_labels_by_sig TO ro_user;
GRANT SELECT ON TABLE public.sprs_labels_by_sig TO devstats_team;


--
-- Name: TABLE sprs_labels_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprs_labels_repos TO ro_user;
GRANT SELECT ON TABLE public.sprs_labels_repos TO devstats_team;


--
-- Name: TABLE sprs_milestones; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.sprs_milestones TO ro_user;
GRANT SELECT ON TABLE public.sprs_milestones TO devstats_team;


--
-- Name: TABLE spstat; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spstat TO ro_user;
GRANT SELECT ON TABLE public.spstat TO devstats_team;


--
-- Name: TABLE spstat_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.spstat_repos TO ro_user;
GRANT SELECT ON TABLE public.spstat_repos TO devstats_team;


--
-- Name: TABLE ssig_pr_wlabs; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssig_pr_wlabs TO ro_user;
GRANT SELECT ON TABLE public.ssig_pr_wlabs TO devstats_team;


--
-- Name: TABLE ssig_pr_wliss; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssig_pr_wliss TO ro_user;
GRANT SELECT ON TABLE public.ssig_pr_wliss TO devstats_team;


--
-- Name: TABLE ssig_pr_wlrel; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssig_pr_wlrel TO ro_user;
GRANT SELECT ON TABLE public.ssig_pr_wlrel TO devstats_team;


--
-- Name: TABLE ssig_pr_wlrev; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssig_pr_wlrev TO ro_user;
GRANT SELECT ON TABLE public.ssig_pr_wlrev TO devstats_team;


--
-- Name: TABLE ssig_prs_open; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssig_prs_open TO ro_user;
GRANT SELECT ON TABLE public.ssig_prs_open TO devstats_team;


--
-- Name: TABLE ssig_prs_open_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssig_prs_open_repos TO ro_user;
GRANT SELECT ON TABLE public.ssig_prs_open_repos TO devstats_team;


--
-- Name: TABLE ssigm_lsk; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssigm_lsk TO ro_user;
GRANT SELECT ON TABLE public.ssigm_lsk TO devstats_team;


--
-- Name: TABLE ssigm_lskr; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssigm_lskr TO ro_user;
GRANT SELECT ON TABLE public.ssigm_lskr TO devstats_team;


--
-- Name: TABLE ssigm_txt; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ssigm_txt TO ro_user;
GRANT SELECT ON TABLE public.ssigm_txt TO devstats_team;


--
-- Name: TABLE stime_metrics; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.stime_metrics TO ro_user;
GRANT SELECT ON TABLE public.stime_metrics TO devstats_team;


--
-- Name: TABLE stime_metrics_repos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.stime_metrics_repos TO ro_user;
GRANT SELECT ON TABLE public.stime_metrics_repos TO devstats_team;


--
-- Name: TABLE suser_reviews; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.suser_reviews TO ro_user;
GRANT SELECT ON TABLE public.suser_reviews TO devstats_team;


--
-- Name: TABLE swatchers; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.swatchers TO ro_user;
GRANT SELECT ON TABLE public.swatchers TO devstats_team;


--
-- Name: TABLE tall_combined_repo_groups; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tall_combined_repo_groups TO ro_user;
GRANT SELECT ON TABLE public.tall_combined_repo_groups TO devstats_team;


--
-- Name: TABLE tall_milestones; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tall_milestones TO ro_user;
GRANT SELECT ON TABLE public.tall_milestones TO devstats_team;


--
-- Name: TABLE tall_repo_groups; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tall_repo_groups TO ro_user;
GRANT SELECT ON TABLE public.tall_repo_groups TO devstats_team;


--
-- Name: TABLE tall_repo_names; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tall_repo_names TO ro_user;
GRANT SELECT ON TABLE public.tall_repo_names TO devstats_team;


--
-- Name: TABLE tbot_commands; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tbot_commands TO ro_user;
GRANT SELECT ON TABLE public.tbot_commands TO devstats_team;


--
-- Name: TABLE tcompanies; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tcompanies TO ro_user;
GRANT SELECT ON TABLE public.tcompanies TO devstats_team;


--
-- Name: TABLE tcountries; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tcountries TO ro_user;
GRANT SELECT ON TABLE public.tcountries TO devstats_team;


--
-- Name: TABLE tcumperiods; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tcumperiods TO ro_user;
GRANT SELECT ON TABLE public.tcumperiods TO devstats_team;


--
-- Name: TABLE tlanguages; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tlanguages TO ro_user;
GRANT SELECT ON TABLE public.tlanguages TO devstats_team;


--
-- Name: TABLE tlicenses; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tlicenses TO ro_user;
GRANT SELECT ON TABLE public.tlicenses TO devstats_team;


--
-- Name: TABLE tpr_labels_tags; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tpr_labels_tags TO ro_user;
GRANT SELECT ON TABLE public.tpr_labels_tags TO devstats_team;


--
-- Name: TABLE tpriority_labels_with_all; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tpriority_labels_with_all TO ro_user;
GRANT SELECT ON TABLE public.tpriority_labels_with_all TO devstats_team;


--
-- Name: TABLE tquick_ranges; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tquick_ranges TO ro_user;
GRANT SELECT ON TABLE public.tquick_ranges TO devstats_team;


--
-- Name: TABLE trepo_groups; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.trepo_groups TO ro_user;
GRANT SELECT ON TABLE public.trepo_groups TO devstats_team;


--
-- Name: TABLE trepos; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.trepos TO ro_user;
GRANT SELECT ON TABLE public.trepos TO devstats_team;


--
-- Name: TABLE treviewers; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.treviewers TO ro_user;
GRANT SELECT ON TABLE public.treviewers TO devstats_team;


--
-- Name: TABLE tsig_mentions_labels; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tsig_mentions_labels TO ro_user;
GRANT SELECT ON TABLE public.tsig_mentions_labels TO devstats_team;


--
-- Name: TABLE tsig_mentions_labels_with_all; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tsig_mentions_labels_with_all TO ro_user;
GRANT SELECT ON TABLE public.tsig_mentions_labels_with_all TO devstats_team;


--
-- Name: TABLE tsig_mentions_texts; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tsig_mentions_texts TO ro_user;
GRANT SELECT ON TABLE public.tsig_mentions_texts TO devstats_team;


--
-- Name: TABLE tsigm_lbl_kinds; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tsigm_lbl_kinds TO ro_user;
GRANT SELECT ON TABLE public.tsigm_lbl_kinds TO devstats_team;


--
-- Name: TABLE tsigm_lbl_kinds_with_all; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tsigm_lbl_kinds_with_all TO ro_user;
GRANT SELECT ON TABLE public.tsigm_lbl_kinds_with_all TO devstats_team;


--
-- Name: TABLE tsize_labels_with_all; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tsize_labels_with_all TO ro_user;
GRANT SELECT ON TABLE public.tsize_labels_with_all TO devstats_team;


--
-- Name: TABLE ttop_repo_names; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ttop_repo_names TO ro_user;
GRANT SELECT ON TABLE public.ttop_repo_names TO devstats_team;


--
-- Name: TABLE ttop_repo_names_with_all; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ttop_repo_names_with_all TO ro_user;
GRANT SELECT ON TABLE public.ttop_repo_names_with_all TO devstats_team;


--
-- Name: TABLE ttop_repos_with_all; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.ttop_repos_with_all TO ro_user;
GRANT SELECT ON TABLE public.ttop_repos_with_all TO devstats_team;


--
-- Name: TABLE tusers; Type: ACL; Schema: public; Owner: gha_admin
--

GRANT SELECT ON TABLE public.tusers TO ro_user;
GRANT SELECT ON TABLE public.tusers TO devstats_team;


--
-- PostgreSQL database dump complete
--

\unrestrict ZnlXPOdS1Vx4NOHeikZTI8ehcWLPe9I8cgm27Br8jAHpBSCZdwCd2nR0tYy9Ocz


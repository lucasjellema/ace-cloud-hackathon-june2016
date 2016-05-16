--------------------------------------------------------
--  File created - maandag-mei-16-2016   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Type PLANNING_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "PLANNING_T" force as object (
  id number(10)  
 , rom_id number(10)
, slt_id number(10)
, room_display_label varchar2(100)
, room_capacity number(4,0)
, room_location_description varchar2(2000)
, slot_display_label varchar2(100)
, slot_start_time timestamp
, ssn_id number(10)
, session_title varchar2(500)
, speakers varchar2(500)
, session_duration  number(2,1)
, track varchar2(100)
, constructor function planning_t 
(  rom_id in number
, slt_id in number
, room_display_label in varchar2
, room_capacity in number
, room_location_description in varchar2
, slot_display_label in varchar2
, slot_start_time in timestamp
, ssn_id in number
, session_title in varchar2
, speakers in varchar2
, session_duration in number
, track varchar2
) return self as result
, constructor function planning_t
              ( id in number
              , title in varchar2
              , speakers  in varchar2
              , slt_id in number
, session_duration in number
, track in  varchar2
, ssn_id in  number
              ) return self as result
, map member function map_planning_t
  return number
, member function to_json
  return varchar2
);

CREATE OR REPLACE EDITIONABLE TYPE BODY "PLANNING_T" as

map member
function map_planning_t
return number
is
begin  
  return 1;
end map_planning_t;  

constructor function planning_t
              ( id in number
              , title in varchar2
              , speakers  in varchar2
              , slt_id in number
, session_duration in number
, track in  varchar2
, ssn_id in  number
              ) return self as result
is
begin
  self.id:= id;
  self.session_title := title;
  self.speakers:= speakers;
  self.slt_id:= slt_id;
  self.session_duration:= session_duration;
  self.track:=track;
  self.ssn_id:= ssn_id;
  return;
end;

constructor function planning_t 
(  rom_id in number
, slt_id in number
, room_display_label in varchar2
, room_capacity in number
, room_location_description in varchar2
, slot_display_label in varchar2
, slot_start_time in timestamp
, ssn_id in number
, session_title in varchar2
, speakers in varchar2
, session_duration in number
, track in  varchar2
) return self as result
is
begin
  self.rom_id:= rom_id;
  self.slt_id:= slt_id;
  self.ssn_id:= ssn_id;
  self.slot_display_label := slot_display_label; 
  self.room_location_description := room_location_description; 
  self.slot_start_time :=slot_start_time ; 
  self.room_display_label := room_display_label; 
  self.room_capacity :=room_capacity ; 
  self.session_title := session_title;
  self.speakers:= speakers;
  self.session_duration:= session_duration;
  self.track:=track;
  return;
end;


member function to_json
return varchar2
is
  l_json    varchar2(32600);
begin
  l_json:= '{'
            ||'"romId" : "'||self.rom_id||'" '
            ||', "sltId" : "'||self.slt_id||'" '
            ||', "room" : "'||self.room_display_label||'" '
            ||', "roomCapacity" : "'||self.room_capacity||'" '
            ||', "roomLocation" : "'||self.room_location_description||'" '
            ||', "slot" : "'||self.slot_display_label||'" '
            ||', "slotDate" : "'||to_char(self.slot_start_time,'DD-MM-YYYY')||'" '
            ||', "slotStartTime" : "'||to_char(self.slot_start_time,'HH24:MI')||'" '
            ||', "sessionStartTime" : "'||to_char(self.slot_start_time,'HH24:MI')||'" '
            ||', "sessionEndTime" : "'||to_char(self.slot_start_time +nvl(self.session_duration,1)*50/60/24 ,'HH24:MI')||'" '
            ||', "sessionDuration" : "'||self.session_duration||'" '
            ||', "sessionId" : "'||self.ssn_id||'" '
            ||', "title" : "'||self.session_title||'" '
            ||', "speakers" : "'||self.speakers||'" '
            ||'}';
  return l_json;         
end to_json;
end;
--------------------------------------------------------
--  DDL for Type PLANNING_TBL_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "PLANNING_TBL_T" as table of planning_t;
--------------------------------------------------------
--  DDL for Type SESSION_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SESSION_T" force as object (
 id number(10) 
, title varchar2(1000) 
, abstract clob
, target_audience varchar2(500)
, experience_level varchar2(500)
, granularity varchar2(500)
, duration number(2,1) -- 2, 1, 0.5 for MC, regular and quickie
, tags tag_tbl_t
, speakers speaker_tbl_t
, planning planning_t
, session_identifier varchar2(50)  -- identifier used in mobile app and web site submission page
, track varchar2(250) 
, constructor function session_t
              ( title in varchar2
              , speaker  in varchar2
              , track   in varchar2
              ) return self as result
, member function to_json
  return varchar2		  
, member function to_json_summary
  return varchar2		  
) NOT FINAL
;

CREATE OR REPLACE EDITIONABLE TYPE BODY "SESSION_T" as

constructor function session_t
              ( title in varchar2
              , speaker  in varchar2
              , track   in varchar2
              ) return self as result
is
begin
  self.title:= title;
  self.speakers:= speaker_tbl_t();
  self.track:= track;
  return;
end;

member function to_json
return varchar2
is
  l_json    varchar2(32600);
begin
  l_json:= '{'
            ||'"sessionId" : "'||self.id||'" '
            ||', "title" : "'||self.title||'" '
            ||', "targetAudience" : "'||self.target_audience||'" '
            ||', "duration" : "'||self.duration||'" '
            ||', "experienceLevel" : "'||self.experience_level||'" '
            ||', "granularity" : "'||self.granularity||'" '
            ||', "abstract" : "'||self.abstract||'" '
            ||', "speakers" : '||bth_speakers_api.json_speaker_tbl_summary(p_speakers => self.speakers)||' '
            ||', "tags" : '||bth_tags_api.json_tag_tbl_summary(p_tags => self.tags)||' '
            ||', "planning" : '||case when self.planning is not null then self.planning.to_json else '{}' end||' '
            ||', "sessionAppIdentifier" : "'||nvl(self.session_identifier, self.id)||'" '
            ||', "track" : "'||self.track||'" '
            ||', "themes" : "-" '
            ||'}';
  return l_json;         
end to_json;

 member function to_json_summary
  return varchar2		  
is
  l_json    varchar2(32600);
begin
  l_json:= '{'
            ||'"sessionId" : "'||self.id||'" '
            ||', "title" : "'||self.title||'" '
            ||', "speakers" : '||bth_speakers_api.json_speaker_tbl_summary(p_speakers => self.speakers)||' '
            ||', "tags" : '||bth_tags_api.json_tag_tbl_summary(p_tags => self.tags)||' '
            ||', "track" : "'||self.track||'" '
            ||'}';
  return l_json;         
end to_json_summary;


end;
--------------------------------------------------------
--  DDL for Type SESSION_TBL_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SESSION_TBL_T" as table of session_t;
--------------------------------------------------------
--  DDL for Type SPEAKER_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SPEAKER_T" force as object (
id number(10)
, first_name  varchar2(500)
, last_name  varchar2(500)
, company  varchar2(500)
, country  varchar2(50)
, biography clob
, salutation varchar2(100)
, community_titles varchar2(500)
, constructor function speaker_t
              ( id in number
              , first_name  in varchar2
              , last_name  in varchar2
              ) return self as result
, member function to_json
  return varchar2		  
, member function to_json_summary
  return varchar2		  
) NOT FINAL
;

CREATE OR REPLACE EDITIONABLE TYPE BODY "SPEAKER_T" as

constructor function speaker_t
              ( id in number
              , first_name  in varchar2
              , last_name  in varchar2
              ) return self as result
is
begin
  self.id:= id;
  self.first_name:= first_name;
  self.last_name:= last_name;
  return;
end;

member function to_json
return varchar2
is
  l_json    varchar2(32600);
  l_sessions  session_tbl_t := session_tbl_t();
begin
  bth_sessions_api.get_sessions
  ( p_tags => null
  , p_search_term => null
  , p_speakers  =>  '[ {"id":'||self.id||'  , "lastName": "'||self.last_name||'"} ]' 
  , p_sessions => l_sessions
  );
  l_json:= '{'
            ||'"id" : "'||self.id||'" '
            ||', "firstName" : "'||self.first_name||'" '
            ||', "lastName" : "'||self.last_name||'" '
            ||', "country" : "'||self.country||'" '
            ||', "company" : "'||self.company||'" '
            ||', "communityTitles" : "'||self.community_titles||'" '
            ||', "biography" : "'||self.biography||'" '
            ||', "sessions" : '||bth_sessions_api.json_session_tbl_summary(p_sessions => l_sessions)||' '
            ||'}';
  return l_json;         
end to_json;

member function to_json_summary
return varchar2		  
is
  l_json    varchar2(32600);
begin
  l_json:= '{'
            ||'"id" : "'||self.id||'" '
            ||', "firstName" : "'||self.first_name||'" '
            ||', "lastName" : "'||self.last_name||'" '
            ||', "country" : "'||self.country||'" '
            ||', "company" : "'||self.company||'" '
            ||'}';
  return l_json;         
end to_json_summary;

end;
--------------------------------------------------------
--  DDL for Type SPEAKER_TBL_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SPEAKER_TBL_T" as table of speaker_t;
--------------------------------------------------------
--  DDL for Type STRING_TBL_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "STRING_TBL_T" as table of varchar2(2000);
--------------------------------------------------------
--  DDL for Type SYSTPMtufDu0GamLgU/40xAqf6w==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMtufDu0GamLgU/40xAqf6w==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMtufDu0GamLgU/40xAqf6w==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMtufTPDmatDgU/40xAqYEA==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMtufTPDmatDgU/40xAqYEA==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMtufTPDmatDgU/40xAqYEA==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMtuilBcWb57gU/40xAqAHA==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMtuilBcWb57gU/40xAqAHA==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMtuilBcWb57gU/40xAqAHA==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCD1/+1JXrgU/40xApWbw==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCD1/+1JXrgU/40xApWbw==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCD1/+1JXrgU/40xApWbw==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCD1/+6JXrgU/40xApWbw==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCD1/+6JXrgU/40xApWbw==" AS TABLE OF "SPEAKER_T"
  GRANT EXECUTE ON "SYSTPMvCD1/+6JXrgU/40xApWbw==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCG0js9JgHgU/40xArr7Q==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCG0js9JgHgU/40xArr7Q==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCG0js9JgHgU/40xArr7Q==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCIEEW7JjvgU/40xAqNuA==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCIEEW7JjvgU/40xAqNuA==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCIEEW7JjvgU/40xAqNuA==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCInAyVJlfgU/40xAr9vA==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCInAyVJlfgU/40xAr9vA==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCInAyVJlfgU/40xAr9vA==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCJ7+esJpDgU/40xArTtA==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCJ7+esJpDgU/40xArTtA==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCJ7+esJpDgU/40xArTtA==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCKZvueJqfgU/40xArRrA==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCKZvueJqfgU/40xArRrA==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCKZvueJqfgU/40xArRrA==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCLmYLMJtzgU/40xAp3NA==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCLmYLMJtzgU/40xAp3NA==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCLmYLMJtzgU/40xAp3NA==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCM4ik4Jw7gU/40xAq/rw==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCM4ik4Jw7gU/40xAq/rw==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCM4ik4Jw7gU/40xAq/rw==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCNYenOJyjgU/40xArSiA==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCNYenOJyjgU/40xArSiA==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCNYenOJyjgU/40xArSiA==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCPK8GYJ37gU/40xAo+jQ==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCPK8GYJ37gU/40xAo+jQ==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCPK8GYJ37gU/40xAo+jQ==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCVRyW+KRrgU/40xAoyGw==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCVRyW+KRrgU/40xAoyGw==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCVRyW+KRrgU/40xAoyGw==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCVvAelKUPgU/40xAr9jw==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCVvAelKUPgU/40xAr9jw==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCVvAelKUPgU/40xAr9jw==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCW7S0oKXbgU/40xAr6CQ==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCW7S0oKXbgU/40xAr6CQ==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCW7S0oKXbgU/40xAr6CQ==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type SYSTPMvCYtttvKcHgU/40xArhqQ==
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "SYSTPMvCYtttvKcHgU/40xArhqQ==" AS TABLE OF "TAG_T"
  GRANT EXECUTE ON "SYSTPMvCYtttvKcHgU/40xArhqQ==" TO PUBLIC
--------------------------------------------------------
--  DDL for Type TAG_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "TAG_T" force as object (
  id number(10) 
, display_label varchar2(100)
, tcy_id number(10)
, category varchar2(100)
, tag_count number(5,0)
, icon_url varchar2(1000)
, icon  blob
, member function to_json
  return varchar2		  
, member function to_json_summary
  return varchar2		  
) NOT FINAL;
CREATE OR REPLACE EDITIONABLE TYPE BODY "TAG_T" as

member function to_json
return varchar2
is
  l_json    varchar2(32600);
begin
  l_json:= '{'
            ||'"id" : "'||self.id||'" '
            ||', "displayLabel" : "'||self.display_label||'" '
            ||', "category" : "'||self.category||'" '
            ||', "count" : "'||self.tag_count||'" '
            ||', "iconUrl" : "'||self.icon_url||'" '
            ||'}';
  return l_json;         
end to_json;

member function to_json_summary
return varchar2
is
  l_json    varchar2(32600);
begin
  l_json:= '"'||self.display_label||'"';
  return l_json;         
end to_json_summary;


end;
--------------------------------------------------------
--  DDL for Type TAG_TBL_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "TAG_TBL_T" as table of tag_t;
--------------------------------------------------------
--  DDL for Sequence BTH_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "BTH_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 3521 CACHE 20 NOORDER  NOCYCLE  NOPARTITION
--------------------------------------------------------
--  DDL for Table BTH_DOCUMENTS
--------------------------------------------------------

  CREATE TABLE "BTH_DOCUMENTS" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "NAME" VARCHAR2(500 BYTE), "CONTENT_TYPE" VARCHAR2(100 BYTE), "CONTENT_DATA" BLOB, "DESCRIPTION" VARCHAR2(500 BYTE), "MASTER_ID" NUMBER(10,0), "PURPOSE" VARCHAR2(10 BYTE))
--------------------------------------------------------
--  DDL for Table BTH_PEOPLE
--------------------------------------------------------

  CREATE TABLE "BTH_PEOPLE" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "FIRST_NAME" VARCHAR2(500 BYTE), "LAST_NAME" VARCHAR2(500 BYTE), "COMPANY" VARCHAR2(500 BYTE), "COUNTRY" VARCHAR2(100 BYTE), "EMAIL_ADDRESS" VARCHAR2(200 BYTE), "MOBILE_PHONE_NUMBER" VARCHAR2(50 BYTE), "BIRTHDATE" DATE, "TWITTER_HANDLE" VARCHAR2(500 BYTE), "LINKEDIN_PROFILE" VARCHAR2(500 BYTE), "FACEBOOK_ACCOUNT" VARCHAR2(500 BYTE), "PICTURE" BLOB, "BIOGRAPHY" CLOB, "SALUTATION" VARCHAR2(100 BYTE), "COMMUNITY_TITLES" VARCHAR2(500 BYTE), "JOB_TITLE" VARCHAR2(500 BYTE), "NOTES" VARCHAR2(2000 BYTE), "PICTURE_DOC_ID" NUMBER(10,0))
--------------------------------------------------------
--  DDL for Table BTH_PLANNING_ITEMS
--------------------------------------------------------

  CREATE TABLE "BTH_PLANNING_ITEMS" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "ROM_ID" NUMBER(10,0), "SLT_ID" NUMBER(10,0), "SSN_ID" NUMBER(10,0))
--------------------------------------------------------
--  DDL for Table BTH_ROOMS
--------------------------------------------------------

  CREATE TABLE "BTH_ROOMS" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "DISPLAY_LABEL" VARCHAR2(100 BYTE), "CAPACITY" NUMBER(4,0), "LOCATION_DESCRIPTION" VARCHAR2(2000 BYTE))
--------------------------------------------------------
--  DDL for Table BTH_SESSIONS
--------------------------------------------------------

  CREATE TABLE "BTH_SESSIONS" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "TITLE" VARCHAR2(1000 BYTE), "ABSTRACT" CLOB, "TARGET_AUDIENCE" VARCHAR2(500 BYTE), "EXPERIENCE_LEVEL" VARCHAR2(500 BYTE), "GRANULARITY" VARCHAR2(500 BYTE), "DURATION" NUMBER(2,1), "SUBMISSION_IDENTIFIER" NUMBER(5,0), "STATUS" VARCHAR2(50 BYTE), "DEMOS" VARCHAR2(2000 BYTE), "NOTES" VARCHAR2(2000 BYTE), "COSPEAKERS" VARCHAR2(2000 BYTE), "TRACK_TAG_ID" NUMBER(10,0))
--------------------------------------------------------
--  DDL for Table BTH_SLOTS
--------------------------------------------------------

  CREATE TABLE "BTH_SLOTS" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "DISPLAY_LABEL" VARCHAR2(100 BYTE), "START_TIME" TIMESTAMP (6), "END_TIME" TIMESTAMP (6), "ROUND_SEQUENCE" NUMBER(2,0))
--------------------------------------------------------
--  DDL for Table BTH_SPEAKERS
--------------------------------------------------------

  CREATE TABLE "BTH_SPEAKERS" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "SSN_ID" NUMBER(10,0), "PSN_ID" NUMBER(10,0), "CONTRIBUTION" VARCHAR2(500 BYTE))
--------------------------------------------------------
--  DDL for Table BTH_TAG_BINDINGS
--------------------------------------------------------

  CREATE TABLE "BTH_TAG_BINDINGS" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "TAG_ID" NUMBER(10,0), "PSN_ID" NUMBER(10,0), "SSN_ID" NUMBER(10,0))
--------------------------------------------------------
--  DDL for Table BTH_TAG_CATEGORIES
--------------------------------------------------------

  CREATE TABLE "BTH_TAG_CATEGORIES" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "DISPLAY_LABEL" VARCHAR2(500 BYTE))
--------------------------------------------------------
--  DDL for Table BTH_TAGS
--------------------------------------------------------

  CREATE TABLE "BTH_TAGS" ("ID" NUMBER(10,0) DEFAULT "BTH_SEQ"."NEXTVAL", "DISPLAY_LABEL" VARCHAR2(100 BYTE), "TCY_ID" NUMBER(10,0), "ICON_URL" VARCHAR2(1000 BYTE), "ICON" BLOB)
--------------------------------------------------------
--  DDL for View PLANNING_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE VIEW "PLANNING_SCHEDULE" ("SLOT", "START_TIME", "ROOM1_PIM", "ROOM2_PIM", "ROOM3_PIM", "ROOM4_PIM", "ROOM5_PIM", "ROOM6_PIM", "ROOM7_PIM", "ROOM8_PIM") AS select sch.slot
,      sch.start_time
, bth_planning_api.get_planning_item( p_pim_id => sch.room1_pim) as room1_pim
, bth_planning_api.get_planning_item( p_pim_id => sch.room2_pim) as room2_pim
, bth_planning_api.get_planning_item( p_pim_id => sch.room3_pim) as room3_pim
, bth_planning_api.get_planning_item( p_pim_id => sch.room4_pim) as room4_pim
, bth_planning_api.get_planning_item( p_pim_id => sch.room5_pim) as room5_pim
, bth_planning_api.get_planning_item( p_pim_id => sch.room6_pim) as room6_pim
, bth_planning_api.get_planning_item( p_pim_id => sch.room7_pim) as room7_pim
, bth_planning_api.get_planning_item( p_pim_id => sch.room8_pim) as room8_pim
from (
select rom.display_label room
,      slt.display_label slot
,      slt.start_time
,      pim.id
from   bth_planning_items pim
       join
       bth_rooms rom
       on (pim.rom_id = rom.id)
       right outer join
       bth_slots slt
       on (pim.slt_id = slt.id)
)
PIVOT (max(id) as pim 
  for (room) in ('Room 1' as Room1, 'Room 2' as Room2,'Room 3' as Room3,'Room 4' as Room4,'Room 5' as Room5,'Room 6' as Room6,'Room 7' as Room7,'Room 8' as Room8)
) sch
order
by     start_time
REM INSERTING into BTH_DOCUMENTS
SET DEFINE OFF;
Insert into BTH_DOCUMENTS (ID,NAME,CONTENT_TYPE,DESCRIPTION,MASTER_ID,PURPOSE) values ('2601','lucas.jpg','image/jpeg','lucas picture','1118','PIC');
Insert into BTH_DOCUMENTS (ID,NAME,CONTENT_TYPE,DESCRIPTION,MASTER_ID,PURPOSE) values ('1','`demoAnimatedCustomBaseMap.png','image/png','lucas picture','18','PIC');
Insert into BTH_DOCUMENTS (ID,NAME,CONTENT_TYPE,DESCRIPTION,MASTER_ID,PURPOSE) values ('2622','3dchess_javafx.png','image/png','lucas picture','20','PIC');
Insert into BTH_DOCUMENTS (ID,NAME,CONTENT_TYPE,DESCRIPTION,MASTER_ID,PURPOSE) values ('2623','ACE Director Logo','image/gif',null,'1','PIC');
--------------------------------------------------------
--  Constraints for Table BTH_DOCUMENTS
--------------------------------------------------------

  ALTER TABLE "BTH_DOCUMENTS" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_DOCUMENTS" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_PEOPLE
--------------------------------------------------------

  ALTER TABLE "BTH_PEOPLE" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_PEOPLE" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_PLANNING_ITEMS
--------------------------------------------------------

  ALTER TABLE "BTH_PLANNING_ITEMS" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_PLANNING_ITEMS" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_ROOMS
--------------------------------------------------------

  ALTER TABLE "BTH_ROOMS" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_ROOMS" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_SESSIONS
--------------------------------------------------------

  ALTER TABLE "BTH_SESSIONS" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_SESSIONS" MODIFY ("TITLE" NOT NULL ENABLE)
  ALTER TABLE "BTH_SESSIONS" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_SLOTS
--------------------------------------------------------

  ALTER TABLE "BTH_SLOTS" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_SLOTS" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_SPEAKERS
--------------------------------------------------------

  ALTER TABLE "BTH_SPEAKERS" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_SPEAKERS" MODIFY ("SSN_ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_SPEAKERS" MODIFY ("PSN_ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_SPEAKERS" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_TAG_BINDINGS
--------------------------------------------------------

  ALTER TABLE "BTH_TAG_BINDINGS" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_TAG_BINDINGS" MODIFY ("TAG_ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_TAG_BINDINGS" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_TAG_CATEGORIES
--------------------------------------------------------

  ALTER TABLE "BTH_TAG_CATEGORIES" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_TAG_CATEGORIES" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Constraints for Table BTH_TAGS
--------------------------------------------------------

  ALTER TABLE "BTH_TAGS" MODIFY ("ID" NOT NULL ENABLE)
  ALTER TABLE "BTH_TAGS" ADD PRIMARY KEY ("ID") USING INDEX  ENABLE
--------------------------------------------------------
--  Ref Constraints for Table BTH_PLANNING_ITEMS
--------------------------------------------------------

  ALTER TABLE "BTH_PLANNING_ITEMS" ADD CONSTRAINT "BTH_PIM_ROM" FOREIGN KEY ("ROM_ID") REFERENCES "BTH_ROOMS" ("ID") ENABLE
  ALTER TABLE "BTH_PLANNING_ITEMS" ADD CONSTRAINT "BTH_PIM_SLT_FK" FOREIGN KEY ("SLT_ID") REFERENCES "BTH_SLOTS" ("ID") ENABLE
  ALTER TABLE "BTH_PLANNING_ITEMS" ADD CONSTRAINT "BTH_PIM_SSN_FK" FOREIGN KEY ("SSN_ID") REFERENCES "BTH_SESSIONS" ("ID") ENABLE
--------------------------------------------------------
--  Ref Constraints for Table BTH_SESSIONS
--------------------------------------------------------

  ALTER TABLE "BTH_SESSIONS" ADD CONSTRAINT "BTH_SSN_TAG_FK" FOREIGN KEY ("TRACK_TAG_ID") REFERENCES "BTH_TAGS" ("ID") ENABLE
--------------------------------------------------------
--  Ref Constraints for Table BTH_SPEAKERS
--------------------------------------------------------

  ALTER TABLE "BTH_SPEAKERS" ADD CONSTRAINT "BTH_SKR_PSN_FK" FOREIGN KEY ("PSN_ID") REFERENCES "BTH_PEOPLE" ("ID") ENABLE
  ALTER TABLE "BTH_SPEAKERS" ADD CONSTRAINT "BTH_SKR_SSN_FK" FOREIGN KEY ("SSN_ID") REFERENCES "BTH_SESSIONS" ("ID") ENABLE
--------------------------------------------------------
--  Ref Constraints for Table BTH_TAG_BINDINGS
--------------------------------------------------------

  ALTER TABLE "BTH_TAG_BINDINGS" ADD CONSTRAINT "BTH_TBG_PSN_FK" FOREIGN KEY ("PSN_ID") REFERENCES "BTH_PEOPLE" ("ID") ENABLE
  ALTER TABLE "BTH_TAG_BINDINGS" ADD CONSTRAINT "BTH_TBG_SSN_FK" FOREIGN KEY ("SSN_ID") REFERENCES "BTH_SESSIONS" ("ID") ENABLE
--------------------------------------------------------
--  Ref Constraints for Table BTH_TAGS
--------------------------------------------------------

  ALTER TABLE "BTH_TAGS" ADD CONSTRAINT "BTH_TAG_TCY_FK" FOREIGN KEY ("TCY_ID") REFERENCES "BTH_TAG_CATEGORIES" ("ID") ENABLE
--------------------------------------------------------
--  DDL for Trigger BTH_PIM_CHANGE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "BTH_PIM_CHANGE_TRG" 
BEFORE INSERT OR DELETE OR UPDATE OF ssn_id, slt_id, rom_id
ON bth_planning_items
begin
  insert into modification_log ( source_of_modification) values ('PIM');
end;
ALTER TRIGGER "BTH_PIM_CHANGE_TRG" ENABLE
--------------------------------------------------------
--  DDL for Trigger BTH_PSN_CHANGE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "BTH_PSN_CHANGE_TRG" 
BEFORE INSERT OR UPDATE OF first_name,last_name, company, community_titles
ON bth_people
begin
  insert into modification_log ( source_of_modification) values ('PSN');
end;
ALTER TRIGGER "BTH_PSN_CHANGE_TRG" ENABLE
--------------------------------------------------------
--  DDL for Trigger BTH_ROM_CHANGE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "BTH_ROM_CHANGE_TRG" 
BEFORE INSERT OR DELETE OR UPDATE OF display_label
ON bth_rooms
begin
  insert into modification_log ( source_of_modification) values ('ROM');
end;
ALTER TRIGGER "BTH_ROM_CHANGE_TRG" ENABLE
--------------------------------------------------------
--  DDL for Trigger BTH_SKR_CHANGE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "BTH_SKR_CHANGE_TRG" 
BEFORE INSERT OR DELETE OR UPDATE OF psn_id, ssn_id
ON bth_speakers
begin
  insert into modification_log ( source_of_modification) values ('SKR');
end;
ALTER TRIGGER "BTH_SKR_CHANGE_TRG" ENABLE
--------------------------------------------------------
--  DDL for Trigger BTH_SLT_CHANGE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "BTH_SLT_CHANGE_TRG" 
BEFORE INSERT OR DELETE OR UPDATE OF display_label, start_time, end_time
ON bth_slots
begin
  insert into modification_log ( source_of_modification) values ('SLT');
end;
ALTER TRIGGER "BTH_SLT_CHANGE_TRG" ENABLE
--------------------------------------------------------
--  DDL for Trigger BTH_SSN_CHANGE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "BTH_SSN_CHANGE_TRG" 
BEFORE INSERT OR UPDATE OF title, status, track_tag_id, duration
ON bth_sessions
begin
  insert into modification_log ( source_of_modification) values ('SSN');
end;
ALTER TRIGGER "BTH_SSN_CHANGE_TRG" ENABLE
--------------------------------------------------------
--  DDL for Trigger BTH_TBG_CHANGE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "BTH_TBG_CHANGE_TRG" 
BEFORE INSERT OR DELETE OR UPDATE OF ssn_id, tag_id
ON bth_tag_bindings
begin
  insert into modification_log ( source_of_modification) values ('TBG');
end;
ALTER TRIGGER "BTH_TBG_CHANGE_TRG" ENABLE

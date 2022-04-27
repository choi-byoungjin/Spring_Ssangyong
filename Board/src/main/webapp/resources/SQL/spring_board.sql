------ ***** spring 기초 ***** ------

show user;
-- USER이(가) "MYMVC_USER"입니다.

create table spring_test
(no         number
,name       varchar2(100)
,writeday   date default sysdate
);

select *
from spring_test;


select no, name, to_char(writeday, 'yyyy-mm-dd hh24:mi:ss') AS writeday  
from spring_test
order by writeday desc;

-----------------------------------------------------------------------

select * from tab;

select * 
from TBL_MAIN_IMAGE;

select imgfilename 
from TBL_MAIN_IMAGE
order by imgno desc;


select * 
from tbl_member;

desc tbl_member;

SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender  
     , birthyyyy, birthmm, birthdd, coin, point, registerday, pwdchangegap  
     , nvl(lastlogingap, trunc( months_between(sysdate, registerday) ) ) AS lastlogingap 
FROM 
 ( 
  select userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender 
        , substr(birthday,1,4) AS birthyyyy, substr(birthday,6,2) AS birthmm, substr(birthday,9) AS birthdd  
        , coin, point, to_char(registerday, 'yyyy-mm-dd') AS registerday 
        , trunc( months_between(sysdate, lastpwdchangedate) ) AS pwdchangegap 
  from tbl_member 
  where status = 1 and userid = 'seoyh' and pwd = '9695b88a59a1610320897fa84cb7e144cc51f2984520efb77111d94b402a8382' 
 ) M 
CROSS JOIN 
(
 select trunc( months_between(sysdate, max(logindate)) ) AS lastlogingap
 from tbl_loginhistory
 where fk_userid = 'seoyh'
) H;


select *
from tbl_loginhistory
order by logindate desc;

select *
from tbl_loginhistory
where fk_userid = 'choibj'
order by logindate desc;

update tbl_loginhistory set logindate = add_months(logindate, 13)
where fk_userid = 'choibj';

commit;

select *
from tbl_member
where userid = 'choibj';

update tbl_member set idle = 0
where userid = 'choibj';

commit

update tbl_member set lastpwdchangedate = add_months(lastpwdchangedate, -4)
where userid = 'choibj';

commit


    ------- **** spring 게시판(답변글쓰기가 없고, 파일첨부도 없는) 글쓰기 **** -------

show user;
-- USER이(가) "MYMVC_USER"입니다.    
    
    
desc tbl_member;

create table tbl_board
(seq         number                not null    -- 글번호
,fk_userid   varchar2(20)          not null    -- 사용자ID
,name        varchar2(20)          not null    -- 글쓴이 
,subject     Nvarchar2(200)        not null    -- 글제목
,content     Nvarchar2(2000)       not null    -- 글내용   -- clob (최대 4GB까지 허용) 
,pw          varchar2(20)          not null    -- 글암호
,readCount   number default 0      not null    -- 글조회수
,regDate     date default sysdate  not null    -- 글쓴시간
,status      number(1) default 1   not null    -- 글삭제여부   1:사용가능한 글,  0:삭제된글
,constraint PK_tbl_board_seq primary key(seq)
,constraint FK_tbl_board_fk_userid foreign key(fk_userid) references tbl_member(userid)
,constraint CK_tbl_board_status check( status in(0,1) )
);

create sequence boardSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from tbl_board
order by seq desc;


select seq, fk_userid, name, subject  
     , readcount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
from tbl_board
where status = 1
order by seq desc;

commit


select seq, fk_userid, name, subject, content, readCount 
     , to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
from tbl_board
where status = 1 and seq = 1;


select seq, fk_userid, name, subject, content, readCount 
     , to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
from tbl_board
where status = 1 and seq = '1';


select seq, fk_userid, name, subject, content, readCount 
     , to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
from tbl_board
where status = 1 and seq = 2;


select previousseq, previoussubject
     , seq, fk_userid, name, subject, content, readCount, regDate
     , nextseq, nextsubject
from
(
select lag(seq,1) over(order by seq desc) AS previousseq
     , lag(subject,1) over(order by seq desc) AS previoussubject       
     , seq, fk_userid, name, subject, content, readCount 
     , to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate     
     , lead(seq,1) over(order by seq desc) AS nextseq
     , lead(subject,1) over(order by seq desc)  AS nextsubject
from tbl_board
where status = 1
) V
where V.seq = '2'



update tbl_board set subject = '호호호'
                    ,content = '헤헤헤헤헤'
where seq = 2 and pw = 'dfsafsd'  
-- 0개 행 이(가) 업데이트되었습니다.

--------------------------------------------------------------------

   ----- **** 댓글 게시판 **** -----

/* 
  댓글쓰기(tbl_comment 테이블)를 성공하면 원게시물(tbl_board 테이블)에
  댓글의 갯수(1씩 증가)를 알려주는 컬럼 commentCount 을 추가하겠다. 
*/
drop table tbl_board purge;

create table tbl_board
(seq           number                not null    -- 글번호
,fk_userid     varchar2(20)          not null    -- 사용자ID
,name          varchar2(20)          not null    -- 글쓴이 
,subject       Nvarchar2(200)        not null    -- 글제목
,content       Nvarchar2(2000)       not null    -- 글내용   -- clob (최대 4GB까지 허용) 
,pw            varchar2(20)          not null    -- 글암호
,readCount     number default 0      not null    -- 글조회수
,regDate       date default sysdate  not null    -- 글쓴시간
,status        number(1) default 1   not null    -- 글삭제여부   1:사용가능한 글,  0:삭제된글
,commentCount  number default 0      not null    -- 댓글의 개수
,constraint PK_tbl_board_seq primary key(seq)
,constraint FK_tbl_board_fk_userid foreign key(fk_userid) references tbl_member(userid)
,constraint CK_tbl_board_status check( status in(0,1) )
);

drop sequence boardSeq;

create sequence boardSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;


----- **** 댓글 테이블 생성 **** -----
create table tbl_comment
(seq           number               not null   -- 댓글번호
,fk_userid     varchar2(20)         not null   -- 사용자ID
,name          varchar2(20)         not null   -- 성명
,content       varchar2(1000)       not null   -- 댓글내용
,regDate       date default sysdate not null   -- 작성일자
,parentSeq     number               not null   -- 원게시물 글번호
,status        number(1) default 1  not null   -- 글삭제여부
                                               -- 1 : 사용가능한 글,  0 : 삭제된 글
                                               -- 댓글은 원글이 삭제되면 자동적으로 삭제되어야 한다.
,constraint PK_tbl_comment_seq primary key(seq)
,constraint FK_tbl_comment_userid foreign key(fk_userid) references tbl_member(userid)
,constraint FK_tbl_comment_parentSeq foreign key(parentSeq) references tbl_board(seq) on delete cascade
,constraint CK_tbl_comment_status check( status in(1,0) ) 
);

create sequence commentSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from tbl_comment
order by seq desc;

select *
from tbl_board
order by seq desc;

select *
from tbl_member;

commit


-- ==== Transaction 처리를 위한 시나리오 만들기 ==== --
---- 회원들이 게시판에 글쓰기를 하면 글작성 1건당 POINT 를 100점을 준다.
---- 회원들이 게시판에서 댓글쓰기를 하면 댓글작성 1건당 POINT 를 50점을 준다.
---- 그런데 일부러 POINT 는 300을 초과할 수 없다.

select *
from tbl_member;

update tbl_member set point = 0;

commit;


-- tbl_member 테이블에 POINT 컬럼에 Check 제약을 추가한다.

alter table tbl_member
add constraint CK_tbl_member_point check( point between 0 and 300 );
-- Table TBL_MEMBER이(가) 변경되었습니다.

update tbl_member set point = 301
where userid = 'choibj';
/*
오류 보고 -
ORA-02290: check constraint (MYMVC_USER.CK_TBL_MEMBER_POINT) violated
*/

update tbl_member set point = 300
where userid = 'choibj';

commit;

-----------------------------------------------------------------
select *
from tbl_comment

select *
from tbl_board;

select userid, point
from tbl_member
where userid = 'eomjh';

select userid, point
from tbl_member
where userid = 'choibj';


--- *** transaction 처리를 위해서 일부러 만들어 두었던 포인트 체크제약을 없애겠다. *** ---
--- *** tbl_member 테이블에 존재하는 제약조건 조회하기 *** ---
select *
from user_constraints
where table_name = 'TBL_MEMBER';

alter table tbl_member
drop constraint CK_TBL_MEMBER_POINT;
-- Table TBL_MEMBER이(가) 변경되었습니다.


select name, content, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') AS regDate 
from tbl_comment
where status = 1 and parentSeq = 2
order by seq desc;

select *
from tbl_board
where subject like '%'||'korea'||'%';

select *
from tbl_board
where lower(subject) like '%'||lower('koReA')||'%';

----------------------------------------------------------------------------------

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'choibj', '최병진', '즐거운 하루 되세요~~', '오늘도 늘 행복하게~~', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'emojh', '엄정화', '오늘도 즐거운 수업을 합시다', '기분이 좋은 하루 되세요^^', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'choibj', '최병진', '기분좋은 날 안녕하신가요?', '모두 반갑습니다', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'choibj', '최병진', '모두들 즐거이 퇴근하세요 안녕~~', '건강이 최고 입니다.', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'eomjh', '엄정화', 'java가 재미 있나요?', '궁금합니다. java가 뭔지요?', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'leess', '이순신', '프로그램은 JAVA 가 쉬운가요?', 'java에 대해 궁금합니다', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'choibj', '최병진', 'JSP 가 뭔가요?', '웹페이지를 작성하려고 합니다.', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'eomjh', '엄정화', 'Korea VS Japan 라이벌 축구대결', '많은 시청 바랍니다.', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'leess', '이순신', '날씨가 많이 쌀쌀합니다.', '건강에 유의하세요~~', '1234', default, default, default);

commit;

select *
from tbl_board
order by seq desc;

select distinct name
from tbl_board
where status = 1
and lower(name) like '%'||lower('정')||'%'
order by name desc    	


select subject
from tbl_board
where status = 1
and lower(subject) like '%'||lower('JA')||'%'
order by seq desc


select count(*)
from tbl_board
where status = 1
and lower(subject) like '%'||'j'||'%'


select count(*)
from tbl_board
where status = 1
and lower(subject) like '%'||lower('')||'%'
order by seq desc;


select seq, fk_userid, name, subject, readCount, regDate, commentCount
from
(
select row_number() over(order by seq desc) AS rno,
        seq, fk_userid, name, subject, readCount, 
        to_char(regDate,'yyyy-mm-dd hh24:mi:ss') as regDate, 
        commentCount
from tbl_board
where status = 1
and lower(subject) like '%'||lower('J')||'%'
) V
where rno between 1 and 3


select previousseq, previoussubject
     , seq, fk_userid, name, subject, content, readCount, regDate, pw
     , nextseq, nextsubject
from
(
    select lag(seq,1) over(order by seq desc) AS previousseq
         , lag(subject,1) over(order by seq desc) AS previoussubject       
         , seq, fk_userid, name, subject, content, readCount 
         , to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate     
         , pw
         , lead(seq,1) over(order by seq desc) AS nextseq
         , lead(subject,1) over(order by seq desc)  AS nextsubject
    from tbl_board
    where status = 1
    and lower(subject) like '%'|| lower('Ja') ||'%'
) V
where V.seq = 11


-------------------------------------------------------------------------------------------------------

-- *** tbl_member 테이블에 gradelevel 이라는 컬럼을 추가하겠다. *** --
alter table tbl_member
add gradelevel number default 1;

-- *** 직원(관리자)들에게는 gradelevel 컬럼의 값을 10 으로 부여하겠다. gradelevel 컬럼의 값이 10 인 직원들만 답변글쓰기가 가능하다 *** --
update tbl_member set gradelevel = 10
where userid in('admin','choibj');

commit;

select *
from tbl_member;



------------- >>>>>>>> 일정관리(풀캘린더) 시작 <<<<<<<< -------------

-- *** 캘린더 대분류(내캘린더, 사내캘린더  분류) ***
create table tbl_calendar_large_category 
(lgcatgono   number(3) not null      -- 캘린더 대분류 번호
,lgcatgoname varchar2(50) not null   -- 캘린더 대분류 명
,constraint PK_tbl_calendar_large_category primary key(lgcatgono)
);
-- Table TBL_CALENDAR_LARGE_CATEGORY이(가) 생성되었습니다.

insert into tbl_calendar_large_category(lgcatgono, lgcatgoname)
values(1, '내캘린더');

insert into tbl_calendar_large_category(lgcatgono, lgcatgoname)
values(2, '사내캘린더');

commit;
-- 커밋 완료.

select * 
from tbl_calendar_large_category;


-- *** 캘린더 소분류 *** 
-- (예: 내캘린더중 점심약속, 내캘린더중 저녁약속, 내캘린더중 운동, 내캘린더중 휴가, 내캘린더중 여행, 내캘린더중 출장 등등) 
-- (예: 사내캘린더중 플젝주제선정, 사내캘린더중 플젝요구사항, 사내캘린더중 DB모델링, 사내캘린더중 플젝코딩, 사내캘린더중 PPT작성, 사내캘린더중 플젝발표 등등) 
create table tbl_calendar_small_category 
(smcatgono    number(8) not null      -- 캘린더 소분류 번호
,fk_lgcatgono number(3) not null      -- 캘린더 대분류 번호
,smcatgoname  varchar2(400) not null  -- 캘린더 소분류 명
,fk_userid    varchar2(40) not null   -- 캘린더 소분류 작성자 유저아이디
,constraint PK_tbl_calendar_small_category primary key(smcatgono)
,constraint FK_small_category_fk_lgcatgono foreign key(fk_lgcatgono) 
            references tbl_calendar_large_category(lgcatgono) on delete cascade
,constraint FK_small_category_fk_userid foreign key(fk_userid) references tbl_member(userid)            
);
-- Table TBL_CALENDAR_SMALL_CATEGORY이(가) 생성되었습니다.


create sequence seq_smcatgono
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;
-- Sequence SEQ_SMCATGONO이(가) 생성되었습니다.


select *
from tbl_calendar_small_category
order by smcatgono desc;


-- *** 캘린더 일정 *** 
create table tbl_calendar_schedule 
(scheduleno    number                 -- 일정관리 번호
,startdate     date                   -- 시작일자
,enddate       date                   -- 종료일자
,subject       varchar2(400)          -- 제목
,color         varchar2(50)           -- 색상
,place         varchar2(200)          -- 장소
,joinuser      varchar2(4000)         -- 공유자   
,content       varchar2(4000)         -- 내용   
,fk_smcatgono  number(8)              -- 캘린더 소분류 번호
,fk_lgcatgono  number(3)              -- 캘린더 대분류 번호
,fk_userid     varchar2(40) not null  -- 캘린더 일정 작성자 유저아이디
,constraint PK_schedule_scheduleno primary key(scheduleno)
,constraint FK_schedule_fk_smcatgono foreign key(fk_smcatgono) 
            references tbl_calendar_small_category(smcatgono) on delete cascade
,constraint FK_schedule_fk_lgcatgono foreign key(fk_lgcatgono) 
            references tbl_calendar_large_category(lgcatgono) on delete cascade   
,constraint FK_schedule_fk_userid foreign key(fk_userid) references tbl_member(userid) 
);
-- Table TBL_CALENDAR_SCHEDULE이(가) 생성되었습니다.

create sequence seq_scheduleno
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;
-- Sequence SEQ_SCHEDULENO이(가) 생성되었습니다.

select *
from tbl_calendar_schedule 
order by scheduleno desc;


-- 일정 상세 보기
select SD.scheduleno
     , to_char(SD.startdate,'yyyy-mm-dd hh24:mi') as startdate
     , to_char(SD.enddate,'yyyy-mm-dd hh24:mi') as enddate  
     , SD.subject
     , SD.color
     , nvl(SD.place,'-') as place
     , nvl(SD.joinuser,'공유자가 없습니다.') as joinuser
     , nvl(SD.content,'') as content
     , SD.fk_smcatgono
     , SD.fk_lgcatgono
     , SD.fk_userid
     , M.name
     , SC.smcatgoname
from tbl_calendar_schedule SD 
JOIN tbl_member M
ON SD.fk_userid = M.userid
JOIN tbl_calendar_small_category SC
ON SD.fk_smcatgono = SC.smcatgono
where SD.scheduleno = 21;

------------- >>>>>>>> 일정관리(풀캘린더) 끝 <<<<<<<< -------------
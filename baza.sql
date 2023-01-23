create database trudneslowa character set='utf8' collate='utf8_polish_ci';

use trudneslowa;

create table baza_slow (
id int primary key auto_increment,
wyraz varchar(30) not null,
nr int not null,
slowo varchar(30) not null,
liczba double,
portal varchar(20) not null,
data date not null,
zmiana boolean not null);

create database qlpt
create table chutro(
	mact char(10) primary key, 
	tenct nvarchar(50), 
	sdt char(10) unique CHECK (PATINDEX('%[^0-9]%', sdt) = 0) , 
	tendn varchar(16) unique check(len(tendn) >= 8), 
	mk varchar(16)CHECK (
        LEN(mk) >= 8 AND 
        PATINDEX('%[a-z]%', mk) > 0 AND   
        PATINDEX('%[A-Z]%', mk) > 0 AND 
        PATINDEX('%[@#$%&]%', mk) > 0  
    )
)
create table khachthue(
	cccd char(12) primary key CHECK (PATINDEX('%[^0-9]%', cccd) = 0), 
	tenkh nvarchar(50) check(
		LEN(tenkh) >= 8 AND 
        PATINDEX('%[a-z]%', tenkh) > 0 AND 
        PATINDEX('%[A-Z]%', tenkh) > 0 AND 
        PATINDEX('%[@#$%&]%', tenkh) > 0  
    ),
	sdtkhach char(10) CHECK (PATINDEX('%[^0-9]%', sdtkhach) = 0) unique,
	tendnkh varchar(16) unique check(len(tendnkh) >= 8), 
	mkkh varchar(16) check(
		LEN(mkkh) >= 8 AND 
        PATINDEX('%[a-z]%', mkkh) > 0 AND 
        PATINDEX('%[A-Z]%', mkkh) > 0 AND 
        PATINDEX('%[@#$%&]%', mkkh) > 0  
    ),
	gioitinh varchar(5) check(gioitinh in('Nam', 'Nu', 'Khac')), 
	ngaysinh datetime,
	quequan nvarchar(50), 
	maphong char(10)
)
create table hopdong(
	mahopdong char(10) primary key,
	ngaytao date, 
	ngayhethan date, 
	trangthai_hopdong nvarchar(20), 
	sotien_coc money,
	cccd char(12) CHECK (PATINDEX('%[^0-9]%', cccd) = 0),
	maphong char(10),
	check(ngaytao <= ngayhethan)
)
create table phongtro(
	maphong char(10) primary key, 
	dientich int check(dientich > 0), 
	soluongnguoi int check(soluongnguoi <= 3), 
	gia money default 1000000,
	trangthai_phong nvarchar(10)
)
create table hoadon(
	mahoadon char(10) primary key, 
	ngaytao date, 
	tongtien money, 
	trangthai_thanhtoan nvarchar(20),		
	maphong char(10), 
	cccd char(12) CHECK (PATINDEX('%[^0-9]%', cccd) = 0)
)
create table chitiethoadon(
	mahoadon char(10), 
	matieudung char(10), 
	soluong int check(soluong >= 1), 
	khuyenmai money
	primary key(mahoadon, matieudung)
)
create table tieudung(
	matieudung char(10) primary key, 
	tentieudung nvarchar(10),
	giaban money
)

alter table hopdong add 
constraint fk_hp_kt foreign key (cccd) references khachthue(cccd),
constraint fk_hp_pt foreign key (maphong) references phongtro(maphong) 

alter table khachthue add 
constraint fk_kt_pt foreign key (maphong) references phongtro(maphong)

alter table hoadon add 
constraint fk_hd_pt foreign key (maphong) references phongtro(maphong), 
constraint fk_hd_kt foreign key (cccd) references khachthue(cccd)

alter table chitiethoadon add 
constraint fk_cthd_hd foreign key (mahoadon) references hoadon(mahoadon), 
constraint fk_cthd_td foreign key (matieudung) references tieudung(matieudung)

DROP DATABASE qlpt

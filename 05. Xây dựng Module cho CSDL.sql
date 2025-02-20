create or alter proc spReturnNewChuTro(	@mact char(10) output, 
										@tenct nvarchar(50) output,
										@sdt char(10) output, 
										@tendn varchar(16) output, 
										@password_convert varbinary(64) output)
as begin 
	declare @mk varchar(16);
	select  @mact = 'chu' + right('0000000' + cast(isnull(max(right(mact, 7)), 0) + 1 as varchar), 7), 
			@tenct = 'tenchutro' + right('0000' + cast(isnull(max(right(tenct, 4)), 0) + 1 as varchar), 4),
			@sdt = '0' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)), 9), 
			@tendn = 'tendn' + right('0000' + cast(isnull(max(right(tendn, 4)), 0) + 1 as varchar), 4),
			@mk = (SELECT 
					CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) + -- Chữ hoa
					CHAR(97 + ABS(CHECKSUM(NEWID())) % 26) + -- Chữ thường
					CHAR(48 + ABS(CHECKSUM(NEWID())) % 10) + -- Số
					CHAR(ASCII(SUBSTRING('@#$%&', ABS(CHECKSUM(NEWID())) % 5 + 1, 1))) + -- Ký tự đặc biệt
					LEFT(REPLACE(NEWID(), '-', ''), 8) -- Loại bỏ dấu gạch ngang và lấy 8 ký tự tiếp theo
					)
	from chutro 
	exec spConvertPassword @mk, @password_convert output
end 

go 

create or alter proc spAddChuTro 
as begin
	declare @mact char(10) , 
			@tenct nvarchar(50),
			@sdt char(10), 
			@tendn varchar(16), 
			@mk varbinary(64),
			@index int = 0;
	while @index < 1000
	begin 
		exec spReturnNewChuTro @mact output, @tenct output, @sdt output, @tendn output, @mk output;
		insert into chutro(mact, tenct, sdt, tendn, mk) values 
		(@mact, @tenct, @sdt, @tendn, @mk) 
		if @@ROWCOUNT> 0 begin 
			print('them thanh cong')
			set @index = @index + 1
		end 
		else begin 
			print('them that bai, them lai')
		end 
	end
end 
go 

create or alter proc spReturnNewPhong(	@maphong char(10) output, 
										@dientich int output, 
										@soluongnguoi int output, 
										@gia money output, 
										@trangthai_phong nvarchar(10) output)
as begin 
	select  @maphong = 'phong' + right('0000000' + cast(isnull(max(right(maphong, 5)), 0) + 1 as varchar), 5)
	from phongtro;

	set @dientich = CAST((RAND() * (50 - 20) + 20) AS INT);
	set	@soluongnguoi  = CAST((RAND() * 3 + 1) AS INT);
	set	@gia = CAST((RAND() * 1000000 + 1000000) AS INT);
	set	@trangthai_phong = N'Trống'

end

go 

create or alter proc spAddPhong
as begin 
	declare @maphong char(10), 
			@dientich int, 
			@soluongnguoi int, 
			@gia money, 
			@trangthai_phong nvarchar(10),
			@index int = 0 
	while @index < 2000 begin
		exec spReturnNewPhong @maphong output, @dientich output, @soluongnguoi output, @gia output, @trangthai_phong output
		insert into phongtro(maphong, dientich, soluongnguoi, gia, trangthai_phong) values 
		(@maphong, @dientich, @soluongnguoi, @gia, @trangthai_phong) 
		if @@ROWCOUNT> 0 begin 
			print('them thanh cong')
			set @index = @index + 1
		end 
		else begin 
			print('them that bai, them lai')
		end 
	end

end 
go

CREATE OR ALTER PROC spCheckMaPhong( @ma_phong CHAR(10) )
AS 
BEGIN 
    DECLARE  @soluongnguoi INT,
			 @soluongnguoi_conlai INT,
			 @trangthai_phong nvarchar(10)

    select @soluongnguoi = case 
							when trangthai_phong = N'Trống' then 0
							else cast(SUBSTRING(trangthai_phong, 5, 1) as int)
						end,
			@soluongnguoi_conlai = soluongnguoi - @soluongnguoi
	from phongtro
	where maphong = @ma_phong

	if @soluongnguoi_conlai = 1 begin 
		set @trangthai_phong = 'FULL'
	end 
	else begin 
		set @trangthai_phong = N'có (' + cast(@soluongnguoi + 1 as varchar) + ')'
	end 

	update phongtro
	set trangthai_phong = @trangthai_phong
	where maphong = @ma_phong

END
GO

go 
CREATE OR ALTER PROC spReturnNewKhachThue(  @cccd char(12) OUTPUT, 
											@tenkh nvarchar(50) OUTPUT,
											@sdtkhach char(10) OUTPUT,
											@tendnkh varchar(16) OUTPUT,
											@password_convert varbinary(64) OUTPUT,
											@gioitinh varchar(5) OUTPUT, 
											@ngaysinh datetime OUTPUT, 
											@quequan nvarchar(50) OUTPUT, 
											@maphong char(10) OUTPUT)
AS BEGIN 
	DECLARE @startDate datetime = DATEADD(YEAR, -50, GETDATE()),
			@endDate datetime = DATEADD(YEAR, -18, GETDATE()),
			@mkkh varchar(16);

	set @ngaysinh = DATEADD(DAY, 
        CAST(RAND() * DATEDIFF(DAY, @startDate, @endDate) AS INT), 
        @startDate);

    SELECT  
		@cccd = RIGHT('000000000000' + CAST(ISNULL(MAX(cccd), 0) + 1 AS VARCHAR), 12),
        @tenkh = 'tenkh' + RIGHT('0000' + CAST(ISNULL(MAX(CAST(RIGHT(tenkh, 4) as int)), 0) + 1 AS VARCHAR), 4), 
        @sdtkhach = '0' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)), 9), 
        @tendnkh = 'tendnkh' + RIGHT('0000' + CAST(ISNULL(MAX(RIGHT(tendnkh, 4)), 0) + 1 AS VARCHAR), 4),
        @mkkh = (
            CHAR(65 + ABS(CHECKSUM(NEWID())) % 26) + -- Chữ hoa
            CHAR(97 + ABS(CHECKSUM(NEWID())) % 26) + -- Chữ thường
            CHAR(48 + ABS(CHECKSUM(NEWID())) % 10) + -- Số
            CHAR(ASCII(SUBSTRING('@#$%&', ABS(CHECKSUM(NEWID())) % 5 + 1, 1))) + -- Ký tự đặc biệt
            LEFT(REPLACE(NEWID(), '-', ''), 8) -- Loại bỏ dấu gạch ngang và lấy 8 ký tự tiếp theo
        ),
        @gioitinh = CASE FLOOR(RAND() * 3) 
                        WHEN 0 THEN 'Nam'
                        WHEN 1 THEN 'Nu'
                        else 'Khac'
                    END, 
        @quequan = 'quequan' + RIGHT('0000' + CAST(ISNULL(MAX(RIGHT(quequan, 4)), 0) + 1 AS VARCHAR), 4)
    FROM khachthue;



    set @maphong = (SELECT TOP 1 maphong 
					FROM phongtro
					where trangthai_phong != 'FULL'
					ORDER BY NEWID())

    EXEC spCheckMaPhong @maphong;  
	exec spConvertPassword @mkkh, @password_convert output

END
go

create or alter proc spAddKhachThue 
as begin
	declare @cccd char(12), 
			@tenkh nvarchar(50), 
			@sdtkhach char(10), 
			@tendnkh varchar(16), 
			@mkkh varbinary(64),
			@gioitinh varchar(5),
			@ngaysinh datetime,
			@quequan nvarchar(50),
			@maphong char(10),
			@index int = 0 
	while @index < 3000 begin

		exec spReturnNewKhachThue	@cccd output, @tenkh output, @sdtkhach output, @tendnkh output, @mkkh output, 
									@gioitinh output, @ngaysinh output, @quequan output, @maphong output

		insert into khachthue(cccd , tenkh, sdtkhach, tendnkh, mkkh, gioitinh, ngaysinh, quequan, maphong) values 
		(@cccd, @tenkh, @sdtkhach, @tendnkh, @mkkh, @gioitinh, @ngaysinh, @quequan, @maphong) 

		if @@ROWCOUNT> 0 begin 
			print('them thanh cong')
			set @index = @index + 1
		end 
		else begin 
			print('them that bai, them lai')
		end 
	end
end
go 

CREATE OR ALTER PROC spCheckHopDong(@cccd char(12),
									@maphong char(10),
									@ret bit output)
as begin 
	if exists(select 1 from hopdong where cccd = @cccd) begin 
		if not exists (select 1 from hopdong where cccd = @cccd and trangthai_hopdong = N'Còn hạn') begin 
			set @ret = 0
		end 
		else begin 
			set @ret = 1 
		end
	end 
	else begin 
		if exists(select khachthue.maphong 
				from khachthue 
					left join hopdong on khachthue.maphong = hopdong.maphong
				where hopdong.maphong is null 
					and khachthue.cccd = @cccd)
		begin 
			set @ret = 0
		end 
		else begin 
			set @ret = 1
		end
	end
end
go
CREATE OR ALTER PROC spReturnNewHopDong(@mahopdong char(10) output,
										@ngaytao date output, 
										@ngayhethan date output, 
										@trangthai_hopdong nvarchar(20) output, 
										@sotien_coc money output,
										@cccd char(12) output,
										@maphong char(10) output)
as begin 
	DECLARE @startDate datetime = DATEADD(YEAR, -2, GETDATE()),
			@endDate datetime = GETDATE(),
			@ret bit;
	declare @randomDate datetime = DATEADD(DAY, CAST(RAND() * DATEDIFF(DAY, @startDate, @endDate) AS INT), @startDate)
	
	SET @ngaytao = DATEFROMPARTS(YEAR(@randomDate), MONTH(@randomDate), 1);
	set @ngayhethan =  DATEADD(DAY, 1, EOMONTH(DATEADD(MONTH, 12, @randomDate)))

	select  @mahopdong = 'hd' + RIGHT('00000000' + CAST(ISNULL(MAX(CAST(RIGHT(mahopdong, 8) as int)), 0) + 1 AS VARCHAR), 8), 
			@trangthai_hopdong = iif(getdate() >= @ngayhethan, N'Hết hạn', N'Còn hạn'), 
			@sotien_coc = cast(rand() * 100000 + 900000 as int)
	from hopdong

	set @maphong = (SELECT TOP 1 phongtro.maphong 
					FROM phongtro
						LEFT JOIN hopdong ON phongtro.maphong = hopdong.maphong
					WHERE hopdong.maphong IS NULL
						or not exists(select 1 from hopdong where trangthai_hopdong = N'Còn hạn')
					ORDER BY NEWID())

	while 1=1 begin 
		set @cccd = (SELECT top 1 khachthue.cccd
					FROM khachthue
						LEFT JOIN hopdong ON khachthue.cccd = hopdong.cccd
					WHERE hopdong.cccd IS NULL
					ORDER BY NEWID())
		exec spCheckHopDong @cccd, @maphong, @ret output
		if @ret = 0 break 
	end 
end 
go
CREATE OR ALTER PROC spAddNewHopDong
as begin
	declare @mahopdong char(10), 
			@ngaytao date, 
			@ngayhethan date, 
			@trangthai_hopdong nvarchar(20), 
			@sotien_coc money,
			@cccd char(12),
			@maphong char(10),
			@index int = 0;
	while @index < 1000 begin
		exec spReturnNewHopDong	@mahopdong output, @ngaytao output, @ngayhethan output, @trangthai_hopdong output, 
									@sotien_coc output, @cccd output, @maphong output
		print @mahopdong
		insert into hopdong(mahopdong , ngaytao, ngayhethan, trangthai_hopdong, sotien_coc, cccd, maphong) values 
		(@mahopdong, @ngaytao, @ngayhethan, @trangthai_hopdong, @sotien_coc, @cccd, @maphong) 
		if @@ROWCOUNT> 0 begin 
			print('them thanh cong')
			set @index = @index + 1
		end 
		else begin 
			print('them that bai, them lai')
		end 
	end
end
go 

create or alter proc spReturnTieuDung(	@matieudung char(10) output, 
										@tentieudung nvarchar(10) output, 
										@giaban money output) 
as begin 
	select	@matieudung = 'td' + RIGHT('00000000' + CAST(ISNULL(MAX(CAST(RIGHT(matieudung, 8) as int)), 0) + 1 AS VARCHAR), 8),
			@tentieudung = 'ten_td' + RIGHT('00000000' + CAST(ISNULL(MAX(CAST(RIGHT(tentieudung, 4) as int)), 0) + 1 AS VARCHAR), 4),
			@giaban =  10000 + cast(rand() * 90000 as int)
	from tieudung
end 

go 

create or alter proc spAddTieuDung
as begin 
	declare	@matieudung char(10), 
			@tentieudung nvarchar(10), 
			@giaban money,
			@index int = 0; 
	while @index < 1000 begin 
		exec spReturnTieuDung @matieudung output, @tentieudung output, @giaban output
		insert into tieudung(matieudung, tentieudung, giaban) values 
		(@matieudung, @tentieudung, @giaban) 
		if @@ROWCOUNT > 0 begin 
			set @index = @index + 1 
			print 'them thanh cong'
		end 
		else begin 
			print 'them that bai'
		end 
	end 
end 

go 

create or alter proc spReturnCTHD(	@matieudung char(10) output,
									@soluong int output, 
									@khuyenmai money output)
as begin 
	set @matieudung = (select top 1 matieudung
						from tieudung
						order by NEWID()
						)
	set @soluong = cast(rand() * 100 + 1 as int)
	set @khuyenmai = (case cast(rand() * 2 as int) 
						when 1 then 0.1
						else 0 
					end)
end 

go 
create or alter proc spAddCTHD(@mahoadon char(10))
as begin 
	declare @matieudung char(10),
			@soluong int, 
			@khuyenmai money,
			@soluong_mtd int = cast(rand() * 3 + 1 as int),
			@solan int = 0; 

	while @solan < @soluong_mtd begin 
		exec spReturnCTHD @matieudung output, @soluong output, @khuyenmai output
		if exists (select 1 from chitiethoadon where mahoadon = @mahoadon and matieudung = @matieudung)
		begin
			continue
		end 
		insert into chitiethoadon(mahoadon, matieudung, soluong, khuyenmai) values 
		(@mahoadon, @matieudung, @soluong, @khuyenmai) 
		if @@ROWCOUNT > 0 begin 
			set @solan = @solan + 1 
		end
	end 
	if @solan > 0 begin 
		print 'them thanh cong ' + cast(@solan as varchar)  
	end
	else begin 
		print 'them that bai'
	end
end 

go 
create or alter proc spReturnHoaDon(@mahoadon char(10) output,
									@ngaytao date output, 
									@trangthai_thanhtoan nvarchar(20) output,
									@maphong char(10) output, 
									@cccd char(12) output)
as begin 
	declare @ngaytao_hopdong  datetime
    SET @maphong = (SELECT TOP 1 maphong
                    FROM hopdong
                    WHERE trangthai_hopdong = N'Còn hạn'
                    ORDER BY NEWID());
    print @maphong
    SET @cccd = (SELECT cccd 
                    FROM hopdong
                    WHERE maphong = @maphong);

	set @ngaytao_hopdong = (select ngaytao
							from hopdong
							where maphong = @maphong)
	set @ngaytao = CASE 
					WHEN (SELECT MAX(ngaytao) FROM hoadon WHERE maphong = @maphong) IS NULL 
						THEN @ngaytao_hopdong
					ELSE 
						DATEADD(MONTH, 1, (SELECT MAX(ngaytao) FROM hoadon WHERE maphong = @maphong))
				END;
	
    IF @ngaytao >= (SELECT ngayhethan FROM hopdong WHERE maphong = @maphong) 
    BEGIN 
        set @mahoadon = null
		return 
	END 

    IF EXISTS (SELECT 1
            FROM hoadon
            WHERE maphong = @maphong
				and trangthai_thanhtoan = N'Chưa thanh toán')
    BEGIN ;
        UPDATE hoadon
        SET trangthai_thanhtoan = N'Đã thanh toán'
        WHERE maphong = @maphong
            AND trangthai_thanhtoan = N'Chưa thanh toán';
    END

    SELECT	@mahoadon = 'hdon' + RIGHT('000000' + CAST(ISNULL(MAX(CAST(RIGHT(mahoadon, 6) AS INT)), 0) + 1 AS VARCHAR), 6),
            @trangthai_thanhtoan = N'Chưa thanh toán'
    FROM hoadon;
end
go 

create or alter proc spAddHoaDon
as begin
	declare @mahoadon char(10),
			@ngaytao date, 
			@trangthai_thanhtoan nvarchar(20),
			@total money = 0,
			@maphong char(10), 
			@cccd char(12),
			@index int = 0; 
	while @index < 1000 begin 
		exec spReturnHoaDon @mahoadon output, @ngaytao output, @trangthai_thanhtoan output, @maphong output, @cccd output
		if @mahoadon is not null begin 
			insert into hoadon(mahoadon, ngaytao, trangthai_thanhtoan, maphong, cccd) values 
			(@mahoadon, @ngaytao, @trangthai_thanhtoan, @maphong, @cccd) 
		end 
		if @@ROWCOUNT > 0 begin 
			exec spAddCTHD @mahoadon
			select @total = SUM(soluong * tieudung.giaban * (1 - khuyenmai)) 
			from chitiethoadon
				join tieudung on chitiethoadon.matieudung = tieudung.matieudung
			where mahoadon = @mahoadon
			
			update hoadon
			set tongtien = @total 
			where mahoadon = @mahoadon

			if @@ROWCOUNT > 0 begin 
				set @index = @index + 1 
				print 'them thanh cong' 
			end
			else begin 
				print 'them that bai'
			end
		end 
		else begin 
			print 'them that bai'
		end
	end
end 
go 


exec spAddChuTro
exec spAddPhong 
exec spAddKhachThue 
exec spAddNewHopDong
exec spAddTieuDung
exec spAddHoaDon

select * from chutro
select * from phongtro  
select * from khachthue 
select * from hopdong
select * from tieudung
select * from chitiethoadon
select * from hoadon

delete from chutro
delete from phongtro
delete from khachthue
delete from hopdong
delete from tieudung
delete from chitiethoadon
delete from hoadon



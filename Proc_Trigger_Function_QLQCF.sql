

--Tính thành tiền của Thanh toán chi tiết
create trigger tgCountMoney
on THANHTOANCHITIET
for insert, update
as
begin
	declare @SoLuong int, @DonGiaB int, @MaHDCT varchar(10), @MaMon varchar(10)
	set @SoLuong = (select SoLuong from inserted)
	set @MaMon = (select MaMon from inserted)
	set @DonGiaB = (select DonGiaB from MON where MaMon = @MaMon)
	set @MaHDCT = (select MaHDChiTiet from inserted)

	update THANHTOANCHITIET 
	set ThanhTien = @SoLuong * @DonGiaB
	where MaHDChiTiet = @MaHDCT

end
go

--tính tổng tiền của thanh toán
create trigger tgCountSumMoney2
on THANHTOANCHITIET
for insert, update
as
begin
	declare @MaHD varchar(10)
	set @MaHD = (select MaHD from inserted)

	update THANHTOAN
	set TongTien = (select sum(ThanhTien) from THANHTOANCHITIET where MaHD = @MaHD)
	where MaHD = @MaHD
end
go

--Tính thành tiền trong bảng NHAPCHITIET
create trigger tgMoneyOnNhapCT
on NHAPCHITIET
for insert, update
as
begin
	declare @SoLuong int, @MaHang varchar(10), @MaDNHChiTiet varchar(10)
	set @SoLuong = (select SoLuong from inserted)
	set @MaHang = (select MaHang from inserted)
	set @MaDNHChiTiet = (select MaDNHChiTiet from inserted)

	update NHAPCHITIET
	set ThanhTien = @SoLuong * (select DonGiaN from HANG where MaHang = @MaHang)
	where MaDNHChiTiet = @MaDNHChiTiet
end
go

--Tính tổng tiền trong bảng NHAP
create trigger tgMoneyOnNhap
on NHAPCHITIET
for insert, update
as
begin
	declare @MaDNH varchar(10)
	set @MaDNH = (select MaDNH from inserted)

	update NHAP
	set TongTien = (select sum(ThanhTien) from NHAPCHITIET where MaDNH = @MaDNH)
	where MaDNH = @MaDNH
end
go

go

--Chứng minh:
select count(*) from TaiKhoan where TenDangNhap = 'phanvantai' and MatKhau = '0905333999' --Trả về 1 

select count(*) from TaiKhoan where TenDangNhap = 'phanvantai' and MatKhau = '99' --Trả về 0 
 
select count(*) from TaiKhoan where TenDangNhap = 'phanvantai' and MatKhau = '0123599' or 1 = 1 --Trả về 11			
--     ' or 1 = 1 --   Khi nhập biểu thức luôn đúng và các kí tự đặc biệt này vào text box "Mật khẩu:"
--thì nó sẽ Login vào được phần mềm mặc dù nó sai --> INJECTION

go
--thủ tục lấy ra tên đăng nhập và mật khẩu để giải quyết SQL injection
create proc pGetAccount (@TenDangNhap nvarchar(50), @MatKhau nvarchar(50))
as
begin
	select * from TAIKHOAN where TenDangNhap = @TenDangNhap and MatKhau = @MatKhau
end
go


--khi xóa món thì tự động đổi thành update set status = 1 đối với món xóa
create trigger tgDeleteMon
on Mon
instead of delete
as
begin
	declare @MaMon varchar(10)
	set @MaMon = (select MaMon from deleted)

	update MON
	set Mon_Status = 1
	where MaMon = @MaMon

end
go

--Mã món tăng tự động
alter function fMaMonNew()
returns varchar(10)
as
begin
	declare @MaMonNew varchar(10), @max int,@temp varchar(10)
	set @max = (select max(cast(MaMon as int)) from MON)
	set @temp = cast((@max+1) as varchar)
	set @MaMonNew = REPLICATE('0',10 - len(@temp))+@temp

	return @MaMonNew
end

print dbo.fMaMonNew()
go

insert into MON values( dbo.fMaMonNew() ,N'Món thêm',123456, 0)

go

--mã bàn tăng tự động
alter function fMaBanNew()
returns varchar(10)
as 
begin
	declare @MaBanNew varchar(10), @max int,@temp varchar(10)
	set @max = (select max(cast(MaBan as int)) from BAN)
	set @temp = cast((@max+1) as varchar)
	set @MaBanNew = REPLICATE('0',10 - len(@temp))+@temp

	return @MaBanNew
end
go

print dbo.fMaBanNew()
go

insert into BAN values(dbo.fMaBanNew() , N'Đã đạt trước',0)
go

--xóa bàn
create trigger tgDeleteBan
on BAN
instead of delete
as
begin
	declare @MaBan varchar(10)
	set @MaBan = (select MaBan from deleted)

	update BAN
	set Ban_Status = 1
	where MaBan = @MaBan

end
go

delete BAN where MaBan = '19'
select * from BAN where Ban_Status = 0
go


--mã nhân viên tăng tự động
create function fMaNVNew()
returns varchar(10)
as
begin
	declare @MaNVNew varchar(10), @max int,@temp varchar(10)
	set @max = (select max(cast(MaNV as int)) from NHANVIEN)
	set @temp = cast((@max+1) as varchar)
	set @MaNVNew = REPLICATE('0',10 - len(@temp))+@temp

	return @MaNVNew
end

print dbo.fMaNVNew()
go
select* from NHANVIEN 

insert into NHANVIEN values(dbo.fMaNVNew(), N'MINHHhH', null, '0346588820', 'NV', 0)
update NHANVIEN set TENNV = N'', SDT='', LoaiNV ='' where MaNV = ''
go

--xóa nhân viên
create trigger tgDeleteNV
on NHANVIEN
instead of delete
as
begin
	declare @MaNV varchar(10)
	set @MaNV = (select MaNV from deleted)

	update NHANVIEN
	set NV_Status = 1
	where MaNV = @MaNV  

end
go

delete NHANVIEN where MaNV = '0000000013'
 
select * from TaiKhoan join NhanVien on NHANVIEN.MaNV = TaiKhoan.MaNV


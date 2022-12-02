
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

--hiển thị bàn
create proc pGetTable
as
begin
	select * from BAN 
end
go

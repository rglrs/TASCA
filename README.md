# Cara run API

## 1. Clone repository/Pull
### a. Cara Clone
```
git clone -b BE --single-branch https://github.com/rglrs/TASCA.git
```
### b. Cara Pull
```
git checkout BE
git pull origin BE
```
## 2. Init project go
```
go mod init tasca
```

## 3. Install dependencies
```
go mod tidy
```

## 4. Tambahkan file .env
```
cp .env.example .env
```

## 5. Ubah isi file .env sesuai dengan kebutuhan

## 6. Jalankan server
```
go run main.go
```
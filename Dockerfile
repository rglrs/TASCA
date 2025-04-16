FROM golang:1.23.3 AS builder

RUN apt-get update && apt-get install -y python3 python3-pip

WORKDIR /app

COPY . .

RUN pip3 install -r AI/requirements.txt

RUN go mod init tasca

RUN go mod tidy

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]
package utils

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"log"
	"math"
	"mime/multipart"
	"net/http"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"tasca/config"
)

func IsS3Configured() bool {
	return config.S3Cfg != nil && config.S3Cfg.Client != nil
}

func UploadFileToS3(fileHeader *multipart.FileHeader, objectKey string) (string, error) {
	if !IsS3Configured() {
		return "", fmt.Errorf("S3 client not initialized")
	}

	file, err := fileHeader.Open()
	if err != nil {
		return "", fmt.Errorf("could not open file: %w", err)
	}
	defer file.Close()

	buffer := make([]byte, fileHeader.Size)
	bytesRead, err := io.ReadFull(file, buffer)
	if err != nil {
		return "", fmt.Errorf("could not read file content (%d bytes read): %w", bytesRead, err)
	}

	contentType := http.DetectContentType(buffer)
	
	if !strings.HasPrefix(contentType, "image/") {
		return "", fmt.Errorf("uploaded file is not a valid image: %s", contentType)
	}

	log.Printf("Uploading file %s (%s, %d bytes) to S3 key: %s", 
		fileHeader.Filename, contentType, fileHeader.Size, objectKey)

	maxRetries := 3
	
	for i := 0; i < maxRetries; i++ {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		
		_, err = config.S3Cfg.Client.PutObject(ctx, &s3.PutObjectInput{
			Bucket:      aws.String(config.S3Cfg.BucketName),
			Key:         aws.String(objectKey),
			Body:        bytes.NewReader(buffer),
			ContentType: aws.String(contentType),
		})
		
		cancel()
		
		if err == nil {
			break
		}
		
		if i < maxRetries-1 {
			log.Printf("Attempt %d to upload to S3 failed: %v. Retrying...", i+1, err)
			time.Sleep(time.Duration(math.Pow(2, float64(i))) * time.Second) // Exponential backoff
		}
	}

	if err != nil {
		return "", fmt.Errorf("failed to upload object to S3 after %d attempts: %w", maxRetries, err)
	}

	log.Printf("File successfully uploaded to S3: %s", objectKey)

	return GetS3ObjectURL(objectKey), nil
}

func DeleteFileFromS3(objectKey string) error {
	if !IsS3Configured() {
		return fmt.Errorf("S3 client not initialized")
	}

	log.Printf("Attempting to delete file from S3: %s", objectKey)

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	
	_, err := config.S3Cfg.Client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(config.S3Cfg.BucketName),
		Key:    aws.String(objectKey),
	})
	
	if err != nil {
		return fmt.Errorf("failed to delete object from S3: %w", err)
	}
	
	log.Printf("File successfully deleted from S3: %s", objectKey)
	
	return nil
}

func GetS3ObjectURL(objectKey string) string {
	if !IsS3Configured() {
		return ""
	}
	return fmt.Sprintf("%s/%s", config.S3Cfg.BaseURL, objectKey)
}

func FileExistsInS3(objectKey string) (bool, error) {
	if !IsS3Configured() {
		return false, fmt.Errorf("S3 client not initialized")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	
	_, err := config.S3Cfg.Client.HeadObject(ctx, &s3.HeadObjectInput{
		Bucket: aws.String(config.S3Cfg.BucketName),
		Key:    aws.String(objectKey),
	})
	
	if err != nil {
		return false, nil
	}
	
	return true, nil
}
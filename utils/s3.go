package utils

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"mime/multipart"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"tasca/config"
)

func UploadFileToS3(fileHeader *multipart.FileHeader, objectKey string) (string, error) {
	if config.S3Cfg == nil || config.S3Cfg.Client == nil {
		return "", fmt.Errorf("S3 client not initialized")
	}

	file, err := fileHeader.Open()
	if err != nil {
		return "", err
	}
	defer file.Close()

	buffer := make([]byte, fileHeader.Size)
	if _, err = io.ReadFull(file, buffer); err != nil {
		return "", err
	}

	_, err = config.S3Cfg.Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket:      aws.String(config.S3Cfg.BucketName),
		Key:         aws.String(objectKey),
		Body:        bytes.NewReader(buffer),
		ContentType: aws.String(getContentType(fileHeader.Filename)),
		ACL: types.ObjectCannedACLPublicRead,
	})

	if err != nil {
		return "", err
	}

	return GetS3ObjectURL(objectKey), nil
}

func DeleteFileFromS3(objectKey string) error {
	if config.S3Cfg == nil || config.S3Cfg.Client == nil {
		return fmt.Errorf("S3 client not initialized")
	}

	_, err := config.S3Cfg.Client.DeleteObject(context.TODO(), &s3.DeleteObjectInput{
		Bucket: aws.String(config.S3Cfg.BucketName),
		Key:    aws.String(objectKey),
	})
	return err
}

func GetS3ObjectURL(objectKey string) string {
	if config.S3Cfg == nil {
		return ""
	}
	return fmt.Sprintf("%s/%s", config.S3Cfg.BaseURL, objectKey)
}

func FileExistsInS3(objectKey string) (bool, error) {
	if config.S3Cfg == nil || config.S3Cfg.Client == nil {
		return false, fmt.Errorf("S3 client not initialized")
	}

	_, err := config.S3Cfg.Client.HeadObject(context.TODO(), &s3.HeadObjectInput{
		Bucket: aws.String(config.S3Cfg.BucketName),
		Key:    aws.String(objectKey),
	})
	if err != nil {
		return false, nil
	}
	return true, nil
}

func getContentType(filename string) string {
	if len(filename) > 4 {
		ext := filename[len(filename)-4:]
		switch ext {
		case ".jpg", "jpeg":
			return "image/jpeg"
		case ".png":
			return "image/png"
		case ".gif":
			return "image/gif"
		case ".svg":
			return "image/svg+xml"
		case ".webp":
			return "image/webp"
		}
	}
	return "application/octet-stream"
}
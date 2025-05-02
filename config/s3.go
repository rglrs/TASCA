// File: config/s3.go
package config

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

// S3Config holds AWS S3 configuration and client
type S3Config struct {
	Client     *s3.Client
	BucketName string
	Region     string
	BaseURL    string
}

// Global S3 config instance
var S3Cfg *S3Config

// InitS3 initializes the S3 client
func InitS3() error {
	// Get S3 credentials from environment variables
	accessKey := os.Getenv("AWS_ACCESS_KEY_ID")
	secretKey := os.Getenv("AWS_SECRET_ACCESS_KEY")
	region := os.Getenv("AWS_REGION")
	bucketName := os.Getenv("AWS_S3_BUCKET")
	
	// Check for required environment variables
	if accessKey == "" || secretKey == "" {
		return fmt.Errorf("missing required AWS credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)")
	}
	
	if region == "" {
		region = "ap-southeast-2" // Default region
		log.Println("AWS_REGION not set, using default: us-east-1")
	}
	
	if bucketName == "" {
		return fmt.Errorf("missing required AWS_S3_BUCKET environment variable")
	}
	
	// Create credentials provider
	credProvider := credentials.NewStaticCredentialsProvider(accessKey, secretKey, "")
	
	// Create configuration with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 10*1000000000) // 10 seconds
	defer cancel()
	
	cfg, err := config.LoadDefaultConfig(ctx,
		config.WithRegion(region),
		config.WithCredentialsProvider(credProvider),
	)
	if err != nil {
		return fmt.Errorf("unable to load SDK config: %v", err)
	}

	// Create S3 client
	client := s3.NewFromConfig(cfg)

	// Set the base URL for constructing object URLs
	baseURL := fmt.Sprintf("https://%s.s3.%s.amazonaws.com", bucketName, region)

	// Create and store the S3 config
	S3Cfg = &S3Config{
		Client:     client,
		BucketName: bucketName,
		Region:     region,
		BaseURL:    baseURL,
	}

	// Try to safely test connection by checking if bucket exists
	// Use a timeout context to avoid hanging
	ctxTest, cancelTest := context.WithTimeout(context.Background(), 5*1000000000) // 5 seconds
	defer cancelTest()
	
	_, err = client.HeadBucket(ctxTest, &s3.HeadBucketInput{
		Bucket: aws.String(bucketName),
	})
	
	if err != nil {
		log.Printf("Warning: Could not verify S3 bucket access: %v", err)
		log.Println("S3 operations may fail if bucket doesn't exist or credentials lack permissions")
		// Continue without returning error - application should still work with local fallback
	} else {
		log.Println("S3 client initialized successfully and bucket verified")
	}
	
	return nil
}
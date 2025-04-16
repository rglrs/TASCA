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

type S3Config struct {
	Client     *s3.Client
	BucketName string
	Region     string
	BaseURL    string
}

var S3Cfg *S3Config

func InitS3() error {
	accessKey := os.Getenv("AWS_ACCESS_KEY_ID")
	secretKey := os.Getenv("AWS_SECRET_ACCESS_KEY")
	region := os.Getenv("AWS_REGION")
	bucketName := os.Getenv("AWS_S3_BUCKET")
	
	if accessKey == "" || secretKey == "" || region == "" || bucketName == "" {
		return fmt.Errorf("missing required S3 environment variables")
	}
	
	useCustomEndpoint := os.Getenv("USE_CUSTOM_S3_ENDPOINT") == "true"
	endpoint := os.Getenv("CUSTOM_S3_ENDPOINT")
	
	credProvider := credentials.NewStaticCredentialsProvider(accessKey, secretKey, "")
	
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
		config.WithCredentialsProvider(credProvider),
	)
	if err != nil {
		return fmt.Errorf("unable to load SDK config: %v", err)
	}

	options := s3.Options{
		Region:      region,
		Credentials: credProvider,
	}

	if useCustomEndpoint && endpoint != "" {
		options.EndpointResolver = s3.EndpointResolverFunc(
			func(region string, options s3.EndpointResolverOptions) (aws.Endpoint, error) {
				return aws.Endpoint{
					URL:               endpoint,
					HostnameImmutable: true,
					SigningRegion:     region,
				}, nil
			})
	}

	client := s3.NewFromConfig(cfg, func(o *s3.Options) {
		*o = options
	})

	baseURL := fmt.Sprintf("https://%s.s3.%s.amazonaws.com", bucketName, region)
	if useCustomEndpoint && endpoint != "" {
		baseURL = fmt.Sprintf("%s/%s", endpoint, bucketName)
	}

	S3Cfg = &S3Config{
		Client:     client,
		BucketName: bucketName,
		Region:     region,
		BaseURL:    baseURL,
	}

	log.Println("S3 client initialized successfully")
	return nil
}
package utils

import (
	"errors"
	"os"
	"time"

	"tasca/models"

	"github.com/golang-jwt/jwt/v5"
)

var SecretKey = []byte(os.Getenv("JWT_SECRET_KEY"))

func GenerateJWT(user models.User) (string, error) {
	claims := jwt.MapClaims{
		"id":        user.ID,
		"username":  user.Username,
		"email":     user.Email,
		"google_id": user.GoogleID,
		"exp":       time.Now().Add(time.Hour * 24).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(SecretKey)
}

func ParseJWT(tokenString string) (*jwt.Token, *models.User, error) {
	claims := jwt.MapClaims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return SecretKey, nil
	})

	if err != nil || !token.Valid {
		return nil, nil, errors.New("token tidak valid")
	}

	idFloat, ok := claims["id"].(float64)
	if !ok {
		return nil, nil, errors.New("ID tidak valid dalam token")
	}

	username, _ := claims["username"].(string)
	email, _ := claims["email"].(string)
	var googleIDPtr *string
	if googleID, ok := claims["google_id"].(string); ok && googleID != "" {
		googleIDPtr = &googleID
	}

	user := &models.User{
		ID:       uint(idFloat),
		Username: username,
		Email:    email,
		GoogleID: googleIDPtr,
	}

	return token, user, nil
}

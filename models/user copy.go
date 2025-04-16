package models

import "time"

type User struct {
	ID               uint       `gorm:"primaryKey" json:"id"`
	Username         string     `gorm:"uniqueIndex;not null" json:"username"`
	Name             string     `json:"name,omitempty"`
	Email            string     `gorm:"uniqueIndex;not null" json:"email"`
	Phone            *string    `gorm:"type:text" json:"phone,omitempty"`
	Password         string     `gorm:"not null" json:"-"`
	GoogleID         *string    `gorm:"uniqueIndex;type:text;default:null" json:"google_id,omitempty"`
	Picture          *string    `gorm:"type:text;default:null" json:"picture,omitempty"`
	Provider         string     `gorm:"type:text;default:'local'" json:"provider"`
	Todos            []Todo     `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"todos"`
	ResetToken       *string    `gorm:"type:text;default:null" json:"-"` //untuk reset password
	ResetTokenExpiry *time.Time `gorm:"default:null" json:"-"`           //untuk reset password
	CreatedAt        time.Time  `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt        time.Time  `gorm:"autoUpdateTime" json:"updated_at"`
}
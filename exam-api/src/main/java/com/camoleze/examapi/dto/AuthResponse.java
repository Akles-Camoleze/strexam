package com.camoleze.examapi.dto;

import com.camoleze.examapi.model.User;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthResponse {
    private String token;
    private User user;
    
    public static AuthResponse fromUserAndToken(User user, String token) {
        return AuthResponse.builder()
                .token(token)
                .user(user)
                .build();
    }
}
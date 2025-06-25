package com.camoleze.examapi.dto;

import lombok.Data;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Data
public class UserCreateRequest {
    @NotBlank(message = "Username is required")
    private String username;
    
    @Email(message = "Valid email is required")
    @NotBlank(message = "Email is required")
    private String email;
    
    @NotBlank(message = "Full name is required")
    private String fullName;
}
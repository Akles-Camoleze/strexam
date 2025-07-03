package com.camoleze.examapi.controller;

import com.camoleze.examapi.dto.AuthRequest;
import com.camoleze.examapi.dto.AuthResponse;
import com.camoleze.examapi.dto.UserCreateRequest;
import com.camoleze.examapi.model.User;
import com.camoleze.examapi.security.JwtUtil;
import com.camoleze.examapi.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.ReactiveAuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AuthController {

    private final ReactiveAuthenticationManager authenticationManager;
    private final UserService userService;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public Mono<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        log.info("Login attempt for user: {}", request.getUsername());
        return authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        ).flatMap(authentication -> {
            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String token = jwtUtil.generateToken(userDetails);
            return userService.getUserByUsername(userDetails.getUsername())
                    .map(user -> AuthResponse.fromUserAndToken(user, token));
        });
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<AuthResponse> register(@Valid @RequestBody UserCreateRequest request) {
        log.info("Registering new user: {}", request.getUsername());
        return userService.createUser(request)
                .flatMap(user -> {
                    UserDetails userDetails = org.springframework.security.core.userdetails.User.builder()
                            .username(user.getUsername())
                            .password(user.getPassword())
                            .authorities(java.util.Collections.emptyList())
                            .build();
                    String token = jwtUtil.generateToken(userDetails);
                    return Mono.just(AuthResponse.fromUserAndToken(user, token));
                });
    }
}
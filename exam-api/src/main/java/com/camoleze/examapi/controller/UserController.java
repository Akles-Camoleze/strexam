package com.camoleze.examapi.controller;

import com.camoleze.examapi.dto.UserCreateRequest;
import com.camoleze.examapi.model.User;
import com.camoleze.examapi.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class UserController {
    
    private final UserService userService;
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<User> createUser(@Valid @RequestBody UserCreateRequest request) {
        log.info("Creating user: {}", request.getUsername());
        return userService.createUser(request);
    }
    
    @GetMapping("/{id}")
    public Mono<User> getUserById(@PathVariable("id") Long id) {
        log.info("Getting user by id: {}", id);
        return userService.getUserById(id);
    }
    
    @GetMapping("/username/{username}")
    public Mono<User> getUserByUsername(@PathVariable("username") String username) {
        log.info("Getting user by username: {}", username);
        return userService.getUserByUsername(username);
    }
    
    @GetMapping
    public Flux<User> getAllUsers() {
        log.info("Getting all users");
        return userService.getAllUsers();
    }
    
    @PutMapping("/{id}")
    public Mono<User> updateUser(@PathVariable("id") Long id, @Valid @RequestBody UserCreateRequest request) {
        log.info("Updating user: {}", id);
        return userService.updateUser(id, request);
    }
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public Mono<Void> deleteUser(@PathVariable("id") Long id) {
        log.info("Deleting user: {}", id);
        return userService.deleteUser(id);
    }
}

package com.camoleze.examapi.service;

import com.camoleze.examapi.dto.UserCreateRequest;
import com.camoleze.examapi.model.User;
import com.camoleze.examapi.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public Mono<User> createUser(UserCreateRequest request) {
        return userRepository.existsByUsername(request.getUsername())
                .flatMap(usernameExists -> {
                    if (usernameExists) {
                        return Mono.error(new RuntimeException("Nome de usuário já existe"));
                    }
                    return userRepository.existsByEmail(request.getEmail());
                })
                .flatMap(emailExists -> {
                    if (emailExists) {
                        return Mono.error(new RuntimeException("Email já existe"));
                    }

                    User user = User.builder()
                            .username(request.getUsername())
                            .email(request.getEmail())
                            .fullName(request.getFullName())
                            .password(passwordEncoder.encode(request.getPassword()))
                            .build();

                    return userRepository.save(user);
                });
    }

    public Mono<User> getUserById(Long id) {
        return userRepository.findById(id)
                .switchIfEmpty(Mono.error(new RuntimeException("Usuário não encontrado")));
    }

    public Mono<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .switchIfEmpty(Mono.error(new RuntimeException("Usuário não encontrado")));
    }

    public Flux<User> getAllUsers() {
        return userRepository.findAll();
    }

    public Mono<User> updateUser(Long id, UserCreateRequest request) {
        return userRepository.findById(id)
                .switchIfEmpty(Mono.error(new RuntimeException("Usuário não encontrado")))
                .flatMap(existingUser -> {
                    User updatedUser = User.builder()
                            .id(existingUser.getId())
                            .username(request.getUsername())
                            .email(request.getEmail())
                            .fullName(request.getFullName())
                            .password(passwordEncoder.encode(request.getPassword()))
                            .createdAt(existingUser.getCreatedAt())
                            .build();

                    return userRepository.save(updatedUser);
                });
    }

    public Mono<Void> deleteUser(Long id) {
        return userRepository.deleteById(id);
    }
}

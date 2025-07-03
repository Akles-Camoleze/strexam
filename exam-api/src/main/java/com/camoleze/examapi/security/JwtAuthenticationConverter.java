package com.camoleze.examapi.security;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.ReactiveUserDetailsService;
import org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationToken;
import org.springframework.security.web.server.authentication.ServerAuthenticationConverter;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@RequiredArgsConstructor
public class JwtAuthenticationConverter implements ServerAuthenticationConverter {

    private final JwtUtil jwtUtil;
    private final ReactiveUserDetailsService userDetailsService;

    @Override
    public Mono<Authentication> convert(ServerWebExchange exchange) {
        System.out.println("=== JWT CONVERTER CHAMADO ===");

        return Mono.justOrEmpty(exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION))
                .filter(authHeader -> authHeader.startsWith("Bearer "))
                .map(authHeader -> authHeader.substring(7))
                .flatMap(token -> {
                    System.out.println("Processando token...");
                    String username = jwtUtil.extractUsername(token);

                    return userDetailsService.findByUsername(username)
                            .filter(userDetails -> jwtUtil.validateToken(token, userDetails))
                            .map(userDetails -> {
                                System.out.println("Criando auth para: " + userDetails.getUsername());
                                PreAuthenticatedAuthenticationToken auth = new PreAuthenticatedAuthenticationToken(
                                        userDetails, token, userDetails.getAuthorities());
                                auth.setAuthenticated(true);
                                return auth;
                            });
                })
                .cast(Authentication.class);
    }
}
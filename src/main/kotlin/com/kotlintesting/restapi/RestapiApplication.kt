package com.kotlintesting.restapi

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.web.bind.annotation.*

@SpringBootApplication
class RestapiApplication

fun main(args: Array<String>) {
	runApplication<RestapiApplication>(*args)
}

@RestController
@RequestMapping("/")
class IndexController 
{
    @GetMapping("/")
    fun index(): String  { return "Hello World!" }
}

@RestController
@RequestMapping("/hello")
class OtherController 
{

 @GetMapping("/{name}")
    fun index(@PathVariable name: String): String  { return "Hello $name!" }
}

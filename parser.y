%{
package main

import (
    "fmt"
    "text/scanner"
    "os"
    "strings"
)

type Expression interface{}
type Token struct {
    token   int
    literal string
}

type TableDef struct{
    name string
    temp bool
}
type BinOpExpr struct {
    left     Expression
    operator rune
    right    Expression
}
%}

%union{
    token Token
    stmt  Expression
    tbl   TableDef
}

%type<stmt> program
%type<stmt> stmt create_tbl_stmt
%type<stmt> create_tbl_prefix // if_not_exists
%token<token> NUMBER CREATE TEMPORARY TABLE IF NOT EXISTS tbl_name

%left '+'

%%

program
    : stmt
    {
        $$ = $1
        yylex.(*Lexer).result = $$
    }

stmt
    : create_tbl_stmt
    {
        $$ = $1
    }

create_tbl_stmt
    // : create_tbl_prefix if_not_exists tbl_name
    : create_tbl_prefix tbl_name
    {
        $$ = TableDef{name: $2.literal, temp: false}
    }

create_tbl_prefix
    : CREATE TABLE
    {
    }
    | CREATE TEMPORARY TABLE
    {
    }

/*
if_not_exists
    : 
    {}
    | IF NOT EXISTS
    {}
*/
%%

type Lexer struct {
    scanner.Scanner
    result Expression
}

func (l *Lexer) Lex(lval *yySymType) int {
    token := l.Scan()
    fmt.Printf("token: %d\n", token)
    fmt.Printf("text : %s\n", l.TokenText())
    fmt.Printf("post: %v\n", l.Position)
    if token == -1 {
        return 0
    }
    if l.TokenText() == "CREATE" {
        return CREATE
    }
    if l.TokenText() == "TABLE" {
        return TABLE
    } else {
        lval.token = Token{token: 0, literal: l.TokenText()}
        return tbl_name
    }
}

func (l *Lexer) Error(e string) {
    panic(e)
}

func main() {
    l := new(Lexer)
    l.Init(strings.NewReader(os.Args[1]))
    fmt.Println("target text: " + os.Args[1])
    yyParse(l)
    fmt.Printf("%#v\n", l.result)
}
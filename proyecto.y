%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(char *mensaje);
int yylex();
char *nuevaTemp(char tipo);
%}

%union {
    char* string_val;
}

%token <string_val> VAR NUM PUYCO PI PF INIBLO FINBLO

%token COMA POT
%token SUMA RESTA DIV MULT
%token MAYOR MENOR MAYORIG MENORIG IGIG DIF
%token AND OR
%token IGUAL
%token DEC MAIN INPUT OUTPUT IF ELSE THEN WHILE FOR
%token COMINI COMFIN

%type <string_val>  termino andor factor asignacion asifor bloque condiciones for expresion vacio ifelse

%%

programa: MAIN{ printf("main:\n"); }INIBLO bloque FINBLO { printf("Programa correcto, Angely Thomas y Pablo Vasquez\n"); };

bloque: sentencia | sentencia bloque;

sentencia: declaracion | lectura | escritura | asignacion | ifelse | while | for;

declaracion: DEC VAR otravariable PUYCO { };

lectura: INPUT VAR PUYCO { printf("INPUT %s;\n", $2); printf("call input;\n"); printf("pop %s;\n", $2); };

escritura: OUTPUT expresion PUYCO { printf("OUTPUT %s;\n", $2); printf("push %s;\n", $2);};

asignacion: VAR IGUAL expresion PUYCO { printf("%s=%s;\n", $1, $3); };

ifelse: IF PI condiciones PF INIBLO bloque FINBLO ELSE INIBLO bloque FINBLO {
    char *label1 = nuevaTemp('l');
    char *label2 = nuevaTemp('l');
    char *label3 = nuevaTemp('l');

    printf("ifz %s goto %s;\n", $3, label1);
    printf("%s:\n", label1);
    printf("%s;\n", $7); // Generar código para el bloque dentro del IF
    printf("goto %s;\n", label2);
    printf("%s:\n", label1);
    printf("%s;\n", $11); // Generar código para el bloque dentro del ELSE
    printf("%s:\n", label2);
}
| IF PI condiciones PF INIBLO bloque FINBLO {
    char *label1 = nuevaTemp('l');
    char *label2 = nuevaTemp('l');

    printf("ifz %s goto %s;\n", $3, label2);
    printf("%s:\n", label1);
    printf("%s;\n", $6); // Generar código para el bloque dentro del IF
    printf("%s:\n", label2);
};

while: WHILE PI condiciones PF INIBLO bloque FINBLO {
    char *label1 = nuevaTemp('l');
    char *label2 = nuevaTemp('l');

    // Generar código para la condición y el bucle
    printf("%s:\n", label1);
    printf("if (!(%s)) goto %s;\n", $3, label2);
    printf("%s;\n", $6);
    printf("goto %s;\n", label1);
    printf("%s:\n", label2);
};

for: FOR PI asignacion condiciones PUYCO asifor PF INIBLO bloque FINBLO {
    char *label1 = nuevaTemp('l');
    char *label2 = nuevaTemp('l');

    // Código de asignación
    printf("%s;\n", $3);

    // Generar código para la condición y el bucle
    printf("%s:\n", label1);
    printf("if (!(%s)) goto %s;\n", $5, label2);
    printf("%s;\n", $9);
    printf("%s;\n", $7); // Código del bucle
    printf("goto %s;\n", label1);
    printf("%s:\n", label2);
};

asifor: VAR IGUAL expresion PUYCO { printf("%s=%s;\n", $1, $3); };

otravariable: COMA VAR otravariable { printf("%s;\n", $2); }
            | vacio;

andor: AND { $$ = "&&"; }
     | OR { $$ = "||"; }
     | vacio { $$ = NULL; };

expresion: expresion SUMA termino { $$ = nuevaTemp('t'); printf("%s=%s+%s;\n", $$, $1, $3); }
        | expresion RESTA termino { $$ = nuevaTemp('t'); printf("%s=%s-%s;\n", $$, $1, $3); }
        | termino { $$ = $1; };

condiciones: expresion MAYOR termino andor condiciones { $$ = nuevaTemp('t'); printf("%s=%s>%s;\n", $$, $1, $3); }
        | expresion MENOR termino andor condiciones { $$ = nuevaTemp('t'); printf("%s=%s<%s;\n", $$, $1, $3); }
        | expresion IGIG termino andor condiciones { $$ = nuevaTemp('t'); printf("%s=%s==%s;\n", $$, $1, $3); }
        | expresion MAYORIG termino andor condiciones { $$ = nuevaTemp('t'); printf("%s=%s>=%s;\n", $$, $1, $3); }
        | expresion MENORIG termino andor condiciones { $$ = nuevaTemp('t'); printf("%s=%s<=%s;\n", $$, $1, $3); }
        | expresion DIF termino andor condiciones { $$ = nuevaTemp('t'); printf("%s=%s<>%s;\n", $$, $1, $3); }
        | vacio { $$ = NULL; };

termino: termino MULT factor { $$ = nuevaTemp('t'); printf("%s=%s*%s;\n", $$, $1, $3); }
        | termino DIV factor { $$ = nuevaTemp('t'); printf("%s=%s/%s;\n", $$, $1, $3); }
        | termino POT factor { $$ = nuevaTemp('t'); printf("%s=%s^%s;\n", $$, $1, $3); }
        | factor { $$ = $1; };

factor: PI expresion PF { $$ = $2; }
        | VAR { $$ = $1; }
        | NUM { $$ = $1; };

vacio: { $$ = NULL; };

%%

char *nuevaTemp(char tipo) {
    static int actual_t = 1;
    static int actual_l = 1;
    char *temp = malloc(10);

    if (tipo == 't') {
        sprintf(temp, "t%d", actual_t++);
    } else if (tipo == 'l') {
        sprintf(temp, "l%d", actual_l++);
    } else {
        fprintf(stderr, "Error: Tipo de etiqueta no válido\n");
        exit(EXIT_FAILURE);
    }

    return temp;
}

void yyerror(char *mensaje) {
    fprintf(stderr, "Error: %s\n", mensaje);
    exit(EXIT_FAILURE);
}

int main(int argc, char **argv) {
    yyparse();
    return 0;
}

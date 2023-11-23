%{
#include<stdio.h>  
#include <stdlib.h>
extern int yylex(void);
void yyerror(char *mensaje);
void nuevaTemp(char *s);
void nuevaLabel(char *s);
void llavesApertura(char *label, char *val);
void llavesAperturaIf(char *label, char *val);

static int actualLabelAux = 1, actualTempAux = 1;
%}

%union {
    char cadena[50];
}

%token <cadena> VAR NUM DEC MAIN INPUT OUTPUT PUYCO PI PF INIBLO FINBLO
%token COMA POT SUMA RESTA DIV MULT
%token MAYOR MENOR MAYORIG MENORIG IGIG DIF
%token AND OR IGUAL IF ELSE THEN WHILE FOR COMINI COMFIN MASMAS

%type <cadena> programa bloque sentencia declaracion lectura escritura asignacion ifg while for otravariable condicionesfor andor expresion termino condiciones factor vacio
%type <cadena> elses if llavesforwhile llaves

%start programa

%%

programa: MAIN { printf("section .text\n"); printf("global _start\n_start:\n"); } INIBLO bloque FINBLO { printf("Programa correcto, Angely Thomas y Pablo Vasquez\n"); };

bloque: sentencia | bloque sentencia;

sentencia: declaracion | lectura | escritura | asignacion | ifg | while | for;

declaracion: DEC VAR otravariable PUYCO;

lectura: INPUT VAR PUYCO { printf("call INPUT\npop %s\n", $3); };

escritura: OUTPUT expresion PUYCO { printf("push %s\ncall OUTPUT\n", $2); };

asignacion: VAR IGUAL expresion PUYCO { printf("mov %s, %s\n", $1, $3); };

llaves: INIBLO { llavesAperturaIf(" ", "L"); }
       ;

llavesforwhile : INIBLO { llavesApertura(" ", "L"); }
       ;


ifg : if { }
    | if elses { }
    ;

if: IF PI andor PF llaves bloque FINBLO { nuevaLabel($$); printf("cmp %s, 0\nje %s\n%s:\n", $3, $3, $$); }
    ;

elses : ELSE INIBLO bloque FINBLO { printf("jmp %s\n%s:\n", $3, $$); }
      ;

while: WHILE PI condiciones PF llavesforwhile bloque FINBLO { nuevaLabel($$); printf("%s:\ncmp %s, 0\nje %s\n", $$, $3, $3); }
    ;

for: FOR PI condicionesfor PF llavesforwhile bloque FINBLO { nuevaLabel($$); printf("%s:\ncmp %s, 0\nje %s\n", $$, $5, $5); }
    ;

otravariable: COMA VAR otravariable | vacio;

condicionesfor: VAR IGUAL factor PUYCO condiciones PUYCO VAR MASMAS { printf("mov %s, %s\n", $1, $5); }
    ;

andor: andor AND condiciones { nuevaTemp($$); printf("and %s, %s\n", $$, $3); }
     | andor OR condiciones { nuevaTemp($$); printf("or %s, %s\n", $$, $3); }
     | condiciones { }
     ;

expresion: expresion SUMA termino { nuevaTemp($$); printf("add %s, %s\n", $$, $3); }
        | expresion RESTA termino { nuevaTemp($$); printf("sub %s, %s\n", $$, $3); }
        | termino { }
        ;

termino: termino MULT factor { nuevaTemp($$); printf("imul %s, %s\n", $$, $3); }
        | termino DIV factor { nuevaTemp($$); printf("idiv %s, %s\n", $$, $3); }
        | factor { }
        ;

condiciones: expresion MAYOR termino { nuevaTemp($$); printf("cmp %s, %s\nsetg %s\n", $1, $3, $$); }
          | expresion MENOR termino { nuevaTemp($$); printf("cmp %s, %s\nsetl %s\n", $1, $3, $$); }
          | expresion IGIG termino { nuevaTemp($$); printf("cmp %s, %s\nsete %s\n", $1, $3, $$); }
          | expresion MAYORIG termino { nuevaTemp($$); printf("cmp %s, %s\nsetge %s\n", $1, $3, $$); }
          | expresion MENORIG termino { nuevaTemp($$); printf("cmp %s, %s\nsetle %s\n", $1, $3, $$); }
          | expresion DIF termino { nuevaTemp($$); printf("cmp %s, %s\nsetne %s\n", $1, $3, $$); }
          | PI condiciones PF { }
          ;

factor: PI expresion PF { }
      | VAR { }
      | NUM { }
      ;

vacio: { };

%%

void nuevaTemp(char *s) {
    static int actualTemp = 1;
    sprintf(s, "t%d", actualTemp++);
    actualTempAux = actualTemp;
}

void nuevaLabel(char *s) {
    static int actualLabel = 1;
    sprintf(s, "L%d", actualLabel++);
    actualLabelAux = actualLabel;
}

void yyerror(char *mensaje) {
    fprintf(stderr, "Error: %s\n", mensaje);
}

int main() {
    yyparse();
    return 0;
}

void llavesApertura(char *label, char *val) {
    printf("%s: cmp %s, 0\nje %s\n%s:\n", label, val, val, label);
}

void llavesAperturaIf(char *label, char *val) {
    printf("%s: cmp %s, 0\nje %s\n%s:\n", label, val, val, label);
}

%{
    #include <stdio.h>
    void yyerror(char *mensaje);
    int yylex();
%}

/*VARIABLES*/
%token VAR NUM COMA POT
/*OPERADORES*/
%token SUMA RESTA DIV MULT
/*PARENTESIS*/
%token PI PF
/*COMPARADORES*/
%token MAYOR MENOR MAYORIG MENORIG IGIG DIF
/*LOGICOS*/
%token AND OR
/*ASIGNACION*/
%token IGUAL
/*SEPARADOR DE SENTENCIAS*/
%token PUYCO
/*BLOQUES*/
%token INIBLO FINBLO
/*PALABRAS RESERVADAS*/
%token DEC MAIN INPUT OUTPUT IF ELSE THEN WHILE FOR
/*COMENTARIOS*/
%token COMINI COMFIN

%%
programa: MAIN INIBLO bloque FINBLO {printf("Programa correcto, Angely Thomas y Pablo Vasquez");};

bloque: sentencia | sentencia bloque;

sentencia: declaracion | lectura | escritura | asignacion | ifelse | while | for;

declaracion: DEC VAR otravariable PUYCO;

lectura: INPUT VAR PUYCO;

escritura: OUTPUT VAR PUYCO;

asignacion: VAR IGUAL expresion PUYCO;

ifelse: IF PI condiciones PF INIBLO bloque FINBLO ELSE INIBLO bloque FINBLO | IF PI condiciones PF INIBLO bloque FINBLO ;

while:  WHILE PI condiciones PF INIBLO bloque FINBLO;

for: FOR PI asignacion condiciones PUYCO asifor PF INIBLO bloque FINBLO;

/*AYUDAS*/

asifor: VAR IGUAL expresion;

otravariable: COMA VAR otravariable | vacio ;

andor: AND | OR | vacio;

expresion: expresion SUMA termino  
        | expresion RESTA termino 
        | termino;

condiciones: expresion MAYOR termino andor condiciones
        | expresion MENOR termino andor condiciones
        | expresion IGIG termino andor condiciones 
        | expresion MAYORIG termino andor condiciones
        | expresion MENORIG termino andor condiciones
        | expresion DIF termino andor condiciones
        | vacio;

termino: termino MULT factor | termino DIV factor | termino POT factor | factor;

factor: PI expresion PF | VAR | NUM;

vacio: ;


%%

void yyerror(char *mensaje)
{
    fprintf(stderr, "Error: %s\n", mensaje);
}

int main(int argc, char **argv)
{
    yyparse();
    return 0;
}

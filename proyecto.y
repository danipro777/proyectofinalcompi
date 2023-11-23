%{
#include<stdio.h>  
#include <stdlib.h>
void yyerror(char *mensaje);
void nuevaTemp(char *s); //para generar nuevas variables temporales
void nuevaLabel(char *s); //para generar nuevas variables label
static int inComments=0, contLc=0, contLa=0, vIf[2][100], contPos=0;
static int actualLabelAux=1, ifWhile=0, ifIf=0, ifFor=0;
static int actualTempAux=1;
int yylex();    
void llavesApertura();
void llavesAperturaIf();
%} 

%union {
    char cadena[50];
}

%token <cadena> VAR NUM DEC MAIN INPUT OUTPUT PUYCO PI PF INIBLO FINBLO
%token COMA POT SUMA RESTA DIV MULT
%token MAYOR MENOR MAYORIG MENORIG IGIG DIF
%token AND OR IGUAL IF ELSE THEN WHILE FOR COMINI COMFIN MASMAS

%type <cadena> programa bloque sentencia declaracion lectura escritura asignacion ifg while for  otravariable condicionesfor andor expresion termino condiciones factor vacio
%type <cadena> elses if

%%

programa: MAIN { printf("main:\n"); } INIBLO bloque FINBLO { printf("Programa correcto, Angely Thomas y Pablo Vasquez\n"); };

bloque: sentencia | bloque sentencia;

sentencia: declaracion | lectura | escritura | asignacion | ifg | while | for;

declaracion: DEC VAR otravariable PUYCO;

lectura: INPUT VAR PUYCO { printf("call INPUT;\npop %s;\n", $3); };

escritura: OUTPUT expresion PUYCO { printf("push %s;\ncall OUTPUT;\n", $2); };

asignacion: VAR IGUAL expresion PUYCO { printf("%s=%s;\n", $1, $3); };

llaves: INIBLO                                            {llavesAperturaIf();}
       ;
llavesforwhile : INIBLO                                            { llavesApertura();}
       ;

ifg : if                                              {}
    | if elses                                       {}
    ;

if: IF PI andor PF llaves bloque FINBLO {nuevaLabel($$); printf("GOTO #L%d\n", actualLabelAux); printf("%s: \n",$$);}
    ;

elses : ELSE INIBLO bloque FINBLO                                 {printf("GOTO #L%d\n", actualLabelAux);nuevaLabel($$); printf("%s: \n",$$);nuevaLabel($$);}
      ;
while: WHILE PI condiciones PF llavesforwhile bloque FINBLO {  printf("GOTO #L%d\n", actualLabelAux);nuevaLabel($$); printf("%s: \n",$$);nuevaLabel($$); }
    ;

for: FOR PI condicionesfor PF llavesforwhile bloque FINBLO    {  printf("GOTO #L%d\n", actualLabelAux);nuevaLabel($$); printf("%s: \n",$$);nuevaLabel($$); }
    ;

//asifor: VAR IGUAL expresion PUYCO { printf("%s=%s;\n", $1, $3); };

otravariable: COMA VAR otravariable | vacio;

condicionesfor: VAR IGUAL factor PUYCO condiciones PUYCO VAR MASMAS;

andor: andor AND condiciones { nuevaTemp($$); printf("%s = %s && %s;\n", $$, $1, $3); }
     | andor OR condiciones { nuevaTemp($$); printf("%s = %s || %s;\n", $$, $1, $3); }
     | condiciones {};

expresion: expresion SUMA termino { nuevaTemp($$); printf("%s = %s + %s;\n", $$, $1, $3); }
        | expresion RESTA termino { nuevaTemp($$); printf("%s = %s - %s;\n", $$, $1, $3); }
        | termino {};

termino: termino MULT factor { nuevaTemp($$); printf("%s = %s * %s;\n", $$, $1, $3); }
        | termino DIV factor { nuevaTemp($$); printf("%s = %s / %s;\n", $$, $1, $3); }
        | factor { };

condiciones: expresion MAYOR termino { nuevaTemp($$); printf("%s = %s > %s;\n", $$, $1, $3); }
          | expresion MENOR termino { nuevaTemp($$); printf("%s = %s < %s;\n", $$, $1, $3); }
          | expresion IGIG termino { nuevaTemp($$); printf("%s = %s == %s;\n", $$, $1, $3); }
          | expresion MAYORIG termino { nuevaTemp($$); printf("%s = %s >= %s;\n", $$, $1, $3); }
          | expresion MENORIG termino { nuevaTemp($$); printf("%s = %s <= %s;\n", $$, $1, $3); }
          | expresion DIF termino { nuevaTemp($$); printf("%s = %s <> %s;\n", $$, $1, $3); }
          | PI condiciones PF {};

factor: PI expresion PF {  }
      | VAR { }
      | NUM { };

vacio: { };

%%

void nuevaTemp(char *s) {
    static int actualTemp = 1;
    sprintf(s, "#t%d", actualTemp++);
    actualTempAux = actualTemp;
}

void nuevaLabel(char *s) {
    static int actualLabel = 1;
    sprintf(s, "#l%d", actualLabel++);
    actualLabelAux = actualLabel;
}

void yyerror(char *mensaje) {
    fprintf(stderr, "Error: %s\n", mensaje);
}

int main() {
    yyparse();
    return 0;
}
void llavesApertura(){
      printf("#L%d: IFZ #t%d GOTO #L%d\n", actualLabelAux, actualTempAux, actualLabelAux);
}
void llavesAperturaIf(){
      printf("IFZ #t%d GOTO #L%d\n",  actualTempAux, actualLabelAux);
}

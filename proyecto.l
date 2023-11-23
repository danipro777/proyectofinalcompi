%{
    #include "proyecto.tab.h"
%}

%%

"+"         {return SUMA;   }
"++"                                {return MASMAS;}
"-"         {return RESTA;  }
"/"         {return DIV;    }
"*"         {return MULT;   }
"("         {return PI;     }
")"         {return PF;     }
">"         {return MAYOR;  }
"<"         {return MENOR;  }
">="        {return MAYORIG;}
"<="        {return MENORIG;}
"=="        {return IGIG;   }
"<>"        {return DIF;    }
"||"        {return OR;     }
"="         {return IGUAL;  }
";"         {return PUYCO;  }
"{"         {return INIBLO; }
"}"         {return FINBLO; }
","         {return COMA;   }
"^"         {return POT;    }
AND         {return AND;    }
DEC         {return DEC;    }
MAIN        {return MAIN;   }
INPUT       {return INPUT;  }
OUTPUT      {return OUTPUT; }
IF          {return IF;     }
ELSE        {return ELSE;   }
THEN        {return THEN;   }
WHILE       {return WHILE;  }
FOR         {return FOR;    }
"/*"        {return COMINI;}
"*/"        {return COMFIN;}    
[0-9]+      { strcpy(yylval.cadena, yytext); return NUM;    }
[A-z0-9]*+  { strcpy(yylval.cadena, yytext); return VAR;   }
.           {}
%%

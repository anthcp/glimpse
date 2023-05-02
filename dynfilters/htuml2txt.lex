/********
 * $Id: htuml2txt.lex,v 1.1 2000/05/25 18:07:05 golda Exp $
 * $Log: htuml2txt.lex,v $
 * Revision 1.1  2000/05/25 18:07:05  golda
 * Added Christian's changes to allow dynamic filters.  I believe this has only been tested on Linux
 * systems.  --GV
 *
 * Revision 1.5  1999/11/06 21:25:07  cvogler
 * - Fixed bug that did not recognize the end of a comment correctly.
 *
 * Revision 1.4  1999/11/06 06:55:08  cvogler
 * - Added support for &gt; and &lt; (greather than, and less than).
 * -  Fixed problems with the matching rules for non-spacing tags that
 *    caused linefeeds to be incorrectly suppressed. As a result, jumping
 *    to line numbers from webglimpse searches did not work.
 *
 *
 * htuml2text.lex
 *
 * A faster HTML filter for WebGlimpse than htuml2txt.pl. I found that
 * the spawning of all the perl processes by glimpse was way too expensive
 * to be practical. In particular, searching 2000 files for a frequently
 * occuring term took more than 30 seconds on a PII-400/Linux 2.2.5
 * machine. Rewriting the filter as a set of lex rules reduced the search
 * time to 5 seconds, which is on par with the simple html2txt filter.
 *
 * Suggested options for compiling on i386/Linux with egcs 1.1.2/flex 2.5.4:
 * flex -F -8 htuml2txt.lex
 * gcc -O3 -fomit-frame-pointer -o htuml2txt lex.yy.c -lfl
 *
 * Note:    For a smaller, slightly slower executable, omit the -F switch in
 *          the call to flex.
 *
 * Caution: The -8 switch MUST be specified if -f or -F is specified!
 * 
 * Note:    It is also necessary to edit .glimpse_filters in the
 *          WebGlimpse database directories.
 *
 * Suggested options for compiling with AT&T-style lex:
 * lex htuml2txt.lex
 * cc -O -o htuml2txt lex.yy.c -ll
 * 
 * Written  on 5/16/1999 by Christian Vogler
 * Send bugreports and suggestions to cvogler@gradient.cis.upenn.edu.
 ******/


STRING           \"([^\"\n\\]|\\\")*\"
WHITE            [\ \t]

/* HTML tags that are to be eliminated altogether, without even a */
/* substitution with a space */
A                [aA]
B                [bB]
I                [iI]
EM               [eE][mM]
FONT             [fF][oO][nN][tT]
STRONG           [sS][tT][rR][oO][nN][gG]
BIG              [bB][iI][gG]
SUP              [sS][uU][pP]
SUB              [sS][uU][bB]
U                [uU]
STRIKE           [sS][tT][rR][iI][kK][eE]
STYLE            [sS][tT][yY][lL][eE]
NSPTAGS          ({A}|{B}|{I}|{EM}|{FONT}|{STRONG}|{BIG}|{SUP}|{SUB}|{U}|{STRIKE}|{STYLE})


/* These allocate the necessary space to make AT&T lex work. */
/* flex ignores them. */
%e 4000
%p 10000
%n 2000

/* treat inside of HTML comments and tags specially, to ensure that */
/* everything inside them is eliminated, even if they contain quotes */
%s COMMENT
%s TAG
%s BEGINTAG

%%

<COMMENT>[^\-\"\n\r]+                   {/* This ruleset eats up all */}
<COMMENT>-+[^\-\>\"\n\r]+               {/* HTML comments */}
<COMMENT>-\>                            {/* none */}
<COMMENT>{STRING}                       {/* none */}
<COMMENT>-{2,}\>                        BEGIN(INITIAL);

<TAG>[^\"\>\r\n]+                       {/* This ruleset discards all */}
<TAG>{STRING}                           {/* HTML tags */}
<TAG>\>                                 BEGIN(INITIAL);

<BEGINTAG>{WHITE}+                      {/* eat whitespace to find tag name */}
<BEGINTAG>!--                           BEGIN(COMMENT); /* HTML comment */
<BEGINTAG>\/                            {/* eat slash in tags */}
<BEGINTAG>{NSPTAGS}                     BEGIN(TAG); /* tag to be eliminated altogether */
<BEGINTAG>\>                            { fputc(' ', yyout); BEGIN(INITIAL);  /* whoa. Empty tag?!? Replace with space */ };
<BEGINTAG>[A-Za-z0-9]+                  |
<BEGINTAG>[^\r\n]                       { fputc(' ', yyout); BEGIN(TAG); /* all else is a tag to be replaced with a space */ }                    

<INITIAL>\<                             BEGIN(BEGINTAG); /* tag that must be analyzed further (comment, spacing tag, non-spacing tag) */



<INITIAL>&nbsp;                         fputc(' ', yyout); /* replace special */
<INITIAL>&#161;                         fputc('�', yyout); /* HTML odes with */
<INITIAL>&iexcl;                        fputc('�', yyout); /* corresponding ISO */
<INITIAL>&#162;                         fputc('�', yyout); /* codes */
<INITIAL>&cent;                         fputc('�', yyout);
<INITIAL>&#163;                         fputc('�', yyout);
<INITIAL>&pound;                        fputc('�', yyout);
<INITIAL>&#164;                         fputc('�', yyout);
<INITIAL>&curren;                       fputc('�', yyout);
<INITIAL>&#165;                         fputc('�', yyout);
<INITIAL>&yen;                          fputc('�', yyout);
<INITIAL>&#166;                         fputc('�', yyout);
<INITIAL>&brvbar;                       fputc('�', yyout);
<INITIAL>&#167;                         fputc('�', yyout);
<INITIAL>&sect;                         fputc('�', yyout);
<INITIAL>&#168;                         fputc('�', yyout);
<INITIAL>&uml;                          fputc('�', yyout);
<INITIAL>&#169;                         fputc('�', yyout);
<INITIAL>&copy;                         fputc('�', yyout);
<INITIAL>&#170;                         fputc('�', yyout);
<INITIAL>&ordf;                         fputc('�', yyout);
<INITIAL>&#171;                         fputc('�', yyout);
<INITIAL>&laquo;                        fputc('�', yyout);
<INITIAL>&#172;                         fputc('�', yyout);
<INITIAL>&not;                          fputc('�', yyout);
<INITIAL>&#173;                         fputc('\\', yyout);
<INITIAL>&shy;                          fputc('\\', yyout);
<INITIAL>&#174;                         fputc('�', yyout);
<INITIAL>&reg;                          fputc('�', yyout);
<INITIAL>&#175;                         fputc('�', yyout);
<INITIAL>&macr;                         fputc('�', yyout);
<INITIAL>&#176;                         fputc('�', yyout);
<INITIAL>&deg;                          fputc('�', yyout);
<INITIAL>&#177;                         fputc('�', yyout);
<INITIAL>&plusmn;                       fputc('�', yyout);
<INITIAL>&#178;                         fputc('�', yyout);
<INITIAL>&sup2;                         fputc('�', yyout);
<INITIAL>&#179;                         fputc('�', yyout);
<INITIAL>&sup3;                         fputc('�', yyout);
<INITIAL>&#180;                         fputc('�', yyout);
<INITIAL>&acute;                        fputc('�', yyout);
<INITIAL>&#181;                         fputc('�', yyout);
<INITIAL>&micro;                        fputc('�', yyout);
<INITIAL>&#182;                         fputc('�', yyout);
<INITIAL>&para;                         fputc('�', yyout);
<INITIAL>&#183;                         fputc('�', yyout);
<INITIAL>&middot;                       fputc('�', yyout);
<INITIAL>&#184;                         fputc('�', yyout);
<INITIAL>&cedil;                        fputc('�', yyout);
<INITIAL>&#185;                         fputc('�', yyout);
<INITIAL>&sup1;                         fputc('�', yyout);
<INITIAL>&#186;                         fputc('�', yyout);
<INITIAL>&ordm;                         fputc('�', yyout);
<INITIAL>&#187;                         fputc('�', yyout);
<INITIAL>&raquo;                        fputc('�', yyout);
<INITIAL>&#188;                         fputc('�', yyout);
<INITIAL>&frac14;                       fputc('�', yyout);
<INITIAL>&#189;                         fputc('�', yyout);
<INITIAL>&frac12;                       fputc('�', yyout);
<INITIAL>&#190;                         fputc('�', yyout);
<INITIAL>&frac34;                       fputc('�', yyout);
<INITIAL>&#191;                         fputc('�', yyout);
<INITIAL>&iquest;                       fputc('�', yyout);
<INITIAL>&#192;                         fputc('�', yyout);
<INITIAL>&Agrave;                       fputc('�', yyout);
<INITIAL>&#193;                         fputc('�', yyout);
<INITIAL>&Aacute;                       fputc('�', yyout);
<INITIAL>&#194;                         fputc('�', yyout);
<INITIAL>&circ;                         fputc('�', yyout);
<INITIAL>&#195;                         fputc('�', yyout);
<INITIAL>&Atilde;                       fputc('�', yyout);
<INITIAL>&#196;                         fputc('�', yyout);
<INITIAL>&Auml;                         fputc('�', yyout);
<INITIAL>&#197;                         fputc('�', yyout);
<INITIAL>&ring;                         fputc('�', yyout);
<INITIAL>&#198;                         fputc('�', yyout);
<INITIAL>&AElig;                        fputc('�', yyout);
<INITIAL>&#199;                         fputc('�', yyout);
<INITIAL>&Ccedil;                       fputc('�', yyout);
<INITIAL>&#200;                         fputc('�', yyout);
<INITIAL>&Egrave;                       fputc('�', yyout);
<INITIAL>&#201;                         fputc('�', yyout);
<INITIAL>&Eacute;                       fputc('�', yyout);
<INITIAL>&#202;                         fputc('�', yyout);
<INITIAL>&Ecirc;                        fputc('�', yyout);
<INITIAL>&#203;                         fputc('�', yyout);
<INITIAL>&Euml;                         fputc('�', yyout);
<INITIAL>&#204;                         fputc('�', yyout);
<INITIAL>&Igrave;                       fputc('�', yyout);
<INITIAL>&#205;                         fputc('�', yyout);
<INITIAL>&Iacute;                       fputc('�', yyout);
<INITIAL>&#206;                         fputc('�', yyout);
<INITIAL>&Icirc;                        fputc('�', yyout);
<INITIAL>&#207;                         fputc('�', yyout);
<INITIAL>&Iuml;                         fputc('�', yyout);
<INITIAL>&#208;                         fputc('�', yyout);
<INITIAL>&ETH;                          fputc('�', yyout);
<INITIAL>&#209;                         fputc('�', yyout);
<INITIAL>&Ntilde;                       fputc('�', yyout);
<INITIAL>&#210;                         fputc('�', yyout);
<INITIAL>&Ograve;                       fputc('�', yyout);
<INITIAL>&#211;                         fputc('�', yyout);
<INITIAL>&Oacute;                       fputc('�', yyout);
<INITIAL>&#212;                         fputc('�', yyout);
<INITIAL>&Ocirc;                        fputc('�', yyout);
<INITIAL>&#213;                         fputc('�', yyout);
<INITIAL>&Otilde;                       fputc('�', yyout);
<INITIAL>&#214;                         fputc('�', yyout);
<INITIAL>&Ouml;                         fputc('�', yyout);
<INITIAL>&#215;                         fputc('�', yyout);
<INITIAL>&times;                        fputc('�', yyout);
<INITIAL>&#216;                         fputc('�', yyout);
<INITIAL>&Oslash;                       fputc('�', yyout);
<INITIAL>&#217;                         fputc('�', yyout);
<INITIAL>&Ugrave;                       fputc('�', yyout);
<INITIAL>&#218;                         fputc('�', yyout);
<INITIAL>&Uacute;                       fputc('�', yyout);
<INITIAL>&#219;                         fputc('�', yyout);
<INITIAL>&Ucirc;                        fputc('�', yyout);
<INITIAL>&#220;                         fputc('�', yyout);
<INITIAL>&Uuml;                         fputc('�', yyout);
<INITIAL>&#221;                         fputc('�', yyout);
<INITIAL>&Yacute;                       fputc('�', yyout);
<INITIAL>&#222;                         fputc('�', yyout);
<INITIAL>&THORN;                        fputc('�', yyout);
<INITIAL>&#223;                         fputc('�', yyout);
<INITIAL>&szlig;                        fputc('�', yyout);
<INITIAL>&#224;                         fputc('�', yyout);
<INITIAL>&agrave;                       fputc('�', yyout);
<INITIAL>&#225;                         fputc('�', yyout);
<INITIAL>&aacute;                       fputc('�', yyout);
<INITIAL>&#226;                         fputc('�', yyout);
<INITIAL>&acirc;                        fputc('�', yyout);
<INITIAL>&#227;                         fputc('�', yyout);
<INITIAL>&atilde;                       fputc('�', yyout);
<INITIAL>&#228;                         fputc('�', yyout);
<INITIAL>&auml;                         fputc('�', yyout);
<INITIAL>&#229;                         fputc('�', yyout);
<INITIAL>&aring;                        fputc('�', yyout);
<INITIAL>&#230;                         fputc('�', yyout);
<INITIAL>&aelig;                        fputc('�', yyout);
<INITIAL>&#231;                         fputc('�', yyout);
<INITIAL>&ccedil;                       fputc('�', yyout);
<INITIAL>&#232;                         fputc('�', yyout);
<INITIAL>&egrave;                       fputc('�', yyout);
<INITIAL>&#233;                         fputc('�', yyout);
<INITIAL>&eacute;                       fputc('�', yyout);
<INITIAL>&#234;                         fputc('�', yyout);
<INITIAL>&ecirc;                        fputc('�', yyout);
<INITIAL>&#235;                         fputc('�', yyout);
<INITIAL>&euml;                         fputc('�', yyout);
<INITIAL>&#236;                         fputc('�', yyout);
<INITIAL>&igrave;                       fputc('�', yyout);
<INITIAL>&#237;                         fputc('�', yyout);
<INITIAL>&iacute;                       fputc('�', yyout);
<INITIAL>&#238;                         fputc('�', yyout);
<INITIAL>&icirc;                        fputc('�', yyout);
<INITIAL>&#239;                         fputc('�', yyout);
<INITIAL>&iuml;                         fputc('�', yyout);
<INITIAL>&#240;                         fputc('�', yyout);
<INITIAL>&ieth;                         fputc('�', yyout);
<INITIAL>&#241;                         fputc('�', yyout);
<INITIAL>&ntilde;                       fputc('�', yyout);
<INITIAL>&#242;                         fputc('�', yyout);
<INITIAL>&ograve;                       fputc('�', yyout);
<INITIAL>&#243;                         fputc('�', yyout);
<INITIAL>&oacute;                       fputc('�', yyout);
<INITIAL>&#244;                         fputc('�', yyout);
<INITIAL>&ocirc;                        fputc('�', yyout);
<INITIAL>&#245;                         fputc('�', yyout);
<INITIAL>&otilde;                       fputc('�', yyout);
<INITIAL>&#246;                         fputc('�', yyout);
<INITIAL>&ouml;                         fputc('�', yyout);
<INITIAL>&#247;                         fputc('�', yyout);
<INITIAL>&divide;                       fputc('�', yyout);
<INITIAL>&#248;                         fputc('�', yyout);
<INITIAL>&oslash;                       fputc('�', yyout);
<INITIAL>&#249;                         fputc('�', yyout);
<INITIAL>&ugrave;                       fputc('�', yyout);
<INITIAL>&#250;                         fputc('�', yyout);
<INITIAL>&uacute;                       fputc('�', yyout);
<INITIAL>&#251;                         fputc('�', yyout);
<INITIAL>&ucirc;                        fputc('�', yyout);
<INITIAL>&#252;                         fputc('�', yyout);
<INITIAL>&uuml;                         fputc('�', yyout);
<INITIAL>&#253;                         fputc('�', yyout);
<INITIAL>&yacute;                       fputc('�', yyout);
<INITIAL>&#254;                         fputc('�', yyout);
<INITIAL>&thorn;                        fputc('�', yyout);
<INITIAL>&#255;                         fputc('�', yyout);
<INITIAL>&yuml;                         fputc('�', yyout);
<INITIAL>&#34;                          fputc('\"', yyout);
<INITIAL>&quot;                         fputc('\"', yyout);
<INITIAL>&#38;                          fputc('&', yyout);
<INITIAL>&amp;                          fputc('&', yyout);
<INITIAL>&#62;                          fputc('>', yyout);
<INITIAL>&gt;                           fputc('>', yyout);
<INITIAL>&#60;                          fputc('<', yyout);
<INITIAL>&lt;                           fputc('<', yyout); 

%%


/* Define this if the filter is to be loaded as a shared library. This
   is an experimental option and requires patches to glimpse, at least
   up to version 4.12.6. The resulting speedup in searches is impressive
   and well worth the hassle. 

   For the patch and instructions, contact cvogler@gradient.cis.upenn.edu.

   These patches might be merged into the main glimpse source tree in the
   future.
*/

#ifdef SHARED_OBJECT 

int filter_func(FILE *in, FILE *out)
{
    yyout = out;
    yyrestart(in);
    BEGIN(INITIAL); /* necessary to put scanner in known state if previous
		       file contained syntax errors, or unbalanced <, >, " */
    while (yylex())
	;

    return 0;       /* all o.k. */
}



#else 

/* filter is loaded as standalone external glimpse filter process. This
   is the default.
*/

int main(void)
{
    while (yylex())
	;
    return 1;
}

#endif


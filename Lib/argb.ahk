
/********************************************

    ARGB Converter Library
    by IsNull 2010

    Licence: Public Domain

*********************************************
*/


/********************************************
* ARGB_GET(ARGB, item)
*
* ARGB: ARGB value
*
* item: A,R,G,B -> field you want
*
*********************************************
*/
ARGB_GET(ARGB, item){

    if(item = "A"){
        return (ARGB >> 24) & 0xFF
    }else if ( item = "R"){
        return (ARGB >> 16) & 0xFF
    }else if (item = "G"){
        return (ARGB >> 8) & 0xFF
    }else if (item = "B"){
        return (ARGB) & 0xFF
    }
}


/********************************************
* ARGB(A,R,G,B)
*
* returns the ARGB value
*
*********************************************
*/
ARGB(A,R,G,B){
    ;---- ensure that the values are max 0xFF (255)
    A := A & 0xFF, R := R & 0xFF
    G := G & 0xFF, B := B & 0xFF
    ;---------------------------------------------
    return ((((((R << 16) | (G << 8)) | B) | (A << 24))) & 0xFFFFFFFF)
}

/********************************************
* ARGB(A,RGB)
*
* returns the ARGB value from RGB
*
*********************************************
*/
ARGB_FromRGB(A,RGB){
    A := A & 0xFF, RGB := RGB & 0xFFFFFF
    return ((RGB | (A << 24)) & 0xFFFFFFFF)
}


/********************************************
* ARGB(A,RGB)
*
* returns the ARGB value from BGR
*
*********************************************
*/
ARGB_FromBGR(A, BGR){
   return ARGB(A & 0xFF, BGR & 0xFF,(BGR >> 8) & 0xFF, (BGR >> 16) & 0xFF)
}

RGBtoHSV(RGB, byref h, byref s, byref v)
{
	_RGBtoHSV(ToFloat(ARGB_GET(RGB, "R")),  ToFloat(ARGB_GET(RGB, "G")),  ToFloat(ARGB_GET(RGB, "B")), h, s, v)
}

;adapted from http://www.cs.rit.edu/~ncs/color/t_convert.html
;// r,g,b values are from 0 to 1
;// h = [0,360], s = [0,1], v = [0,1]
;//      if s == 0, then h = -1 (undefined)
_RGBtoHSV(r,  g,  b, byref h, byref s, byref v)
{
   ;float min, max, delta
   min := Min(r, g, b)
   max := Max(r, g, b)
   v := max           ;// v
   delta := max - min
   if( max != 0 )
      s := delta / max      ;// s
   else {
      ;// r = g = b = 0      // s = 0, v is undefined
      s := 0
      h := -1
      return
   }
   if(r == max)
      h := (g - b) / delta      ;// between yellow & magenta
   else if(g == max)
      h := 2 + (b - r) / delta   ;// between cyan & yellow
   else
      h := 4 + (r - g) / delta   ;// between magenta & cyan
   h *= 60            ;// degrees
   if(h < 0)
      h += 360
}

Min(x,y,z){
	return x < y && x < z ? x : ( z > y ? y : z )
}
Max(x,y,z){
	return x > y && x > z ? x : ( z < y ? y : z )
}
;0-1
ToFloat(item){
   return 1 / 0xFF * item
}

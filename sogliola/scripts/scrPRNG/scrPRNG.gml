function PRNG(seed) constructor {
   static state = int64(seed)
   static a = int64(6364136223846793005);
   static c = int64(1);
   static modulus = int64(0xFFFFFFFFFFFFFFFF);
   static buff = buffer_create(8,buffer_fixed,1);
   
   // Calcola il prossimo numero casuale sulla base di un GLC
   // https://it.wikipedia.org/wiki/Generatore_lineare_congruenziale 
   static _next = function() {
      state = (a * state + c) & modulus;
      return state;
   }

   // Genera un numero casuale reale tra x1 e x2. Internamente, genera prima un numero
   // double casuale tra 0 e 1. In questo caso, segno ed esponente sono fissati, mentre
   // la randomicità viene determinata dai 52 bit di mantissa che vengono estratti
   // direttametne dai numeri generati da GLC da _next. Infine, si modula il numero
   // per mapparlo sul range x1,x2
   static randomRange = function(x1,x2) {
      _next();
      buffer_seek(buff,buffer_seek_start,0);
      buffer_write(
         buff,buffer_u64,
         int64(0x3FE0000000000000) + (int64(0x000FFFFFFFFFFFFF) & state)
      );
      buffer_seek(buff,buffer_seek_start,0);
      var randval = ( buffer_read(buff,buffer_f64) - 0.5 ) * 2;
      return x1 + (x2-x1)*randval;
   }
   static iRandom = function(n) {
      return round(randomRange(0,floor(n)));
   }
   static iRandomRange = function(n1,n2) {
      return round(randomRange(floor(n1),floor(n2)));
   }
   static random = function(n) {
      return randomRange(0,n);
   }
   static setState = function(json) {
      if is_string(json)
         state = json_parse(json).st
      else state = int64(json)
   }
   static getState = function() {
      return json_stringify({ st: state })
   }
   static randomise = function() {
      // La generazione del seme si ottiene considerando anzitutto un intero
      // che rappresenta il tempo attuale considerando anche i millisecondi
      // con current_time

      var time = date_current_datetime()
      var base = current_time & 0xFF +
         (date_get_second(time) << 8) + 
         (date_get_hour(time) << (6+8)) +
         (date_get_day(time) << (6+5+8)) +
         (date_get_month(time) << (6+5+5+8))

      // Tale valore viene poi passato ad hash per produrre un 
      // seme casuale

      var hash = (md5_string_utf8(json_stringify(base)))
      state = int64(_h2d(string_copy(hash,1,2))) + 
       (int64(_h2d(string_copy(hash,3,2))) << 8  ) +
       (int64(_h2d(string_copy(hash,5,2))) << 16 ) +
       (int64(_h2d(string_copy(hash,7,2))) << 24 ) +
       (int64(_h2d(string_copy(hash,9,2))) << 32 ) +
       (int64(_h2d(string_copy(hash,11,2))) << 40 ) +
       (int64(_h2d(string_copy(hash,13,2))) << 48 ) +
       (int64(_h2d(string_copy(hash,15,2))) << 56 )
   }

   // hex2dec
   static _h2d = function(hex) 
   {
      var dec = 0;
   
      var dig = "0123456789ABCDEF";
      var len = string_length(hex);
      for (var pos = 1; pos <= len; pos += 1) {
         dec = dec << 4 | (string_pos(string_char_at(hex, pos), dig) - 1);
      }
   
      return dec;
   }

}
PRNG(42) // Inizializza PRNG

if false {
   PRNG.randomise()
   // Verifica che iRandom includa gli estremi
   while( PRNG.iRandom(9) != 9 ) {}
   while( PRNG.iRandom(9) != 0 ) {}
   // Verifica che iRandomRange includa gli estremi
   while( PRNG.iRandomRange(12,102) != 12 ) {}
   while( PRNG.iRandomRange(12,102) != 102 ) {}
   
   show_message("PRNG test pass")
}

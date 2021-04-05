use WWW;
use Gumbo;
#https://www.inegi.org.mx/app/mapas/

sub MAIN ( $acción, $objeto, Bool :$bil, Int :$año, Bool :$fuzz, Bool :$lista, Int :$escala, Str :$rango ) {
    my @noencontrados;
    my constant $urlbase = 'https://www.inegi.org.mx';
    if ! $lista {
        given $acción {
            when ( /descarga/ ) { descarga urls( $objeto , 0 ) }
            when ( /urls/ ) { urls( $objeto , 1 ) }
            when ( /info/ ) {}
        }
    } else {
        given $acción {
            when ( /descarga/ ) { descarga  filtro lista $objeto }
            when ( /urls/ ) { imprimir sort filtro lista $objeto }
            when ( /info/ ) {}
        }
    }
    if @noencontrados.elems > 0 {for @noencontrados {say "no se encontró $_"}};
    #toma los elementos coincidentes y crea para cada formato hace una linea con la información
    sub duplicador( @coincidentes ) {
        my @resultados;
        for @coincidentes {
            my $escala = $_<escala>.substr(2);$escala ~~ s/\s//;
            my ( Int $año, Str $clavecarta ) = $_<edicion>, $_<clvCarta>.uc;
            my $formateado-parcial = parse-html $_<formatos>;
            my @urlformatos = $formateado-parcial.lookfor( :TAG<a> );
            push @resultados , map { "$año $escala $clavecarta " ~ $_.nodes[0]<alt>.words[1] ~ " " ~ $urlbase ~ $_.attribs<href> } , @urlformatos;
        }
        return @resultados
    }
    #toma el elemento resultado de jget y extrae los elementos que coinciden con la busqueda dependiendo si está fuzz activado
    sub coincidentes( %listadeentrada is readonly,  Str $objetoevaluado ) {
        my Hash @resultados = grep { .defined } , grep { not $_<titulo>.contains( "Modelo digital" ) }, %listadeentrada<mapas>.list;
        #map {say $_.<clvCarta>.uc},@resultados depura ñlos resultados
        @resultados = grep {$_.<clvCarta>.uc eq $objetoevaluado.uc }, @resultados;
        push @noencontrados , $objetoevaluado if @resultados ~~ Empty;
        return @resultados
    }
    sub filtro( @resultadosdeduplicador ) {
        my @resultados = @resultadosdeduplicador;
        if ( $bil ) { @resultados = grep { $_.words[3].contains( "bil" ) } , @resultados }
        if ( $año ) { @resultados = grep { $_.words[0] == $año } , @resultados }
        if ( $escala ) { @resultados = grep { $_.words[1].split( ':' )[1] == $escala } , @resultados }
        if $rango {
            my ( Int $min, Int $max ) = sort $rango.split( /<[:-]>/ );
            @resultados = grep { $_.words[0] >= $min && $_.words[0] <= $max } , @resultados
        }
        return @resultados
    }
    sub urls( Str $objetoabuscar is readonly, Int $imprimir ) {
        my $urlbase = "https://www.inegi.org.mx/app/api/productos/interna_v1/mapas/lista/resultados/?enti=&muni=&loca=&tema=260&titg=&esca=&edic=&form=&busc=$objetoabuscar&adv=false&rango=&sens=&uedo=&reso=&point=&tipoB=2&orden=4&pagi=0&tama=100&desc=true&_=1606930592224";
        my %resultado = jget $urlbase;
        %resultado.keys.contains( 'mapas' ) && my @coco = sort filtro duplicador coincidentes(%resultado , $objetoabuscar);
        if $imprimir { for @coco { say $_[0] } }
        return @coco
    }
    sub info( $acción ) {
        my @urls = urls( $objeto , 0 );
        my $elementos = @urls.elems;
        my $años = ( map { $_.words[0] } , @urls ).sort.unique.Str;
        my $formato = ( map { $_.words[2] } , @urls ).sort.unique.Str;
        $años ~~ s:g/\s/,/;
        $formato ~~ s:g/\s/:/;
        my $repeticiones = ( map { $_.words[0] } , @urls ).sort.repeated.unique.Str;
        $repeticiones ~~ s:g/\s/,/;
        my $informe = "Se han encontrado $elementos elementos en la busqueda. Los años registrados son $años y sus formatos son $formato";
        my $informe2 = "Los siguientes años se encuentran repetidos $repeticiones,posiblemente con diferente formato ";
        my $informe3 = "para descargar un año especifico o formato active --formato y/o --año";
        say $informe;
        say $informe2;
    }
    sub lista( $objetolista ) {
        my @acumulador;
        my @objetosabuscar = $objeto.IO.lines if $objeto.IO.e or die "Documento de lista no localizade";
        map { push @acumulador , $_[0] }, map { urls( $_ , 0 ) } , @objetosabuscar;
        return @acumulador[*;*;*]
    }
    sub imprimir( @resultadodelista ) {
        for @resultadodelista {
            say $_[0]
        }
    }
    sub nombre( $elementodelistadeurls ) {
        my @split = $elementodelistadeurls.words;
        return @split[2] ~ "_" ~ @split[0] ~ ".zip"
    }
    sub descarga( @listadeurls ) {
        @listadeurls = @listadeurls.grep: {.defined}
        if ( @listadeurls.elems == 1 ) {
            my $url = @listadeurls[0].words[4];
            my $nombre = nombre @listadeurls[0];
            my $file = $nombre.IO.open :w :createonly;
            say "comenzando descarga de $nombre";
            my $descarga = get $url;
            if ! ( $descarga ~~ Failure ) {
                say "descarga terminada" if $file.write( $descarga ) or say "no se puede escribir"; }
        } else {
            map { descarga $_ } , @listadeurls
        }
    }
}
#find . "*.bil" >lista
#gdalbuildvrt -input_file_list lista index.vrt
#rm lista

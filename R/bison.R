#' Search for and collect data from the USGS Bison API.
#'
#' @export
#' @param species (character) A species name.
#' @param type (character) Type, one of scientific_name or common_name.
#' @param tsn (numeric) Specifies the TSN to query by. If you supply a tsn it 
#' doesn't make sense to supply a species name as well. Example:162003.
#' @param start (numeric) Record to start at. Default: 0. See "Pagination" 
#' in Details.
#' @param count (numeric) Number of records to return. Default: 25.
#' See "Pagination" in Details.
#' @param countyFips (character) Specifies the county fips code to 
#' geographically constrain the search to one county. Character must be 
#' supplied as a number starting with zero may lose the zero. Eg: "49015".
#' @param county (character) County name. As codes are a pain in the ass, you 
#' can put in the county name here instead of specifying a countyFips entry, 
#' and bison will attempt to look up the countyFips code. (character)
#' @param state (character) Specifies the state name to geographically 
#' constrain the search. Example: Tennessee.
#' @param aoi (character) Specifies a WKT (Well-Known Text) polygon to 
#' geographically  constrain the search.Eg.: c(-111.06 38.84,
#'         -110.80 39.377,
#'         -110.20 39.17,
#'         -110.20 38.90,
#'         -110.63 38.67,
#'         -111.06 38.84),
#'  which calls up the occurrences within the specified area. Check out 
#'  the Wikipedia page here <http://en.wikipedia.org/wiki/Well-known_text> 
#'  for an in depth look at the options, terminology, etc. 
#' @param aoibbox (character) Specifies a four-sided bounding box to 
#' geographically constrain the search (using format: minx,miny,maxx,maxy). 
#' The coordinates are Spherical Mercator with a datum of WGS84. Example: 
#' -111.31,38.81,-110.57,39.21 
#' @param params (character) String of parameters, one of providerID, 
#' resourceID, basisOfRecord, catalogNumber, year, computedStateFips, 
#' hierarchy_homonym_string, TSNs, recordedBy, occurrenceID, collectorNumber, 
#' provider, ownerInstitutionCollectionCode, eventDate, providedScientificName, 
#' scientificName, ITISscientificName, providedCommonName, ITIScommonName, 
#' kingdom, ITIStsn, centroid, higherGeographyID, computedCountyFips,
#' providedCounty, calculatedCounty, stateProvince, calculatedState, 
#' countryCode. See examples.
#' @param ... Further args passed on to [crul::HttpClient()]. See examples.
#'
#' @seealso [bison_solr()] [bison_tax()]
#' 
#' @references <https://bison.usgs.gov/#opensearch>
#' 
#' @section Pagination:
#' `bison()` paginates internally for you on the `count` parameter, so that 
#' for example, if you request 2000 records, then we'll do two requests to 
#' get all those records. If you request for example 50 records, then we 
#' just do one request. 
#'
#' @examples \dontrun{
#' bison(species="Bison bison", count=50)
#' 
#' # lots of results
#' res <- bison(species="Bison bison", count=2000)
#' res$summary
#' NROW(res$points)
#'
#' out <- bison(species="Helianthus annuus", count=300)
#' out$summary # see summary
#' out$counties # see county data
#' out$states # see state data
#' bisonmap(out, tomap = "points")
#' bisonmap(out, tomap = "county")
#' bisonmap(out, tomap = "state")
#'
#' # Search for a common name
#' bison(species="Tufted Titmouse", type="common_name")
#'
#' # Constrain search to a certain county, 49015 is Emery County in Utah
#' bison(species="Helianthus annuus", countyFips = "49015")
#'
#' # Constrain search to a certain county, specifying county name instead of 
#' # code
#' bison(species="Helianthus annuus", county = "Los Angeles")
#' # bison(species="Helianthus annuus", county = "Los")
#'
#' # Constrain search to a certain aoi, which turns out to be Emery County, 
#' # Utah as well
#' bison(species="Helianthus annuus",
#'  aoi = "POLYGON((-111.06360117772908 38.84001566645886,
#'                  -110.80542246679359 39.37707771107983,
#'                  -110.20117441992392 39.17722368276862,
#'                  -110.20666758398464 38.90844075244811,
#'                  -110.63513438085685 38.67724220095734,
#'                  -111.06360117772908 38.84001566645886))")
#'
#' # Constrain search to a certain aoibbox, which, you guessed it, is also 
#' # Emery Co., Utah
#' bison(species="Helianthus annuus", aoibbox = '-111.31,38.81,-110.57,39.21')
#'
#' # Taxonomic serial number
#' bison(tsn = 162003)
#' ## If you don't have tsn's, search for a taxonomic serial number
#' library('taxize')
#' poa_tsn <- get_tsn('Poa annua')
#' bison(tsn = poa_tsn)
#'
#' # Curl debugging and some of these examples aren't 
#' # that useful, but are given for demonstration purposes
#' ## get curl verbose output to see what's going on with your request
#' bison(tsn = 162003, count=1, verbose = TRUE)
#' ## set a timeout so that the call stops after time x, compare 1st to 2nd call
#' # bison(tsn=162003, count=1, timeout_ms = 1)
#' ## set cookies
#' bison(tsn=162003, count=1, cookie = "a=1;b=2")
#' ## user agent and verbose 
#' bison(tsn=162003, count=1, useragent = "rbison", 
#'   verbose = TRUE)
#'
#' # Params - the params function accepts a number of search terms
#' ## Find the provider with ID 318.
#' bison(params='providerID:("318")')
#' ## Find all resources with id of '318,1902' OR '318,9151', with values 
#' ## separated by spaces.
#' bison(params='resourceID:("318,1902" "318,9151")')
#' ## Criterion may be combined using the semicolon (';') character, which 
#' ## translates to a logical AND operator. Note that field names and values 
#' ## are case sensitive.
#' bison(params='providerID:("408" "432");resourceID:("14027")')
#' ## Search by basisOfRecord, for specimen types in this case
#' bison(params='basisOfRecord:(specimen)')
#' ## Search by computedStateFips, 01 for Alabama
#' bison(params='computedStateFips:01')
#' ## Search by ITIStsn
#' bison(params='ITIStsn:162003')
#' ## Search by countryCode
#' bison(params='countryCode:US')
#' ## Search by ITIScommonName
#' bison(params='ITIScommonName:"Canada goose"')
#' }

bison <- function(species=NULL, type="scientific_name", tsn=NULL, start=0, 
  count=25, countyFips=NULL, county=NULL, state=NULL, aoi=NULL, aoibbox=NULL, 
  params=NULL, ...) {

  calls <- names(sapply(match.call(), deparse))[-1]
  calls_vec <- c("what") %in% calls
  if (any(calls_vec)) {
    stop("The parameter 'what' has been removed. see `?bison`", 
      call. = FALSE)
  }
  
  stopifnot(is.numeric(count))
  stopifnot(count >= 0)
  # stopifnot(count <= 500)
  if (is.null(species)) type <- NULL
  countyFips <- county_handler(county)

  if (!is.null(tsn)) {
    itis <- 'itis'
    tsn <- as.numeric(as.character(tsn))
    stopifnot(is.numeric(tsn))
  } else { 
    itis <- NULL 
  }

  # check if param names are in the accepted list
  check_params(params)

  args <- bs_compact(
    list(species=species, type=type, itis=itis, tsn=tsn, start=start,
      count=count, countyFips=countyFips, state=state, aoi=aoi,
      aoibbox=aoibbox, params=params))
  
  if (count > 1000) {
    if (args$count > 1000) args$count <- 1000
    iter <- 0
    sumreturned <- 0
    numreturned <- 0
    outout <- list()
    while(sumreturned < count) {
      iter <- iter + 1
      tmp <- bison_GET(file.path(bison_base(), "api/search.json"), args, ...)
      # if no results, assign numreturned var with 0
      if (length(tmp$data) == 0) {
        numreturned <- 0
      } else {
        numreturned <- length(tmp$data)
      }
      sumreturned <- sumreturned + numreturned
      # if less results than maximum
      if ((numreturned > 0) && (numreturned < 1000)) {
        # update limit for metadata before exiting
        count <- numreturned
        args$count <- count
      }
      if (sumreturned < count) {
        # update args for next query
        args$start <- args$start + numreturned
        args$count <- min(c(1000, count - sumreturned))
      }
      outout[[iter]] <- tmp
    }
    pts <- dplyr::bind_rows(lapply(outout, getpoints))
    summary <- outout[[1]]$occurrences$legend
    counties <- getcounties(outout[[1]])
    states <- getstates(outout[[1]])
    tt <- list(summary=summary, states=states, counties=counties, points=pts)
  } else {
    tt <- bison_data(
      bison_GET(file.path(bison_base(), "api/search.json"), args, ...)
    )
  }

  structure(tt, class = "bison")
}

bison_GET <- function(url, args = list(), ...) {
  cli <- crul::HttpClient$new(url = url, opts = list(...))
  tt <- cli$get(query = args)
  tt$raise_for_status()  
  if (tt$status_code > 201) {
    stopifnot(tt$headers$`content-type` == "text/html;charset=utf-8")
    warning("no results found")
  } else {
    stopifnot(tt$headers$`content-type` == "application/json;charset=UTF-8")
  }
  if (tt$status_code > 201) {
    return(NA)
  } else {
    out <- tt$parse("UTF-8")
    jsonlite::fromJSON(out, FALSE)
    # return(json$occurrences$legend)
  }
}

check_params <- function(x) {
  if (!is.null(x)) {
    y <- strsplit(x, ";")[[1]]
    z <- vapply(y, function(b) strsplit(b, ":")[[1]][[1]], "", 
                USE.NAMES = FALSE)
    check <- z %in% 
      c('providerID','resourceID','basisOfRecord','catalogNumber','year',
        'computedStateFips', 'hierarchy_homonym_string','TSNs','recordedBy',
        'occurrenceID','collectorNumber', 'provider',
        'ownerInstitutionCollectionCode','eventDate','providedScientificName',
        'scientificName','ITISscientificName','providedCommonName',
        'ITIScommonName','kingdom', 'ITIStsn','centroid','higherGeographyID',
        'computedCountyFips','providedCounty',
        'calculatedCounty','stateProvince','calculatedState','countryCode')
    if (!all(check)) stop("You used in an incorrect param field", call. = FALSE)
  }
}

bison_data <- function(input) {
  summary = input$occurrences$legend
  counties = getcounties(input)
  states = getstates(input)
  points = getpoints(input)
  list(summary=summary, states=states, counties=counties, points=points)
}

getcounties <- function(x){
  tryx <- tryCatch(x$counties$total, error = function(e) e)
  if(inherits(tryx, "simpleError") || is.null(tryx)){
    NULL
  } else {
    if(x$counties$total == 0){
      NULL
    } else {
      if(is.character(x$counties$data) || length(x$counties$data) == 0){
        df <- data.frame(NULL)
      } else {
        df <- ldply(x$counties$data, function(y) data.frame(y))
        names(df)[c(1,3)] <- c("record_id","county_name")
      }
      return(df)
    }
  }
}

getstates <- function(x){
  tryx <- tryCatch(x$states$total, error = function(e) e)
  if(inherits(tryx, "simpleError") || is.null(tryx)){
    NULL
  } else {
    if(x$states$total == 0){
      NULL
    } else {
      df <- ldply(x$states$data, function(y) data.frame(y))
      names(df)[c(1,3)] <- c("record_id","county_fips")
      return(df)
    }
  }
}

getpoints <- function(x){
  tryx <- tryCatch(x$data, error = function(e) e)
  if (inherits(tryx, "simpleError")) {
    NULL
  } else if (length(x$data) == 0) {
    NULL
  } else {
    df <- data.table::setDF(
      data.table::rbindlist(x$data, use.names = TRUE, fill = TRUE))
    if ('decimalLongitude' %in% names(df)) {
      df$decimalLongitude <- 
        as.numeric(as.character(df$decimalLongitude))
    }
    if ('decimalLatitude' %in% names(df)) {
      df$decimalLatitude <- 
        as.numeric(as.character(df$decimalLatitude))
    }
    nms <- c("name","decimalLongitude","decimalLatitude","occurrenceID",
        "provider","basis","common_name","geo")
    nms_use <- nms[nms %in% names(df)]
    df <- df[, nms_use]
    return(df)
  }
}

county_handler <- function(x){
  if(!is.null(x)){
    numbs <- fips[grep(x, fips$county),]
    if(nrow(numbs) > 1){
      message("\n\n")
      print(numbs)
      message(
  "\nMore than one matching county found '", x, 
  "'!\nEnter row number of county you want (other inputs will return 'NA'):\n")
      take <- scan(n = 1, quiet = TRUE, what = 'raw')

      if(length(take) == 0)
        take <- 'notake'
      if(take %in% seq_len(nrow(numbs))){
        take <- as.numeric(take)
        message("Input accepted, took county '", 
                as.character(numbs[take, "county"]), "'.\n")
        countyFips <- paste0(numbs[take, c("fips_state","fips_county")],
                             collapse="")
      } else {
        countyFips <- NA
        message("\nReturned 'NA'!\n\n")
      }
    } else
      if(nrow(numbs) == 1){
        countyFips <- paste0(numbs[, c("fips_state","fips_county")],collapse="")
      } else
      { stop("a problem occurred finding the countyFips...") }
  } else { countyFips <- NULL }
  return( countyFips )
}

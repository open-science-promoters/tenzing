# Module UI
  
#' @title   mod_read_spreadsheet_ui and mod_read_spreadsheet_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_read_spreadsheet
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_read_spreadsheet_ui <- function(id){
  
  tagList(
    fileInput(NS(id, "file"), label = 'Choose file to upload',
              accept = c(
                '.csv',
                '.tsv',
                '.xlsx'),
              multiple = FALSE)
  )
}
    
# Module Server
    
#' @rdname mod_read_spreadsheet
#' @export
#' @keywords internal
    
mod_read_spreadsheet_server <- function(id) {
  # File uploading limit: 9MB.
  options(shiny.maxRequestSize = 9*1024^2)
  
  moduleServer(id, function(input, output, session) {
    
    # Reading tabedata from locale
    table_data <- eventReactive(input$file, {
      
      # File input requirement
      req(input$file)
      
      # Read file extension
      ext <- tools::file_ext(input$file$name)
      
      # Read data based on the extension
      table_data <- switch(ext,
                           csv = vroom::vroom(input$file$datapath, delim = ","),
                           tsv = vroom::vroom(input$file$datapath, delim = "\t"),
                           xlsx = readxl::read_xlsx(input$file$datapath, sheet = 1),
                           validate("Invalid file; Please upload a .csv, a .tsv or an .xlsx file."))
      
      # Delete empty rows
      table_data <-
        table_data %>% 
        tibble::as_tibble() %>%
        dplyr::filter_at(
          dplyr::vars(Firstname, `Middle name`, Surname),
          dplyr::any_vars(!is.na(.)))
      
      return(table_data)
      })
    
    return(list(
      data = table_data,
      uploaded = reactive(input$file)
      ))
  })
}
    
## To be copied in the UI
# mod_read_spreadsheet_ui("read_spreadsheet_ui_1")
    
## To be copied in the server
# mod_read_spreadsheet_server("read_spreadsheet_ui_1")
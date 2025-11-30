library(shiny)
library(Rulia)

# Initialisation de Julia et du package
# jlrun('import Pkg; Pkg.activate("/Users/maximedesjobert/Documents/M1SSD/FormationJulia/Packages/RPGSimulator.jl")')
jlusing(RPGSimulator)

ui <- fluidPage(
  titlePanel("🎮 Simulateur de Combat RPG"),
  
  theme = bslib::bs_theme(version = 5, bootswatch = "darkly"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("⚔️ Configuration du Combat"),
      
      hr(),
      
      h5("Combattant 1"),
      textInput("nom1", "Nom:", value = "Jed"),
      selectInput("classe1", "Classe:", 
                  choices = c("Mage", "Chevalier", "Gobelin", "Archer"),
                  selected = "Mage"),
      
      hr(),
      
      h5("Combattant 2"),
      textInput("nom2", "Nom:", value = "Hussin"),
      selectInput("classe2", "Classe:", 
                  choices = c("Mage", "Chevalier", "Gobelin", "Archer"),
                  selected = "Chevalier"),
      
      hr(),
      
      actionButton("lancer_combat", "⚔️ Lancer le Combat", 
                   class = "btn-danger btn-lg btn-block",
                   style = "margin-top: 20px;")
    ),
    
    mainPanel(
      width = 9,
      
      tabsetPanel(
        id = "tabs",
        
        tabPanel("📊 Résultat",
                 br(),
                 uiOutput("vainqueur_ui"),
                 br(),
                 verbatimTextOutput("combat_log"),
                 value = "resultat"
        ),
        
        tabPanel("📈 Analyse",
                 br(),
                 plotOutput("evolution_pv", height = "400px"),
                 br(),
                 plotOutput("degats_par_round", height = "400px"),
                 value = "analyse"
        ),
        
        tabPanel("📋 Détails",
                 br(),
                 h4("Tableau des actions"),
                 tableOutput("tableau_combat"),
                 value = "details"
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Stocker les résultats du combat
  resultats_combat <- reactiveVal(NULL)
  
  # Lancer le combat
  observeEvent(input$lancer_combat, {
    
    # Créer les combattants avec jleval pour évaluer les commandes Julia
    cmd1 <- sprintf('%s(nom="%s")', input$classe1, input$nom1)
    cmd2 <- sprintf('%s(nom="%s")', input$classe2, input$nom2)
    
    combattant1 <- jleval(cmd1)
    combattant2 <- jleval(cmd2)
    
    # Capturer le log du combat
    combat_log <- capture.output({
      fight <- jl(combat)(combattant1, combattant2)
    })
    
    # Extraire les résultats
    vainqueur <- R( (fight[1]))
    historique_matrix <- R( (fight[2]))
    
    # Convertir la matrice en dataframe
    historique_df <- as.data.frame(t(historique_matrix), stringsAsFactors = FALSE)
    
    # Convertir les colonnes numériques SANS décimales
    cols_numeriques <- c("round", "damage", "actor_PV", "target_PV")
    for (col in cols_numeriques) {
      if (col %in% colnames(historique_df)) {
        historique_df[[col]] <- as.integer(round(as.numeric(historique_df[[col]])))
      }
    }
    
    # Renommer les colonnes en français
    colnames(historique_df) <- c("Tour", "Attaquant", "Action", "Cible", "Dégâts", "PV_Attaquant", "PV_Cible")
    
    # Stocker les résultats
    resultats_combat(list(
      vainqueur = vainqueur,
      log = paste(combat_log, collapse = "\n"),
      historique = historique_df,
      nom1 = input$nom1,
      nom2 = input$nom2
    ))
  })
  
  # Afficher le vainqueur
  output$vainqueur_ui <- renderUI({
    req(resultats_combat())
    res <- resultats_combat()
    
    div(
      style = "text-align: center; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 10px; color: white;",
      h2(style = "margin: 0;", "🏆 VAINQUEUR 🏆"),
      h1(style = "margin: 10px 0; font-size: 48px; text-shadow: 2px 2px 4px rgba(0,0,0,0.5);", 
         res$vainqueur)
    )
  })
  
  # Tableau détaillé
  output$tableau_combat <- renderTable({
    req(resultats_combat())
    resultats_combat()$historique
  }, striped = TRUE, hover = TRUE, bordered = TRUE, digits = 0)
  
  # Graphique d'évolution des PV
  output$evolution_pv <- renderPlot({
    req(resultats_combat())
    res <- resultats_combat()
    hist <- res$historique
    
    # Préparer les données pour le graphique
    pv_data <- data.frame()
    
    for (i in 1:nrow(hist)) {
      round_num <- hist$round[i]
      actor <- hist$actor[i]
      target <- hist$target[i]
      
      pv_data <- rbind(pv_data, data.frame(
        round = round_num,
        personnage = actor,
        PV = hist$actor_PV[i],
        moment = "après"
      ))
      
      pv_data <- rbind(pv_data, data.frame(
        round = round_num,
        personnage = target,
        PV = hist$target_PV[i],
        moment = "après"
      ))
    }
    
    # Retirer les doublons
    pv_data <- unique(pv_data)
    pv_data <- pv_data[order(pv_data$round), ]
    
    # Créer le graphique
    par(bg = "#1a1a1a", col.axis = "white", col.lab = "white", col.main = "white")
    
    personnages <- unique(pv_data$personnage)
    couleurs <- c("#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A")
    
    plot(NULL, xlim = c(1, max(pv_data$round)), ylim = c(0, max(pv_data$PV, na.rm = TRUE)),
         xlab = "Round", ylab = "Points de Vie", 
         main = "Évolution des Points de Vie par Round",
         cex.lab = 1.2, cex.main = 1.5)
    
    grid(col = "gray30")
    
    for (i in seq_along(personnages)) {
      perso_data <- pv_data[pv_data$personnage == personnages[i], ]
      lines(perso_data$round, perso_data$PV, col = couleurs[i], lwd = 3, type = "b", pch = 19)
    }
    
    legend("topright", legend = personnages, col = couleurs[1:length(personnages)], 
           lwd = 3, pch = 19, bg = "#2a2a2a", text.col = "white", cex = 1.1)
  })
  
  # Graphique des dégâts par round
  output$degats_par_round <- renderPlot({
    req(resultats_combat())
    res <- resultats_combat()
    hist <- res$historique
    
    par(bg = "#1a1a1a", col.axis = "white", col.lab = "white", col.main = "white")
    
    # Agréger les dégâts par round et par acteur
    degats_agg <- aggregate(damage ~ round + actor, data = hist, FUN = sum)
    
    # Créer une matrice pour le graphique en barres
    rounds <- sort(unique(degats_agg$round))
    acteurs <- unique(degats_agg$actor)
    
    mat_degats <- matrix(0, nrow = length(acteurs), ncol = length(rounds))
    rownames(mat_degats) <- acteurs
    colnames(mat_degats) <- rounds
    
    for (i in 1:nrow(degats_agg)) {
      acteur <- as.character(degats_agg$actor[i])
      round_num <- degats_agg$round[i]
      mat_degats[acteur, as.character(round_num)] <- degats_agg$damage[i]
    }
    
    couleurs <- c("#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A")
    
    barplot(mat_degats, beside = TRUE, col = couleurs[1:length(acteurs)],
            xlab = "Round", ylab = "Dégâts Infligés",
            main = "Dégâts Infligés par Round",
            legend.text = rownames(mat_degats),
            args.legend = list(bg = "#2a2a2a", text.col = "white", cex = 1.1))
    
    grid(col = "gray30", ny = NULL)
  })
}

shinyApp(ui = ui, server = server)
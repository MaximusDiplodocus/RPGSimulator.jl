library(shiny)
library(Rulia)

# Initialisation de Julia et du package
jlrun('import Pkg; Pkg.activate("/Users/maximedesjobert/Documents/M1SSD/FormationJulia/Packages/RPGSimulator.jl")') # à personnaliser
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
      
      checkboxInput("custom_stats1", "Personnaliser les statistiques", value = FALSE),
      
      conditionalPanel(
        condition = "input.custom_stats1 == true",
        numericInput("pv1", "Points de Vie (PV):", value = 100, min = 1, max = 500),
        numericInput("pm1", "Points de Magie (PM):", value = 50, min = 0, max = 200),
        numericInput("atk1", "Attaque:", value = 20, min = 1, max = 100),
        numericInput("vitesse1", "Vitesse:", value = 15, min = 1, max = 50),
        numericInput("defense1", "Défense:", value = 10, min = 0, max = 50)
      ),
      
      hr(),
      
      h5("Combattant 2"),
      textInput("nom2", "Nom:", value = "Hussin"),
      selectInput("classe2", "Classe:", 
                  choices = c("Mage", "Chevalier", "Gobelin", "Archer"),
                  selected = "Chevalier"),
      
      checkboxInput("custom_stats2", "Personnaliser les statistiques", value = FALSE),
      
      conditionalPanel(
        condition = "input.custom_stats2 == true",
        numericInput("pv2", "Points de Vie (PV):", value = 100, min = 1, max = 500),
        numericInput("pm2", "Points de Magie (PM):", value = 50, min = 0, max = 200),
        numericInput("atk2", "Attaque:", value = 20, min = 1, max = 100),
        numericInput("vitesse2", "Vitesse:", value = 15, min = 1, max = 50),
        numericInput("defense2", "Défense:", value = 10, min = 0, max = 50)
      ),
      
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
                 uiOutput("vainqueur_combat"),
                 br(),
                 uiOutput("stats_combattants")
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
    
    # Créer les combattants avec ou sans stats personnalisées
    # Création du combattant 1
    if (input$custom_stats1) {
      cmd1 <- sprintf(
        'c = %s(nom="%s"); c.stats.PV=%d; c.stats.PM=%d; c.stats.ATK=%d; c.stats.VITESSE=%d; c.stats.DEFENSE=%d; c',
        input$classe1, input$nom1,
        input$pv1, input$pm1, input$atk1, input$vitesse1, input$defense1
      )
    } else {
      cmd1 <- sprintf('%s(nom="%s")', input$classe1, input$nom1)
    }
    
    # Création du combattant 2
    if (input$custom_stats2) {
      cmd2 <- sprintf(
        'c = %s(nom="%s"); c.stats.PV=%d; c.stats.PM=%d; c.stats.ATK=%d; c.stats.VITESSE=%d; c.stats.DEFENSE=%d; c',
        input$classe2, input$nom2,
        input$pv2, input$pm2, input$atk2, input$vitesse2, input$defense2
      )
    } else {
      cmd2 <- sprintf('%s(nom="%s")', input$classe2, input$nom2)
    }
    
    combattant1 <- jleval(cmd1)
    combattant2 <- jleval(cmd2)
    
    # Capturer le log du combat
    fight <- jl(combat)(combattant1, combattant2)
    
    # Extraire les résultats
    vainqueur <- R( (fight[1]))
    historique_matrix <- R( (fight[2]))
    
    # Convertir la matrice en dataframe
    historique_df <- as.data.frame(t(historique_matrix), stringsAsFactors = FALSE)
    
    # Convertir les colonnes numériques sans décimales
    cols_numeriques <- c("round", "damage", "actor_PV", "target_PV")
    for (col in cols_numeriques) {
      if (col %in% colnames(historique_df)) {
        historique_df[[col]] <- as.integer(round(as.numeric(historique_df[[col]])))
      }
    }
    
    # Renommer les colonnes en français
    colnames(historique_df) <- c("Tour", "Attaquant", "Action", "Cible", "Degats", "PV_Attaquant", "PV_Cible")
    
    # Stocker les résultats
    resultats_combat(list(
      vainqueur = vainqueur,
      historique = historique_df,
      nom1 = input$nom1,
      nom2 = input$nom2
    ))
  })
  
  # Afficher le vainqueur
  output$vainqueur_combat <- renderUI({
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
    hist <- resultats_combat()$historique
    
    # Construire pv_data depuis l'historique
    pv_data <- data.frame(
      round = hist$Tour,
      personnage = as.character(hist$Cible),
      PV = hist$PV_Cible,
      degats = hist$Degats
    )
    
    # Ajout des PV initiaux
    pv_base <- aggregate(
      cbind(PV, degats) ~ personnage,
      pv_data,
      function(x) x[1]
    )
    
    pv_base$PV <- pv_base$PV + pv_base$degats
    pv_base$round <- 0 
    pv_base$degats <- NULL
    
    # Ajouter à pv_data
    pv_data <- rbind(pv_base, pv_data[, c("round","personnage","PV")])
    pv_data <- pv_data[order(pv_data$round), ]
    
    # Graphique
    plot(
      pv_data$round[pv_data$personnage == pv_data$personnage[1]],
      pv_data$PV[pv_data$personnage == pv_data$personnage[1]],
      type = "b", lwd = 3, pch = 19, col = "#FF6B6B",
      xlab = "Tour",
      ylab = "Points de Vie",
      main = "Évolution des PV",
      ylim = c(0, max(pv_data$PV) + 10),
      xaxt = "n"
    )
    
    # Ajouter le 2ᵉ personnage
    lines(
      pv_data$round[pv_data$personnage == pv_data$personnage[2]],
      pv_data$PV[pv_data$personnage == pv_data$personnage[2]],
      type = "b", lwd = 3, pch = 19, col = "#4ECDC4"
    )
    
    # Ajouter l'axe X avec uniquement des entiers
    axis(
      1,
      at = min(pv_data$round):max(pv_data$round),
      labels = min(pv_data$round):max(pv_data$round)
    )
    
    # Ajouter la légende
    legend(
      "topright",
      legend = pv_data$personnage[1:2],
      col = c("#FF6B6B", "#4ECDC4"),
      lwd = 3,
      pch = 19
    )
  })
  
  # Graphique du nombre de dégâts par tour
  output$degats_par_round <- renderPlot({
    req(resultats_combat())
    hist <- resultats_combat()$historique
    
    # Construire un data frame pour les dégâts
    degats_data <- data.frame(
      round = hist$Tour,
      personnage = as.character(hist$Attaquant),
      degats = hist$Degats
    )
    
    # On suppose toujours 2 personnages
    personnage1 <- unique(degats_data$personnage)[1]
    personnage2 <- unique(degats_data$personnage)[2]
    
    # Couleurs
    couleurs <- c("#4ECDC4", "#FF6B6B")
    
    # Limites de l'axe Y
    ylim_max <- max(degats_data$degats) + 5
    
    # Graphique du premier personnage
    plot(
      degats_data$round[degats_data$personnage == personnage1],
      degats_data$degats[degats_data$personnage == personnage1],
      type = "b", lwd = 3, pch = 19, col = couleurs[1],
      xlab = "Tour",
      ylab = "Dégâts",
      main = "Dégâts infligés par tour",
      ylim = c(0, ylim_max),
      xaxt = "n"
    )
    
    # Graphique du deuxième personnage
    lines(
      degats_data$round[degats_data$personnage == personnage2],
      degats_data$degats[degats_data$personnage == personnage2],
      type = "b", lwd = 3, pch = 19, col = couleurs[2]
    )
    
    # Axe X en entiers
    axis(1, at = min(degats_data$round):max(degats_data$round),
         labels = min(degats_data$round):max(degats_data$round))
    
    # Légende
    legend(
      "topright",
      legend = c(personnage1, personnage2),
      col = couleurs,
      lwd = 3,
      pch = 19
    )
  })
  
}

shinyApp(ui = ui, server = server)
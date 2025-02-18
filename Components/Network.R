output$network <- renderEcharts4r({
  data <- networkData()
  
  e_charts() %>%
    e_graph() %>%
    e_graph_nodes(data$node,
                  names = id,
                  value = label,
                  size = effectSize) %>%
    e_graph_edges(data$edge, target = target, source = source) %>%
    e_modularity() %>%
    e_labels() %>%
    e_tooltip(
      formatter = htmlwidgets::JS('function(params) {
        if (["クルーズ船", "卓球スクール", "ライブハウス", "スポーツジム", "展示会"].includes(params.name)) {
          return("")
        }
        const label = params.value.split("#")
        return("<b>" + params.name + "番患者</b><br><br>年齢：" +
          label[0] + "<br>性別：" + label[1] + "<br>居住地：" + 
          label[2] + "<br><br>" + label[3])
      }')
    )
})

networkData <- reactive({
  # クラスタラベル
  clusterLabel <- c('クルーズ船', '卓球スクール', 'ライブハウス', 'スポーツジム', '展示会')
  # ノット作成
  confirmedNodes <-
    detail[, c('id',
               'age',
               'gender',
               'residence',
               'relatedConfirmed',
               'subgroup')] # ノット
  confirmedNodes$gender <- as.character(confirmedNodes$gender)
  confirmedNodes$effectSize <-
    sapply(confirmedNodes$relatedConfirmed, function(x) {
      count <- length(strsplit(x, ',')[[1]])
      K <- 8
      size <- K * count
      if (size > 32) {
        size <- 32 + count
      }
      size
    })
  # エッジ作成
  confirmedEdges <- data.frame('source' = 0, 'target' = 0) # エッジ初期化
  for (i in 1:nrow(confirmedNodes)) {
    relation <-
      strsplit(confirmedNodes$relatedConfirmed[i], ',')[[1]] # 複数関連者対応
    # クラスター対応
    if (relation[1] %in% clusterLabel) {
      confirmedEdges <-
        rbind(confirmedEdges, c(confirmedNodes[i]$id, relation[1]), stringsAsFactors = F)
    } else if (relation[1] == 0 ||
        suppressWarnings(is.na(as.numeric(relation)))) {
      # 関連者なしの場合、エッジを自分から自分へに設定する
      item <- c(confirmedNodes[i]$id, confirmedNodes[i]$id)
      confirmedEdges <-
        rbind(confirmedEdges, item, stringsAsFactors = F)
    } else if (length(relation) > 1) {
      for (j in 1:length(relation)) {
        # 最初に確認された患者をソース源にする
        id <- confirmedNodes[i]$id
        item <- if (id < as.numeric(relation[j]))
          c(id, relation[j])
        else
          c(relation[j], confirmedNodes[i]$id)
        confirmedEdges <-
          rbind(confirmedEdges, item, stringsAsFactors = F)
      }
    } else {
      item <- c(confirmedNodes[i]$id, relation)
      confirmedEdges <-
        rbind(confirmedEdges, item, stringsAsFactors = F)
    }
  }
  confirmedEdges <- data.table(confirmedEdges)
  
  # 離散のポイントを非表示するか
  if (input$hideSingle) {
    filterResult <-
      confirmedEdges[confirmedEdges$source != confirmedEdges$target]
    inSource <-
      sapply(as.character(confirmedNodes$id), function(x) {
        x %in% filterResult$source
      })
    inTarget <-
      sapply(confirmedNodes$id, function(x) {
        x %in% filterResult$target
      })
    confirmedNodes <-
      confirmedNodes[rowSums(data.frame(inSource, inTarget)) > 0,]
  }
  confirmedNodes$id <- as.character(confirmedNodes$id)
  confirmedNodes$label <- paste(sep = "#", 
                                confirmedNodes$age, 
                                confirmedNodes$gender, 
                                confirmedNodes$residence,
                                confirmedNodes$subgroup)
  
  # クラスタ対応
  for (x in clusterLabel) {
    confirmedNodes <- rbind(confirmedNodes, list('id' = x, 'label' = x, 'effectSize' = 15), fill = T)
  }
  # data <- list(node = confirmedNodes, edge = confirmedEdges)
  return(list(node = confirmedNodes, edge = confirmedEdges))
})

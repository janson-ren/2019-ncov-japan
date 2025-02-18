# ====区域ごとの確認数====
output$totalConfirmedByRegionPlot <- renderEcharts4r({
  dt <- totalConfirmedByRegionData()[count > 0][order(-count)]
  # dt$name <- paste(totalConfirmedByRegionData()$region, totalConfirmedByRegionData()$count)
  dt$minusUntilToday <- 0 - dt$untilToday
  dt$minusToday <- 0 - dt$today
  dt$minusTotal <- dt$minusUntilToday + dt$minusToday
  dt %>%
    e_charts(region, x_index = 1) %>%
    e_bar(minusUntilToday,
          stack = '1',
          z = 2,
          itemStyle = list(color = middleRed),
          label = list(show = T, position = 'inside', color = '#FFFFFF', formatter = htmlwidgets::JS('
            function(params) {
              if (params.value[0] < -3) {
                return(0 - params.value[0]);
              } else {
                return("");
              }
            }
          ')),
          name = lang[[langCode]][79]) %>%
    e_bar(minusToday,
          stack = '1',
          z = 2,
          itemStyle = list(color = lightNavy),
          label = list(show = T, position = 'inside', color = '#FFFFFF', formatter = htmlwidgets::JS('
            function(params) {
              if (params.value[0] < 0) {
                return(0 - params.value[0]);
              } else {
                return("");
              }
            }
          ')),
          name = lang[[langCode]][78]) %>%
    e_bar(minusTotal,
          z = 1,
          itemStyle = list(color = darkRed),
          barGap = '-100%',
          label = list(show = T, position = 'left', formatter = htmlwidgets::JS('
            function(params) {
              if (params.value[0] < 0) {
                return(params.value[1] + "：" +(0 - params.value[0]));
              } else {
                return("");
              }
            }
          ')),
          name = '合計') %>%
    e_grid(right = '0%', bottom = '0%', top = '0%', left = '25%') %>%
    e_x_axis(splitLine = list(show = F), axisLabel = list(show = F),
             axisLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), show = F) %>%
    e_legend(orient = 'vertical', top = '0%', left = '25%') %>%
    e_legend_unselect(name = lang[[langCode]][78]) %>%
    e_flip_coords()
})

output$regionTimeSeries <- renderEcharts4r({
  total <- colSums(byDate[, 2:ncol(byDate)])
  totalOver0 <- names(total[total > 0])
  dt <- cumsum(byDate[, 2:ncol(byDate)])
  dt$date <- byDate$date
  dt <- melt(dt, measure.vars = 1:50, variable.name = 'region')
  dt2show <- dt[!region %in% lang[[langCode]][35:36]]
  dt2show <- dt2show[region %in% totalOver0]
  dt2show <- dt2show[value != 0]
  setorderv(dt2show, c('date', 'value', 'region'))
  
  newByDate <- rowSums(byDate[, c(2:48, 50)])
  timeSeriesTitle <- lapply(seq_along(byDate$date), function(i) {
    return(
      list(
        text = byDate$date[[i]],
        subtext = paste0('本日合計新規', newByDate[[i]], '人（検疫職員カテゴリを含む）')
        )
      )
  })
  
  dt2show %>%
    group_by(date) %>%
    e_chart(region, timeline = T) %>%
    e_bar(value) %>%
    e_axis(axisTick =list(show = F), axisLabel = list(interval = 0)) %>%
    e_x_axis(axisLabel = list(rotate = 90, interval = 0)) %>%
    e_y_axis(max = max(dt2show$value) + 5) %>%
    e_grid(bottom = '25%', left = '5%', right = '5%') %>%
    e_labels(show = T) %>%
    e_title(formatter = htmlwidgets::JS('
      function(params) {
        console.log(params)
        return("")
      }
                                        ')) %>%
    e_tooltip() %>%
    e_timeline_opts(left = '0%', right = '0%', symbol = 'diamond',
                    playInterval = 500,
                    loop = F,
                    currentIndex = nrow(byDate) - 1) %>%
    e_timeline_serie(
      title = timeSeriesTitle
    )
})

totalConfirmedByRegionData <- reactive({
  total <- colSums(byDate[, 2:ncol(byDate)])
  today <- colSums(byDate[nrow(byDate), 2:ncol(byDate)])
  untilToday <- colSums(byDate[1:nrow(byDate) - 1, 2:ncol(byDate)])
  total <- data.table(region = names(total), 
                      count = total, 
                      today = today, 
                      untilToday = untilToday)
  
  # if (is.null(input$showOtherRegion)) {
  #   total <- total[!(region %in% lang[[langCode]][35:36])]
  # } else {
  #   if (!('showShip' %in% input$showOtherRegion)) {
  #     total <- total[region != lang[[langCode]][35]] # クルーズ船
  #   }
  #   if (!('showFlight' %in% input$showOtherRegion)) {
  #     total <- total[region != lang[[langCode]][36]] # チャーター便
  #   }
  # }
  total <- total[!(region %in% lang[[langCode]][35:36])]
  total
})

output$genderBar <- renderEcharts4r({
  dt <- detail[, c('gender', 'age'), with = F]
  dt <- dt[, .(count = .N), by = c('gender', 'age')]
  dt <- reshape(data = dt, idvar = 'age', timevar = 'gender', direction = 'wide')
  dt$count.女 <- 0 - dt$count.女
  
  dt %>%
    e_chart(age) %>%
    e_bar(count.男, stack = '1', name = '男性', itemStyle = list(color = darkNavy)) %>%
    e_bar(count.女, stack = '1', name = '女性', itemStyle = list(color = middleRed)) %>%
    e_x_axis(type = 'category') %>%
    e_labels(position = 'inside', formatter = htmlwidgets::JS('
      function(params) {
        let count = params.value[0]
        if(count < 0) {
          count = -count
        }
        return(count)
      }
    ')) %>%
    e_y_axis(axisLabel = '', splitLine = list(show = F)) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS('
      function(params) {
        let count = params.value[0]
        if(count < 0) {
          count = -count
        }
        return("歳代：" + params.value[1]+ "<br>確認数：" + count)
      }
                                          '),
    ) %>%
    e_legend(top = '0%', right = '20%') %>%
    e_grid(top = '0%', bottom = '1%', left = '10%', right = '10%')
})

# ====感染者割合====
output$confirmedBar <- renderEcharts4r({
  dt <- data.table('label' = '感染者',
                   'domestic' = TOTAL_DOMESITC + TOTAL_OFFICER,
                   'ship' = TOTAL_SHIP,
                   'flight' = TOTAL_FLIGHT,
                   'domesticPer' = round((TOTAL_DOMESITC + TOTAL_OFFICER) / TOTAL_JAPAN * 100, 2),
                   'shipPer' = round(TOTAL_SHIP / TOTAL_JAPAN * 100, 2),
                   'flightPer' = round(TOTAL_FLIGHT / TOTAL_JAPAN * 100, 2)
  )
  e_charts(dt, label) %>%
    e_bar(shipPer, name = lang[[langCode]][35], stack = '1', itemStyle = list(color = lightRed)) %>%
    e_bar(domesticPer, name = lang[[langCode]][4], stack = '1', itemStyle = list(color = middleRed)) %>%
    e_bar(flightPer, name = lang[[langCode]][36], stack = '1', itemStyle = list(color = lightYellow)) %>%
    e_y_axis(max = 100, splitLine = list(show = F), show = F) %>%
    e_x_axis(splitLine = list(show = F), show = F) %>%
    e_grid(left = '0%', right = '0%', top = '0%', bottom = '0%') %>%
    e_labels(position = 'inside', formatter = htmlwidgets::JS('
      function(params) {
        return(params.value[0] + "%")
      }
    ')) %>%
    e_legend(show = F) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS(paste0('
      function(params) {
        return(params.seriesName + "：" + Math.round(params.value[0] / 100 * ', TOTAL_JAPAN, ', 0) + "名")
      }
    ')))
})

# ====退院者割合====
output$curedBar <- renderEcharts4r({
  dt <- data.table('label' = '退院者',
                   'domestic' = SYMPTOM_DISCHARGE_WITHIN$final,
                   'flight' = SYMPTOM_DISCHARGE_FLIGHT$final,
                   'ship' = DISCHARGE_SHIP$final,
                   'symtomlessDomestic' = SYMPTOMLESS_DISCHARGE_WITHIN$final,
                   'symtomlessFlight' = SYMPTOMLESS_DISCHARGE_FLIGHT$final,
                   'domesticPer' = round(SYMPTOM_DISCHARGE_WITHIN$final / DISCHARGE_TOTAL * 100, 2),
                   'flightPer' = round(SYMPTOM_DISCHARGE_FLIGHT$final / DISCHARGE_TOTAL * 100, 2),
                   'symtomlessDomesticPer' = round(SYMPTOMLESS_DISCHARGE_WITHIN$final / DISCHARGE_TOTAL * 100, 2),
                   'symtomlessFlightPer' = round(SYMPTOMLESS_DISCHARGE_FLIGHT$final / DISCHARGE_TOTAL * 100, 2),
                   'shipPer' = round(DISCHARGE_SHIP$final / DISCHARGE_TOTAL * 100, 2)
                   )
  e_charts(dt, label) %>%
    e_bar(domesticPer, 
          name = paste0(lang[[langCode]][4], ' (', lang[[langCode]][95], ')'), # 国内事例 （症状あり）
          stack = '1', itemStyle = list(color = lightGreen)) %>%
    e_bar(symtomlessDomesticPer, 
          name = paste0(lang[[langCode]][4], ' (', lang[[langCode]][96], ')'), # 国内事例 （無症状）
          stack = '1', itemStyle = list(color = middleGreen)) %>%
    e_bar(flightPer, 
          name = paste0(lang[[langCode]][36], ' (', lang[[langCode]][95], ')'), # チャーター便 （症状あり）
          stack = '1', itemStyle = list(color = darkGreen)) %>%
    e_bar(symtomlessFlightPer, 
          name = paste0(lang[[langCode]][36], ' (', lang[[langCode]][96], ')'), # チャーター便 （無症状）
          stack = '1', itemStyle = list(color = superDarkGreen)) %>%
    e_bar(shipPer, 
          name = lang[[langCode]][35], # クルーズ船
          stack = '1', itemStyle = list(color = middleGreen)) %>%
    e_y_axis(max = 100, splitLine = list(show = F), show = F) %>%
    e_x_axis(splitLine = list(show = F), show = F) %>%
    e_grid(left = '0%', right = '0%', top = '0%', bottom = '0%') %>%
    e_labels(position = 'inside', formatter = htmlwidgets::JS('
      function(params) {
        if(params.value[0] > 10) {
          return(params.value[0] + "%")
        } else {
          return("")
        }
      }
    ')) %>%
    e_legend(show = F) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS(paste0('
      function(params) {
        return("<b>" + params.seriesName + "</b><br>" + Math.round(params.value[0] / 100 * ',
        DISCHARGE_TOTAL, ', 0) + "名 (" + params.value[0] + "%)")
      }
    ')))
})

# ====死亡者割合====
output$deathBar <- renderEcharts4r({
  DEATH_TOTAL <- DEATH_DOMESITC + DEATH_SHIP
  dt <- data.table('label' = '死亡者',
                   'domestic' = DEATH_DOMESITC,
                   'flight' = DEATH_SHIP,
                   'domesticPer' = round(DEATH_DOMESITC / DEATH_TOTAL * 100, 2),
                   'shipPer' = round(DEATH_SHIP / DEATH_TOTAL * 100, 2)
  )
  e_charts(dt, label) %>%
    e_bar(domesticPer, name = lang[[langCode]][4], stack = '1', itemStyle = list(color = lightNavy)) %>%
    e_bar(shipPer, name = lang[[langCode]][35], stack = '1', itemStyle = list(color = darkNavy)) %>%
    e_y_axis(max = 100, splitLine = list(show = F), show = F) %>%
    e_x_axis(splitLine = list(show = F), show = F) %>%
    e_grid(left = '0%', right = '0%', top = '0%', bottom = '0%') %>%
    e_legend(show = F) %>%
    e_labels(position = 'inside', formatter = htmlwidgets::JS('
      function(params) {
        return(params.value[0] + "%")
      }
    ')) %>%
    e_flip_coords() %>%
    e_tooltip(formatter = htmlwidgets::JS(paste0('
      function(params) {
        return(params.seriesName + "：" + Math.round(params.value[0] / 100 * ', DEATH_TOTAL, ', 0) + "名")
      }
    ')))
})

# ====コールセンター====
output$callCenter <- renderEcharts4r({
  maxCall <- max(callCenterDailyReport$call)
  callCenterDailyReport %>%
    e_chart(date) %>%
    e_bar(call, name = 'コールセンター', stack = '1', itemStyle = list(color = middleBlue)) %>%
    e_bar(fax, name = 'FAX', stack = '1', itemStyle = list(color = darkBlue)) %>%
    e_bar(mail, name = 'メール', stack = '1', itemStyle = list(color = lightBlue)) %>%
    e_line(line, name = '回線数', y_index = 1, itemStyle = list(color = darkBlue)) %>%
    e_grid(left = '3%') %>%
    e_legend(type = 'scroll', orient = 'vertical', left = '10%', top = '15%') %>%
    e_mark_line(data = list(xAxis = '2020-02-07', itemStyle = list(color = middleBlue), 
                            label = list(formatter = ' 2/7\nフリーダイヤル化'))) %>%
    e_mark_line(data = list(xAxis = '2020-02-14', itemStyle = list(color = darkBlue), 
                            label = list(formatter = ' 2/14正午\nFAX対応'))) %>%
    e_mark_line(data = list(xAxis = '2020-02-19', itemStyle = list(color = lightBlue), 
                            label = list(formatter = ' 2/19正午\nメール対応'))) %>%
    e_x_axis(splitLine = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), axisLabel = list(inside = T), axisTick = list(show = F)) %>%
    e_y_axis(splitLine = list(show = F), index = 1, axisTick = list(show = F)) %>%
    e_tooltip(trigger = 'axis')
})

regionPCRData <- reactive({
  dt <- provincePCR
  dt[, per := round(陽性者数/累積検査数 * 100, 2)]
  dt$per[is.nan(dt$per)] <- 0
  dt[, position := -50]
  setorder(dt, -累積検査数)
  dt
})

# ====都道府県PCR====
output$regionPCR <- renderEcharts4r({
  dt <- regionPCRData()
  dateSeq <- sort(unique(dt$date))
  timeSeriesTitle <- lapply(seq_along(dateSeq), function(i) {
    item <- domesticDailyReport[date == dateSeq[i]]
    all <- ''
    if(nrow(item) > 0 ) {
      all <- paste0('  厚労省集計検査数：', item$pcr)
    }
    return(
      list(
        text = dateSeq[i],
        subtext = paste0('都道府県合計検査数：', sum(dt[date == dateSeq[i]]$累積検査数), all)
        )
    )
  })
  
  dt %>%
    group_by(date) %>%
    e_chart(県名, timeline = T) %>%
    e_bar(累積検査数, itemStyle = list(color = middleYellow)) %>%
    e_bar(陽性者数, z = 2, barGap = '-100%', itemStyle = list(color = darkRed)) %>%
    e_scatter(position, size = per, name = '陽性率') %>%
    e_axis(axisTick =list(show = F), axisLabel = list(interval = 0)) %>%
    e_x_axis(axisLabel = list(rotate = 90, interval = 0)) %>%
    e_y_axis(max = max(dt$累積検査数) + 30, 
             index = 0, min = -50,
             splitLine = list(show = F)) %>%
    e_grid(bottom = '25%', left = '5%', right = '5%') %>%
    e_labels(show = T, fontSize = 8, formatter = htmlwidgets::JS('
      function(params) {
        if(params.value[1] > 0) {
          return(params.value[1])
        } else {
          return("")
        }
      }
                                                   ')) %>%
    e_tooltip(trigger = 'axis', formatter = htmlwidgets::JS('
      function(params) {
        return(params[0].name + 
          "<br>累積検査数：" + params[0].value[1] + 
          "<br>陽性者数：" + params[1].value[1] +
          "<br>検査陽性者率：" + params[2].value[2] + "%"
        )
      }
    ')) %>%
    e_timeline_opts(left = '0%', right = '0%', symbol = 'diamond',
                    playInterval = 500, loop = F,
                    currentIndex = length(unique(dt$date)) - 1) %>%
    e_timeline_serie(
      title = timeSeriesTitle
    )
})

# ====個別都道府県のPCRデータ====
output$singleRegionPCR <- renderEcharts4r({
  regionName <- input$selectSingleRegionPCR
  data <- regionPCRData()[県名 == regionName]
  # regionName <- '茨城県' # TEST
  # data <- dt[県名 == regionName] #TEST
  setorder(data, date)
  data <- data[累積検査数 != 0 | 陽性者数 != 0]
  
  data %>%
    e_chart(date) %>%
    e_bar(累積検査数, itemStyle = list(color = middleYellow)) %>%
    e_bar(陽性者数, z = 2, barGap = '-100%', itemStyle = list(color = darkRed)) %>%
    e_line(per, name = '検査陽性率', y_index = 1) %>%
    e_x_axis(axisTick =list(show = F), splitLine = list(show = F)) %>%
    e_y_axis(axisTick =list(show = F), splitLine = list(show = F)) %>%
    e_y_axis(axisTick =list(show = F), index = 1, splitLine = list(show = F)) %>%
    e_title(
      text = regionName, 
      subtext = paste0('累積検査数ランキング：', maxCheckNumberData[県名 == regionName]$rank)
    ) %>%
    e_tooltip(trigger = 'axis')
})

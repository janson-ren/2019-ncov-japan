fluidPage(
  # fluidRow(
  #   box(width = 12,
  #       solidHeader = T,
  #       status = 'info',
  #       title = tagList(icon('info'), '通知'),
  #       collapsible = T,
  #       collapsed = T, 
  #       tags$small(
  #         paste0(
  #           '機能開発もデータの収集も全部ひとりで担当をしているので、',
  #           '患者さんの行動歴や厚生労働省が発表しているデータの整理を協力できる有志がございましたら是非Pull Requestを：'
  #         ),
  #         tags$a(href = 'https://github.com/swsoyee/2019-ncov-japan', 'Github'),
  #         '。一人でメンテナンスすることはやはり限度があります。データの更新だけで精一杯であり、機能開発はなかなか着手できませんでした。'
  #       ))
  # ),
  fluidRow(
    column(width = 7, style='padding:0px;',
      widgetUserBox(
        title = lang[[langCode]][17],
        # 新型コロナウイルス
        subtitle = lang[[langCode]][18],
        # 2019 nCoV
        width = 12,
        type = NULL,
        src = 'ncov.jpeg',
        color = "purple",
        collapsible = F,
        background = T,
        backgroundUrl = 'ncov_back.jpg',
        # tags$p(dashboardLabel(status = 'danger',  # APIアクセスできなかった
        #                       style = 'square', 
        #                       paste(sep = ' | ', lang[[langCode]][71], # ページ閲覧数
        #                             statics$result$totals$pageviews$all)
        #                       ),
        #        dashboardLabel(status = 'success',
        #                       style = 'square',
        #                       paste(sep = ' | ', lang[[langCode]][72], # 閲覧者数
        #                             statics$result$totals$uniques)
        #        )
        #        ),
        tags$p(tags$img(src = 'https://img.shields.io/badge/dynamic/json?url=https://stg.covid-2019.live/ncov-static/stats.json&label=%E9%96%B2%E8%A6%A7%E6%95%B0&query=$.result.totals.pageviews.all&color=orange&style=flat-square')),
        # 発熱や上気道症状を引き起こすウイルス...
        tags$p(lang[[langCode]][19]),
        footer = tagList(
          tags$a(href = lang[[langCode]][21], # https://www.mhlw.go.jp/stf/...
                 icon('link'), 
                 paste0(lang[[langCode]][22], # コロナウイルスはどのようなウイルスですか？
                        '（', lang[[langCode]][5], # 厚生労働省
                        '）、 ')),
          tags$a(href = lang[[langCode]][59], # https://phil.cdc.gov/Details.aspx?pid=2871
                 icon('image'), 
                 # 背景画像
                 lang[[langCode]][58])
        )
      )
    ),
    column(
      width = 5,
      fluidRow(
        valueBox(
          width = 6,
          value = sum(PCR_WITHIN$final, PCR_FLIGHT$final, PCR_SHIP$final),
          subtitle = paste0(lang[[langCode]][90], ' (+', sum(PCR_WITHIN$diff, PCR_FLIGHT$diff, PCR_SHIP$diff), ')'),
          icon = icon('vials'),
          color = "yellow"
        ),
        valueBox(
          width = 6,
          value = TOTAL_JAPAN,
          subtitle = paste0(lang[[langCode]][60], ' (+', TOTAL_JAPAN_DIFF, ')'),
          icon = icon('procedures'),
          color = "red"
        )
      ),
      fluidRow(
        valueBox(
          width = 6,
          value = DISCHARGE_TOTAL,
          subtitle = paste0(lang[[langCode]][6],
                            ' (+',
                            SYMPTOM_DISCHARGE_FLIGHT$diff +
                              SYMPTOM_DISCHARGE_WITHIN$diff +
                              SYMPTOMLESS_DISCHARGE_FLIGHT$diff +
                              SYMPTOMLESS_DISCHARGE_WITHIN$diff +
                              DISCHARGE_SHIP$diff, ')'),
          icon = icon('user-shield'),
          color = "green"
        ),
        valueBox(
          width = 6,
          value = DEATH_JAPAN,
          subtitle = paste0(lang[[langCode]][7], ' (+', DEATH_JAPAN_DIFF, ')'),
          icon = icon('bible'),
          color = "navy"
        )
      ),
      fluidRow(
        column(width = 12, style='padding:0px;',
        boxPlus(
          width = 12,
          actionButton(inputId = 'twitterShare',
                       label = 'Twitter',
                       icon = icon('twitter'),
                       onclick = sprintf("window.open('%s')", twitterUrl)
          ),
          actionButton(inputId = 'github',
                       label = 'Github',
                       icon = icon('github'),
                       onclick = sprintf("window.open('%s')", 'https://github.com/swsoyee/2019-ncov-japan')
          )
        )
        )
      )
    )
  ),
  fluidRow(
    boxPlus(
      # 国内状況推移
      title = tagList(icon('chart-line'), lang[[langCode]][88]),
      closable = F,
      collapsible = T,
      width = 12,
      tabsetPanel(
        id = 'linePlot',
        tabPanel(
          # 感染者数の推移
          title = lang[[langCode]][3], 
          icon = icon('procedures'),
          value = 'confirmed',
          fluidRow(
            column(
              width = 8,
              fluidRow(
                tags$br(),
                pickerInput(
                  inputId = 'regionPicker',
                  # 地域選択
                  label = lang[[langCode]][93],
                  choices = regionName,
                  selected = defaultSelectedRegionName,
                  options = list(
                    `actions-box` = TRUE,
                    size = 10,
                    # クリア
                    `deselect-all-text` = lang[[langCode]][91],
                    # 全部
                    `select-all-text` = lang[[langCode]][92],
                    # 三件以上選択されました
                    `selected-text-format` = lang[[langCode]][94] 
                  ),
                  multiple = T,
                  width = '70%',
                  inline = T
                )
              ),
              uiOutput('confirmedLineWrapper') %>% withSpinner()
            ),
            column(
              width = 4,
              tags$br(),
              tags$b(paste0(
                lang[[langCode]][97], length(regionZero), ' (', round(length(regionZero) /
                                                                        47 * 100, 2), '%)'
              )),
              uiOutput('saveArea'),
              tags$br(),
              tags$b('感染者'),
              echarts4rOutput('confirmedBar', height = '20px') %>% withSpinner(),
              uiOutput('todayConfirmed'),
              tags$br(),
              tags$b('死亡者'),
              echarts4rOutput('deathBar', height = '20px') %>% withSpinner(),
              uiOutput('todayDeath'),
              tags$hr(),
              tags$b('感染者確認数（日次）'),
              uiOutput('renderCalendar')
            )
          )
        ),
        tabPanel(
          # PCR検査数推移
          title = 'PCR検査数の推移',
          icon = icon('vials'),
          value = 'pcr',
          fluidRow(
            column(
              width = 8,
              tags$br(),
              fluidRow(
                column(
                  width = 6,
                  switchInput(
                    inputId = "showShipInPCR",
                    label = icon('ship'), 
                    offLabel = icon('eye-slash'), 
                    onLabel = icon('eye'),
                    value = F,
                    inline = T
                  ),
                  switchInput(
                    inputId = "showFlightInPCR",
                    label = icon('plane'),
                    offLabel = icon('eye-slash'), 
                    onLabel = icon('eye'),
                    value = T,
                    inline = T
                  )
                )
              ),
              echarts4rOutput('pcrLine') %>% withSpinner()
            ),
            column(
              width = 4,
              tagList(
                tags$br(),
                tags$b('注意点'),
                tags$li(lang[[langCode]][98]), # 「令和２年３月４日版」以後は、陽性となった者の~
                tags$li(lang[[langCode]][99]), # これまで延べ人数で公表しましたクルーズ船のＰＣＲ~
                tags$br(),
                tags$a(
                  href = 'https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html',
                  icon('link'),
                  '報道発表一覧（新型コロナウイルス）'
                ),
                tags$hr(),
                tags$b('PCR検査数（日次）')
              ),
              echarts4rOutput('pcrCalendar', height = '130px') %>% withSpinner()
            )
          )
        ),
        tabPanel(
          # 退院者数の推移
          title = lang[[langCode]][89], 
          icon = icon('user-shield'),
          value = 'discharged',
          fluidRow(
            column(
              width = 8,
              tags$br(),
              fluidRow(
                column(
                  width = 6,
                  switchInput(
                    inputId = "showShipInDischarge",
                    label = icon('ship'), 
                    offLabel = icon('eye-slash'), 
                    onLabel = icon('eye'),
                    value = F,
                    inline = T
                  ),
                  switchInput(
                    inputId = "showFlightInDischarge", 
                    label = icon('plane'),
                    offLabel = icon('eye-slash'), 
                    onLabel = icon('eye'),
                    value = T,
                    inline = T
                  )
                )
              ),
              echarts4rOutput('recoveredLine') %>% withSpinner()
            ),
            column(
              width = 4,
              tagList(
                tags$br(),
                uiOutput('dischargeSummary'),
                tags$b('退院者内訳'),
                echarts4rOutput('curedBar', height = '20px') %>% withSpinner(),
                uiOutput('todayCured'),
                tags$hr(),
                tags$b('退院数（日次）')
              ),
              echarts4rOutput('curedCalendar', height = '130px') %>% withSpinner()
            )
          )
        ),
        tabPanel(
          # コールセンターの対応
          title = 'コールセンターの対応', 
          icon = icon('headset'),
          value = 'callCenter',
          fluidRow(
            column(
              width = 8,
              echarts4rOutput('callCenter') %>% withSpinner()
            ),
            column(
              width = 4,
              tagList(
                tags$br(),
                tags$b('これまでの主な相談内容'),
                tags$li('現在の症状に対する不安'),
                tags$li('予防法、消毒、対処法等医療に関する一般的事項'),
                tags$li('政府の対策についてのご意見'),
                tags$li('渡航に関する相談'),
                tags$li('国内発症例の詳細な行動履歴について'),
                tags$li('その他'),
                tags$br(),
                tags$a(
                  href = 'https://www.mhlw.go.jp/content/10906000/000601711.pdf',
                  icon('link'),
                  '厚生労働省コールセンターの対応状況等について'
                ),
                tags$hr(),
                tags$b('相談を受けた件数（日次）')
              ),
              echarts4rOutput('callCenterCanlendar', height = '130px') %>% withSpinner()
            )
          )
        )
      ),
      tags$hr(),
      fluidRow(
        column(
          width = 2,
          # 国内事例
          descriptionBlock(
            number = TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF,
            number_color = 'red',
            number_icon = getChangeIcon(TOTAL_DOMESITC_DIFF + TOTAL_OFFICER_DIFF + TOTAL_FLIGHT_DIFF),
            header = TOTAL_DOMESITC + TOTAL_OFFICER + TOTAL_FLIGHT,
            text = lang[[langCode]][4]
          )
        ),
        column(
          width = 2,
          # クルーズ船
          descriptionBlock(
            number = TOTAL_SHIP_DIFF,
            number_color = 'red',
            number_icon = getChangeIcon(TOTAL_SHIP_DIFF),
            header = TOTAL_SHIP,
            text = lang[[langCode]][35],
          )
        ),
        column(
          width = 2,
          # 国内事例
          descriptionBlock(
            number = SYMPTOM_DISCHARGE_WITHIN$diff + 
              SYMPTOMLESS_DISCHARGE_WITHIN$diff + 
              SYMPTOM_DISCHARGE_FLIGHT$diff + 
              SYMPTOMLESS_DISCHARGE_FLIGHT$diff,
            number_color = 'green',
            number_icon = getChangeIcon(SYMPTOM_DISCHARGE_WITHIN$diff + 
                                          SYMPTOMLESS_DISCHARGE_WITHIN$diff + 
                                          SYMPTOM_DISCHARGE_FLIGHT$diff + 
                                          SYMPTOMLESS_DISCHARGE_FLIGHT$diff),
            header = SYMPTOM_DISCHARGE_WITHIN$final + 
              SYMPTOMLESS_DISCHARGE_WITHIN$final +
              SYMPTOM_DISCHARGE_FLIGHT$final + 
              SYMPTOMLESS_DISCHARGE_FLIGHT$final,
            text = lang[[langCode]][4]
          )
        ),
        column(
          width = 2,
          # クルーズ船
          descriptionBlock(
            number = DISCHARGE_SHIP$diff,
            number_color = 'green',
            number_icon = getChangeIcon(DISCHARGE_SHIP$diff),
            header = DISCHARGE_SHIP$final,
            text = lang[[langCode]][35],
          )
        ),
        column(
          width = 2,
          # 国内事例
          descriptionBlock(
            number = DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF,
            number_color = 'black',
            number_icon = getChangeIcon(DEATH_DOMESITC_DIFF + DEATH_OFFICER_DIFF),
            header = DEATH_DOMESITC + DEATH_OFFICER,
            text = lang[[langCode]][4]
          )
        ),
        column(
          width = 2,
          # クルーズ船
          descriptionBlock(
            number = DEATH_SHIP_DIFF,
            number_color = 'black',
            number_icon = getChangeIcon(DEATH_SHIP_DIFF),
            header = DEATH_SHIP,
            text = lang[[langCode]][35],
            right_border = F
          )
        )
    )
  )),
  fluidRow(
    boxPlus(
      title = tagList(icon('map-marked-alt'), '各都道府県の状況'),
      closable = F,
      collapsible = T,
      width = 12,
      tabsetPanel(
        tabPanel(
          title = tagList(icon('globe-asia'), '感染状況マップ'),
          fluidRow(
            column(
              width = 6,
              fluidRow(
                column(
                  width = 6,
                  tags$br(),
                  dropdownButton(
                    tags$h4('表示設定'),
                    materialSwitch(
                      inputId = 'showPopupOnMap', 
                      label = '日次増加数のポップアップ', 
                      status = "danger", 
                      value = T
                    ),
                    materialSwitch(
                      inputId = 'replyMapLoop', 
                      label = 'ループ再生', 
                      status = "danger", 
                      value = T
                    ),
                    dateRangeInput(
                      inputId = 'mapDateRange',
                      label = '表示日付',
                      start = byDate$date[nrow(byDate) - 30], 
                      end = byDate$date[nrow(byDate)],
                      min = byDate$date[1],
                      max = byDate$date[nrow(byDate)],
                      separator = " ~ ", 
                      language = 'ja'
                    ),
                    sliderInput(
                      inputId = 'mapFrameSpeed',
                      label = '再生速度（秒/日）', 
                      min = 0.5,
                      max = 3, 
                      step = 0.1, 
                      value = 0.8
                    ),
                    circle = F, 
                    status = "danger", 
                    icon = icon("gear"), 
                    size = 'sm',
                    width = "300px",
                    tooltip = tooltipOptions(title = '表示設定')
                  ),
                  # column(
                  #   width = 6,
                  #   actionButton(inputId = 'switchCaseMap', label = '事例マップへ')
                  # )
                ),
              ),
              echarts4rOutput('echartsMap', height = '600px')  %>% withSpinner(),
            ),
            column(
              width = 6,
              boxPad(
                echarts4rOutput('totalConfirmedByRegionPlot', height = '600px')  %>% withSpinner()
              )
            ),
          )
        ),
        tabPanel(
          title = tagList(icon('vials'), 'PCR検査状況'),
          fluidRow(
            column(
              width = 8,
              tags$br(),
              tags$a(icon('database'), 'データ提供：@kenmo_economics', 
                     href = 'https://twitter.com/kenmo_economics'
              ),
              tags$p('発表なしの日の検査数を0扱いしています（補間法のオプションを追加する予定あり）。また、個別の市のデータは県に含まれていないので、ご注意してください。データに関する問い合わせは@kenmo_economicsまで。'),
              echarts4rOutput('regionPCR') %>% withSpinner()
            ),
            column(
              width = 4,
              tags$br(),
              selectInput(
                inputId = 'selectSingleRegionPCR', 
                label = '地域選択', 
                choices = unique(provincePCR$県名)
                ),
              echarts4rOutput('singleRegionPCR')
            )
          )

        ),
        tabPanel(
          title = tagList(icon('chart-bar'), '時系列棒グラフ'),
          echarts4rOutput('regionTimeSeries') %>% withSpinner()
        )
      ),
      footer = tags$small(paste(
        lang[[langCode]][62], UPDATE_DATETIME, '開発＆調整中'
      ))
    ),
  ),
  fluidRow(
    boxPlus(title = tagList(icon('connectdevelop'), '感染経路ネットワーク'),
            width = 8,
            closable = F,
            # collapsed = T,
            echarts4rOutput('network') %>% withSpinner(),
            enable_sidebar = T,
            sidebar_start_open = F,
            sidebar_content = tagList(
              checkboxInput('hideSingle', '離散を非表示', T)
            ),
            footer = tags$small('3月9日以後に、厚労省のページでは感染者の詳細情報についての発表は中止になり、こちらのデータ更新も止むを得ず中止になりました。')),
    boxPlus(title = tagList(icon('venus-mars'), '歳代・性別'),
            width = 4,
            echarts4rOutput('genderBar'),
            closable = F,
            footer = tags$small('3月9日以後に、厚労省のページでは感染者の詳細情報についての発表は中止になり、こちらのデータ更新も止むを得ず中止になりました。')
    )
  ),
  fluidRow(
    boxPlus(title = tagList(icon('hospital'), '症状の進行'),
            width = 8,
            closable = F,
            # collapsed = T,
            dateInput(
              inputId = 'selectProcessDay', 
              label = '日付選択', 
              min = domesticDailyReport$date[1], 
              max = domesticDailyReport$date[nrow(domesticDailyReport)], 
              value = domesticDailyReport$date[nrow(domesticDailyReport)], language = 'ja'
            ),
            echarts4rOutput('processSankey') %>% withSpinner(),
            footer = tags$small('※開発バージョンです。最終版ではありません')
            ),
    boxPlus(width = 4, dataTableOutput('news') %>% withSpinner())
  )
)

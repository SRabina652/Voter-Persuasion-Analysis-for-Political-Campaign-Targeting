 # Introduction 
Political campaigns often face a major challenge: they do not know which voters are most likely to be persuaded. Because of this uncertainty, campaigns frequently send the same messages to a large number of voters, including people who have already decided how they will vote or are unlikely to change their opinions. This results in wasted time, money, and campaign resources. Without data-driven decision making, campaigns struggle to identify the right audience and deliver the most effective message.
This project focuses on addressing that problem using the Voter Persuasion dataset. The dataset contains information about voters at the individual, household, and neighborhood levels, along with experimental campaign data where voters were exposed to different political messages and candidate profiles. 
Using this data, the project applies analytics techniques to better understand voter behavior and identify patterns related to persuasion. The analysis helps demonstrate how political campaigns can use data analytics instead of relying only on intuition when making targeting decisions.
The main goal of this project is to help campaigns focus their outreach efforts on voters who are more likely to be influenced by certain political messages. By improving targeting strategies, campaigns can communicate more effectively while reducing unnecessary costs and effort.

# Business Problem and Business Goals
## Business problem
The political campaign does not have a reliable, data-driven system to identify which voters are most likely to be persuaded. Because of this, campaign resources such as advertisements, phone calls, text messages, and volunteer outreach are often distributed inefficiently.
As a result, the campaign spends time, money, and effort contacting voters who are unlikely to change their opinions, while potentially missing voters who could be influenced by specific political messages. This reduces the overall effectiveness of campaign strategies and makes it difficult to maximize voter engagement and persuasion outcomes.
Without analytics, campaign decisions rely heavily on intuition rather than evidence-based targeting, which can lead to lower campaign efficiency and weaker communication strategies.
## Business goals
The primary business goal of this project is to develop a predictive classification system that can accurately identify voters who are most likely to be persuaded by political campaign messages.
By using data-driven predictions, the campaign can focus its outreach efforts on high-probability voters instead of targeting all voters equally. This can help reduce wasted campaign resources, improve communication efficiency, and increase the overall effectiveness of campaign strategies.
Another important goal is to better understand the characteristics and behaviors associated with persuadable voters. These insights can help campaigns design more effective messaging strategies, improve voter engagement, and support smarter decision-making during political campaigns.

# Analytics Goals and Planned Approach
## Analytics goals
The goal of analytics is to understand the structure and characteristics of the voter persuasion dataset in order to support more effective, data-driven campaign decisions. This includes examining voter demographics, voting history, household information, and neighborhood characteristics to better understand how these factors may relate to voter persuasion outcomes.
The analysis focuses on data cleaning, exploratory data analysis (EDA), and identifying potentially important predictors for persuasion. Variable types, data distributions, missing values, and unusual or zero values are examined to ensure the dataset is accurate, consistent, and suitable for further analysis and modeling.
Another important analytics goal is to identify patterns and relationships within the data that may help explain differences between persuadable and non-persuadable voters. These steps help reduce noise, improve data quality, and simplify the dataset by focusing on meaningful variables.
By developing a strong understanding of the dataset, the analytics process creates a reliable foundation for future predictive modeling, voter segmentation, and campaign targeting strategies.

## Analytics approach
The analytical approach for this project is designed to support a better understanding of the voter persuasion dataset and prepare the data for informed, data-driven campaign decisions. The first stage focuses on data understanding and preprocessing to ensure that the variables accurately represent voter characteristics, behaviors, and campaign-related information. This includes reviewing variable types, checking for missing values, identifying unusual or extreme values, and confirming that zero values represent meaningful information rather than data quality issues.
The second stage involves exploratory data analysis (EDA) to identify overall patterns and trends within the dataset. Summary statistics, distributions, and variable relationships are examined to better understand how voter demographics, voting history, household characteristics, and neighborhood factors vary across the population. This step also helps identify potential outliers and provides important context for interpreting voter behavior and persuasion outcomes.
The final stage focuses on assessing predictor relevance by examining which variables or categories of variables appear most informative for understanding persuasion behavior. Variables related to demographics, political affiliation, voting participation, and community characteristics are reviewed to determine their potential usefulness for future predictive analysis. This process helps reduce unnecessary complexity while keeping the most meaningful information for later modeling and campaign targeting efforts.
Overall, the approach emphasizes building a clean, well-understood, and analytically reliable foundation before moving into predictive modeling and voter targeting strategies.

# Data Exploration and Preprocessing
## Data Understanding
The voter persuasion dataset contains 10,000 voter records and 79 variables. Each row represents an individual voter, while the variables describe demographics, household characteristics, neighborhood conditions, voting history, political engagement, and consumer interests. Having many variables provides a detailed view of voter behavior, but it also increases the possibility that some variables may contain limited analytical value. Therefore, the variables were reviewed carefully during the data understanding stage.
Most variables in the dataset are numeric, while a smaller number are categorical. The dataset contains 73 numeric variables and 6 categorical variables. This distinction is important because numeric variables can be summarized using statistical measures, whereas categorical variables require different preprocessing and analysis methods.
Basic summary statistics were reviewed to confirm that the values were reasonable and consistent. For example, voter age ranges from 18 to 100 years old, while household income varies widely across voters and communities. Variables related to voting participation, political affiliation, and neighborhood composition also showed meaningful variation throughout the dataset. These checks confirmed that the dataset was suitable for further analysis and modeling.
Missing value checks showed that none of the 79 variables contained missing values. Because the dataset was complete, no records were removed and no imputation methods were required. This simplified preprocessing and ensured the data was ready for further analysis.

## Attribute Screening and Variable Role
During attribute screening, variables were reviewed to determine whether they provided meaningful information for understanding voter behavior and persuasion outcomes.
Identifier variables such as X and VOTER_ID were excluded because they only serve as unique record labels and do not describe voter characteristics or campaign-related behavior. Including these variables could introduce unnecessary noise without improving analytical insight or predictive performance.
The variable MOVED_A was treated as the target variable because it represents whether a voter’s attitude changed after exposure to campaign messaging. Since it is the outcome the campaign is trying to predict, it was not included as a predictor during preprocessing.
The remaining variables were considered potential predictors because they capture important voter information, including demographics, household structure, political affiliation, voting history, neighborhood characteristics, and consumer interests. Reviewing variable roles at this stage helped create a cleaner and more focused dataset for later exploratory analysis and predictive modeling.

## Missing Value Check
Missing values were checked by reviewing each variable for null or NA entries across the dataset. The analysis showed that none of the 79 variables contained missing values.
Because the dataset was complete, no records were removed and no imputation methods were required. This simplified preprocessing and ensured the data was ready for further analysis and modeling.

## Zero Value Exploration
Zero values were reviewed separately because, in this dataset, zero often represents meaningful information rather than missing data. Each numeric variable was examined to determine how frequently zero values appeared.
Variables with very few unique values were treated as categorical indicators, where zero represents a valid category. Numeric variables with greater variation were retained for further analysis, resulting in 41 numeric variables being selected.
Several variables naturally contain zero values. For example, variables such as PR_PELIG and AP_PELIG use zero to indicate low voting participation eligibility, while demographic variables such as NH_ASIAN, NH_MULT, and HISP may contain zero when a neighborhood has no representation from a particular group.
These zero values were retained because they provide meaningful information about voter and community characteristics. Removing them could distort the data and lead to inaccurate conclusions in later analysis.

# Exploratory Data Analysis

 <img width="740" height="525" alt="image" src="https://github.com/user-attachments/assets/f9e4c98f-9060-4d69-9fc5-e7800d3c8d34" />

Figure 1: Distribution of Voter Movement (MOVED_A)
Figure 1 presents the distribution of the MOVED_A variable in the voter persuasion dataset. The variable indicates whether a voter changed their attitude after exposure to a campaign message.
The chart shows that approximately 6,300 voters were not persuaded (MOVED_A = 0), while around 3,700 voters showed movement after the message (MOVED_A = 1). This indicates that most voters remained unchanged, although a substantial portion responded to campaign messaging.
The distribution suggests a moderate class imbalance, where non-moved voters appear more frequently than moved voters. This is important because imbalance can influence classification model performance and should be considered during later modeling stages.
 
Figure 2: Age by Voter Movement
Figure 2 compares the age distribution of voters based on whether they changed their attitude after receiving a campaign message.
The median age for both groups is around 50 years old, indicating that middle-aged voters make up a large portion of the dataset regardless of persuasion outcome. The spread of ages is also similar across both groups, with voter ages ranging from approximately 18 to 100 years old.
The boxplot suggests that age alone may not strongly distinguish between voters who were persuaded and those who were not. However, the group of moved voters (MOVED_A = 1) shows slightly greater variation in age distribution, indicating that persuasion responses may occur across a wider age range.
 
Figure 3: Income by Voter Movement
Figure 3 compares median household income for voters who did not move after the message (MOVED_A = 0) and voters who did move after the message (MOVED_A = 1).
Most voters in both groups are concentrated around the $50,000–$90,000 income range. The median income for both groups appears close, around $60,000, meaning income alone does not strongly separate moved and non-moved voters.
The chart also shows high-income outliers in both groups. For MOVED_A = 0, there are outliers around $175,000–$200,000. For MOVED_A = 1, there is an outlier around $175,000. These outliers represent voters from much higher-income neighborhoods compared to the majority of the dataset. They were kept because they appear to be real values, not missing data or errors.

 
Figure 4: Party Registration Distribution
Figure 4 shows the distribution of voter party registration in the dataset across Democrats, Independents, and Republicans.
The dataset contains the largest number of Democratic voters, with approximately 4,700 records. Republican voters are the second largest group with around 2,800 records, while Independent voters represent the smallest group with approximately 2,200 records
The chart suggests that the dataset is politically diverse but somewhat dominated by Democratic voters. This is important because party affiliation was identified as one of the strongest predictors of voter movement and persuasion behavior. Differences in party registration may influence how voters respond to campaign messages and political outreach strategies.
 
Figure 5: Voting in 2012 vs Persuasion
Figure 5 compares voter movement outcomes with whether individuals voted in the 2012 election.
Among voters who did not vote in 2012 (VPR_12 = 0), a larger proportion remained unchanged after the campaign message (MOVED_A = 0). In contrast, voters who participated in the 2012 election (VPR_12 = 1) showed a higher proportion of movement after receiving the message (MOVED_A = 1).
The chart suggests that prior voting participation may be related to persuasion behavior. Politically active voters appear more likely to respond to campaign messaging compared to voters with lower political participation. This supports earlier findings that political engagement variables are important predictors for understanding voter persuasion.
 
Figure 6. Average Upscale Buying Score by Persuasion

Figure 6 compares the average upscale buying index between voters who were persuaded by the campaign message and those who were not.
The chart shows that voters who moved after the message have a slightly higher average upscale buying score compared to voters who did not move. However, the overall values for both groups are very low, indicating that upscale buying behavior is not strongly associated with persuasion outcomes.
This finding suggests that consumer lifestyle variables, such as upscale purchasing behavior, may provide only limited value for predicting voter movement when compared to stronger political and voting-related predictors.
 
Figure 7. Effect of Message A on Voter Movement

Figure 7 compares voter movement outcomes based on whether voters received Message A during the campaign experiment
Among voters who did not receive Message A (MESSAGE_A = 0), a larger number remained unchanged after the campaign communication. However, among voters who received Message A (MESSAGE_A = 1), the number of persuaded voters (MOVED_A = 1) becomes relatively higher compared to non-moved voters.
This pattern suggests that Message A may have had a positive influence on voter persuasion. Voters exposed to the message appear more likely to change their attitudes compared to those who did not receive it. The results indicate that campaign messaging strategies can play an important role in influencing voter behavior and may be useful predictors in later classification modeling.

 
Figure 8. Gender (Female) vs Persuasion
Figure 8 compares voter persuasion outcomes based on gender using the variable GENDER_F, where 1 represents female voters and 0 represents non-female voters.
Among non-female voters (GENDER_F = 0), approximately 70% remained unchanged after the campaign message, while about 55% showed movement. Among female voters (GENDER_F = 1), the proportion of persuaded voters increases to around 45%, compared to about 28% who did not move.
These results suggest that female voters may be slightly more responsive to campaign messaging compared to non-female voters. Although the difference is moderate, gender appears to provide some useful information for understanding persuasion behavior.
 
Figure 9. Parents vs Persuasion
Figure 9 compares persuasion outcomes based on whether voters have children in the household.
Voters without children (Has Kids = 0) make up the larger share of persuaded voters, accounting for approximately 62% of the moved group. In comparison, voters with children (Has Kids = 1) represent around 38% of voters who were persuaded after receiving campaign messaging.
These results suggest that voters without children may have been somewhat more responsive to campaign messages than voters with children. However, the difference is moderate, indicating that household structure may provide supporting information but is likely less important than direct political or voting-related predictors.
  
 
Figure 10. Household Political Composition vs Persuasion

Figure 10 compares the number of registered Democrats, Republicans, and Independents in a household across voter persuasion outcomes (MOVED_A).
The results show that voters who were persuaded (MOVED_A = 1) tend to have slightly more Democratic household members compared to non-moved voters. In contrast, non-moved voters generally have a higher number of registered Republicans in the household, suggesting that stronger Republican household representation may be associated with lower persuasion likelihood.
For Independent household composition, both groups show similar distributions, with most households containing few Independent voters. This indicates a weaker relationship between Independent household structure and persuasion outcomes.
The boxplots also contain several outliers, with some households having as many as 8 to 9 politically affiliated members. These outliers were retained because they represent real household political compositions rather than errors in the dataset.
Overall, the figure suggests that household political background may influence persuasion behavior, especially for Democratic and Republican households.

  
  
 
Figure 11. Neighborhood Demographic Composition vs Persuasion
Figure 11 compares neighborhood demographic percentages across voters who did not move (MOVED_A = 0) and voters who moved (MOVED_A = 1).
For White population percentage, the median is slightly higher for non-moved voters, around 65–67%, compared to about 62–64% for moved voters. African American percentage is slightly higher among moved voters, with a median around 18–20%, compared to about 15–17% for non-moved voters.
Hispanic, Asian, and Multiracial percentages are generally low for both groups. Hispanic median values are around 2–4%, Asian around 3–4%, and Multiracial around 1–2%. The plots also show outliers, including Hispanic values near 35–40%, Asian values around 12–16%, and Multiracial values around 6–8%.
Overall, the data suggests that neighborhood demographic differences exist, but they are moderate rather than very large.
  
     
Figure 12. Neighborhood Commuting Patterns vs Persuasion

Figure 12 compares several neighborhood commuting characteristics across voter persuasion outcomes (MOVED_A), including commuting by car, carpooling, public transit, walking, and commute duration.
The results show that commuting by car is the dominant transportation method for both groups, with median values around 75–85%. Non-moved voters show slightly higher car commuting percentages compared to moved voters. In contrast, persuaded voters (MOVED_A = 1) tend to have somewhat higher percentages for carpooling, public transit use, and walking.
For commute duration, neighborhoods where commuting times are less than 10 minutes show median values around 8–10%, while 60–90+ minute commute percentages are generally lower, around 5–7% for both groups. Persuaded voters show slightly higher long-commute percentages overall.
Several outliers are visible across the plots. Public transit percentages exceed 10–15% in some neighborhoods, walking percentages rise above 30%, and carpooling percentages exceed 20–30% in a few cases. These outliers were retained because they represent real neighborhood transportation differences rather than data errors.
Overall, the results suggest that neighborhood commuting behavior may have a moderate relationship with persuasion outcomes, although the differences between moved and non-moved voters are not extremely large.


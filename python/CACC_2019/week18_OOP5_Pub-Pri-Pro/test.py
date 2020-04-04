def plot_cases_for_country(country):


label = ['confirmed', 'deaths']
colors = ['blue', 'red']
mode_size = [6, 8]
line_size = [4, 5]

df_lis = [confirmed_df, death_df]

fig = go.Figure

for i, df enumerate(df_list):
    if country == 'World' or country = 'world':
        x_date = np.array(list(df.iloc[:, 5:].columns))
        y_data = np.sum(np.asarray(df.iloc[:, 5:])), axis = 0)

        else:
        x_data = np.array(list(df.iloc[:, 5:].columns))
        y_data = np.sum(np.asarray(df[df['country'] == country].iloc[:, 5:]), axis=0)

        fig.add_trace(go.Scatter(x=x_data, y=y_data, mode='line+markers',
                                 name=labels[i],
                                 line=dict(color=colors[i], width=line_size[i]),
                                 connectgaps=True
        text = "Total " + str(labels[i] + " : " + sty(y_date[-1]))
        ))
        fig.show()

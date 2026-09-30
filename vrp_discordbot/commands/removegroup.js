exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || !/^\d{1,10}$/.test(params[0]) || !params[1]) {
        return message.reply('Invalid args! Correct term is: ' + process.env.PREFIX + 'removegroup [permid] [group name]')
    }
    fivemexports.ghmattimysql.execute("SELECT * FROM `vrp_user_data` WHERE user_id = ? AND dkey = ?", [parseInt(params[0]), "vRP:datatable"], (result) => {
        if (result && result.length > 0) {
            let dvalue = JSON.parse(result[0].dvalue)
            if (!dvalue.groups) dvalue.groups = {}
            let groups = dvalue.groups
            groups[params[1]] = undefined;
            fivemexports.ghmattimysql.execute("UPDATE `vrp_user_data` SET dvalue = ? WHERE user_id = ? AND dkey = ?", [JSON.stringify(dvalue), parseInt(params[0]), "vRP:datatable"])
        }
    })
    let embed = {
        "title": "Removed Group",
        "description": `\nSuccess! Removed Group to: ${params[0]} Group Name: ${params[1]}`,
        "color": 5301186,
        "footer": {
            "text": "vRP • Made by JamesUK#6793"
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}

exports.conf = {
    name: "removegroup",
    perm: 3
}
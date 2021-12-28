using UnityEngine;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine.Assertions;

[System.Serializable]
public class BreadDatas
{
    public List<Bread> _breads;
}

public class BreadMakerSystem : GameSystem
{
    private string TargetDir => Application.persistentDataPath;
    private string DataPath => TargetDir + "/Data.txt";
    private string DataBackupPath => TargetDir + "/DataBackup.txt";

    public List<Bread> _breads;
    public List<double> times;

    public BreadMakerSystem(Game game) : base(game)
    {
    }

    public override void Initialize()
    {
        base.Initialize();
        _breads = new List<Bread>();
        /*if (game._versionToolData.Debug)
        {
            times = new List<double>()
            {
                10,
                30,
                100,
                200,
                501,
                502,
                503,
                504,
                505,
                506,
            };
        }
        else
        {
            times = new List<double>()
            {
                TimeHelper.Minute * 30,
                TimeHelper.Hour * 12,
                TimeHelper.Day,
                TimeHelper.Day * 2,
                TimeHelper.Day * 4,
                TimeHelper.Day * 7,
                TimeHelper.Day * 15,
                TimeHelper.Month,
                TimeHelper.Month * 3,
                TimeHelper.Month * 6,
            };
        }*/
        times = new List<double>()
        {
                // 10,
                // 30,
                // 100,
                // 200,
                // 501,
                // 502,
                // 503,
                // 504,
                // 505,
                // 506,


            TimeHelper.Minute * 30,
            TimeHelper.Hour * 12,
            TimeHelper.Day,
            TimeHelper.Day * 2,
            TimeHelper.Day * 4,
            TimeHelper.Day * 7,
            TimeHelper.Day * 15,
            TimeHelper.Month,
            TimeHelper.Month * 3,
            TimeHelper.Month * 6,

        };
        Assert.IsTrue(times.Count == 10);

        if (Directory.Exists(TargetDir) == false)
        {
            Directory.CreateDirectory(TargetDir);
        }

        if (File.Exists(DataPath) == false)
        {
            WriteExcel(DataPath, false);
        }

        ReadExcel(DataPath);

        InvokeRepeating(nameof(SendPer), 0f, 1f);

        //WriteData(false);
    }

    private void BtnClickEventCallback(BtnClickEvent obj)
    {
        var index = obj.breadUI.gameObject.Number();
        _breads[index].Ripe += 1;
        WriteData(false);
    }

    private void SendPer()
    {
        Incident.SendEvent(new PerSecondEvent()
        {
            timeStamp = GetTimeStamp()
        });
    }

    public bool CanInteraction(Bread bread, double timeStamp)
    {
        double p = bread.ProducedDate;
        int ripe = bread.Ripe;

        double interval = timeStamp - p;

        int level = 0;
        for (int i = 0; i < times.Count; i++)
        {
            var per = times[i];

            if (interval >= per)
            {
                level += 1;
            }
            else
            {
                break;
            }
        }

        return level >= ripe;
    }


    private double GetTimeStamp()
    {
        return TimeHelper.GetNowTimeStamp();
    }

    public void WriteData(bool isOpen = true)
    {
        WriteExcel(DataPath, true);

        if (isOpen)
        {
            Incident.SendEvent(new ErrorEvent()
            {
                ErrorMsg = "WriteData Success"
            });
            this.Delay(3f, () => { OpenTargetDir(); });
        }
    }

    public void WriteDataBackup(bool isOpen = true)
    {
        WriteExcel(DataBackupPath, true);

        if (isOpen)
        {
            Incident.SendEvent(new ErrorEvent()
            {
                ErrorMsg = "WriteDataBackup Success"
            });
            this.Delay(3f, () => { OpenTargetDir(); });
        }
    }

    public void OpenTargetDir()
    {
        Application.OpenURL(TargetDir);
    }
    UTF8Encoding utf8 = new UTF8Encoding(false);


    void ReadExcel(string path)
    {


        try
        {
            var fileStr = File.ReadAllText(path, Encoding.UTF8);
            BreadDatas bData = JsonUtility.FromJson<BreadDatas>(fileStr);

            foreach (var saveB in bData._breads)
            {
                Bread wantB = new Bread();

                wantB.ID = saveB.ID;
                wantB.Content = saveB.Content;

                if (saveB.Title == "")
                {
                    int maxLenth = saveB.Content.Length;
                    int limit = 7;

                    if (maxLenth >= limit)
                    {
                        wantB.Title = new string(saveB.Content.Take(limit).ToArray());
                    }
                    else
                    {
                        wantB.Title = new string(saveB.Content.Take(maxLenth).ToArray());
                    }
                }
                else
                {
                    wantB.Title = saveB.Title;
                }

                if (saveB.ProducedDate == default)
                {
                    wantB.ProducedDate = GetTimeStamp();
                }
                else
                {
                    wantB.ProducedDate = saveB.ProducedDate;
                }

                if (saveB.Ripe == default)
                {
                    wantB.Ripe = 1;
                }
                else
                {
                    wantB.Ripe = saveB.Ripe;
                }

                _breads.Add(wantB);
            }

            /*var stream = File.Open(path, FileMode.Open, FileAccess.Read, FileShare.Read);
            var excelReader = ExcelReaderFactory.CreateOpenXmlReader(stream);
            var result = excelReader.AsDataSet();
            var t = result.Tables[0];

            var collection = t.Rows;
            var row = t.Rows.Count;
            var col = t.Columns.Count;

            for (int i = 1; i < row; i++)
            {
                Bread b = new Bread();

                b.ID = Convert.ToString(collection[i][0]);
                b.Content = Convert.ToString(collection[i][2]);
                var tStr = collection[i][1].ToString();
                if (string.IsNullOrEmpty(tStr))
                {
                    int maxLenth = b.Content.Length;
                    int limit = 7;
                    if (maxLenth >= limit)
                    {
                        b.Title = new string(b.Content.Take(limit).ToArray());
                    }
                    else
                    {
                        b.Title = new string(b.Content.Take(maxLenth).ToArray());
                    }
                }
                else
                {
                    b.Title = Convert.ToString(tStr);
                }

                var pStr = collection[i][3].ToString();
                if (string.IsNullOrEmpty(pStr))
                {
                    b.ProducedDate = GetTimeStamp();
                }
                else
                {
                    b.ProducedDate = Convert.ToDouble(pStr);
                }

                var rStr = collection[i][4].ToString();
                if (string.IsNullOrEmpty(rStr))
                {
                    b.Ripe = 1;
                }
                else
                {
                    b.Ripe = Convert.ToInt32(rStr);
                }

                _breads.Add(b);
            }

            stream.Close();
            excelReader.Close();*/
        }
        catch (Exception e)
        {
            Incident.SendEvent(new ErrorEvent()
            {
                ErrorMsg = "发生错误" + e.ToString()
            });
        }
    }

    void WriteExcel(string path, bool isDeleteOrigin)
    {
        try
        {
            if (isDeleteOrigin)
            {
                if (File.Exists(path))
                {
                    File.Delete(path);
                }
            }

            var bData = new BreadDatas()
            {
                _breads = new List<Bread>(_breads)
            };

            if (bData._breads.Count == 0)
            {
                bData._breads.Add(new Bread()
                {
                    Content = "这是记忆面包测试例子"
                });
            }

            string dataStr = JsonUtility.ToJson(bData, true);
            File.WriteAllText(path, dataStr, Encoding.UTF8);


            /*FileInfo newFile = new FileInfo(path);

            if (isDeleteOrigin)
            {
                if (newFile.Exists == true)
                {
                    newFile.Delete();
                }
            }

            // 所有操作语句要放到using中
            using (ExcelPackage package = new ExcelPackage(newFile))
            {
                ExcelWorksheet worksheet = package.Workbook.Worksheets.Add("Sheet1"); // 添加sheet
                worksheet.DefaultColWidth = 15; // 默认列宽
                worksheet.DefaultRowHeight = 20; // 默认行高
                worksheet.Cells[1, 1].Value = "ID";
                worksheet.Cells[1, 2].Value = "Title";
                worksheet.Cells[1, 3].Value = "Content";
                worksheet.Cells[1, 4].Value = "ProducedDate";
                worksheet.Cells[1, 5].Value = "Ripe";

                for (var index = 0; index < _breads.Count; index++)
                {
                    var bread = _breads[index];
                    worksheet.Cells[(index + 2), 1].Value = Convert.ToString(bread.ID);
                    worksheet.Cells[(index + 2), 2].Value = Convert.ToString(bread.Title);
                    worksheet.Cells[(index + 2), 3].Value = Convert.ToString(bread.Content);
                    worksheet.Cells[(index + 2), 4].Value = Convert.ToString(bread.ProducedDate);
                    worksheet.Cells[(index + 2), 5].Value = Convert.ToString(bread.Ripe);
                }

                package.Save();
            }*/
        }
        catch (Exception e)
        {
            Incident.SendEvent(new ErrorEvent()
            {
                ErrorMsg = "发生错误" + e.ToString()
            });
        }
    }

    //auto
    private void Awake()
    {
        Incident.DeleteEvent<BtnClickEvent>(BtnClickEventCallback);
        Incident.RigisterEvent<BtnClickEvent>(BtnClickEventCallback);
    }
}
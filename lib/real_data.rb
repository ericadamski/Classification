class DataSets

  def self.get (data_set)
    data = []
    case data_set
      when 'iris'
        # 0 - sepal length
        # 1 - sepal width
        # 2 - petal length
        # 3 - petal width
        # 4 - Class : Iris Setosa, Iris Versicolour, Iris Virginica
        File.read(File.expand_path(File.dirname(__FILE__))+"/../data/iris.csv")
            .each_line do |line|
          data.push line.split(',')
        end
        return binaryify data, 3
      when 'wine'
        # 0 - Class: 1-3
        # 1 - Alcohol
        # 2 - Malic Acid
        # 3 - Ash
        # 4 - Alcalinity of ash
        # 5 - magnesium
        # 6 - phenols
        # 7 - flavanoids
        # 8 - nonflavanoid phenol
        # 9 - proanthocyanins
        # 10- color intensity
        # 11- hue
        # 12- OD280/OD315 of diluted wines
        # 13- proline
        File.read(File.expand_path(File.dirname(__FILE__))+
          "/../data/wine.csv").each_line do |line|
          data.push line.split(',')
        end
        return binaryify data, data.first().size - 1
      when 'heart_disease'
        # 0 - age
        # 1 - gender
        # 2 - cp
        # 3 - Rest bps
        # 4 - chol
        # 5 - fbs
        # 6 - restecg
        # 7 - thalach
        # 8 - exang
        # 9 - oldpeak
        # 10- dlope
        # 11- ca
        # 12- thal
        # 13- ClassL 1 - 5
        File.read(File.expand_path(File.dirname(__FILE__))+
          "/../data/heartDisease.csv").each_line do |line|
          data.push line.split(',')
        end
        return binaryify data, data.first().size - 1
    end
  end

  def self.binaryify (data_set, size)
    # get threshold for each feature
    range = [] # data_set.length - 1
    for i in 0..size do
      range[i] = data_set.map { |vector| vector[i].to_f }.flatten().minmax
    end
    # convert into vecters of 0 or 1
    bdata = []
    for vector in data_set do
      vect = []
      for i in 0..size do
        vect[i] = vector[i].to_f > avg(range[i]) ? 1 : 0
      end
      bdata.push vect
    end
    bdata
  end

  def self.avg (range)
    range.reduce(:+).to_f / range.size
  end

end
